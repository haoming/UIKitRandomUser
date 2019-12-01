//
//  UserListViewModel.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

enum GenderFilter: Int {
    case FemaleAndMale = 0
    case Female = 1
    case Male = 2
}

 protocol UserListViewModelDelegate: class {
    func dataRefreshed(_ viewModel: UserListViewModel, filterApplied: Bool)
 }


class UserListViewModel {
    
    let disposeBag = DisposeBag()
    
    // UI state
    let searchQuery = Variable<String>("")
    let selectedGenderOptionIndex = Variable<Int>(GenderFilter.FemaleAndMale.rawValue)
    
    // VM state
    let filterApplied = Variable<Bool>(false)
    let isDataSetEmpty = Variable<Bool>(true)
    let isLoading = Variable<Bool>(false)
        
    private weak var delegate: UserListViewModelDelegate!
    private weak var managedObjectContext: NSManagedObjectContext!
    
    private var page: Int
    private let countPerPage: Int
    private var seed: String
    
    private var fetcher: UserFetcher
    private var coreDataFetcher: CoreDataUserFetcher
        
    init(moc: NSManagedObjectContext? = nil, delegate: UserListViewModelDelegate) {
        self.delegate = delegate
        self.fetcher = UserFetcher()
        
        self.page = 1
        self.countPerPage = 30
        self.seed = UUID().uuidString
        
        if let moc = moc {
            self.managedObjectContext = moc
        } else {
            let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            self.managedObjectContext = moc
        }
        self.coreDataFetcher = CoreDataUserFetcher(managedObjectContext: self.managedObjectContext)

        self.setUpFilterObservables()
    }
    
    var frc: NSFetchedResultsController<UserEntity> {
        get {
            return self.coreDataFetcher.fetchedResultsController
        }
    }
    
    private func setUpFilterObservables() {
        let searchObserverable = self.searchQuery.asObservable()
        .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
        .distinctUntilChanged()
        
        let genderOptionObserverable = self.selectedGenderOptionIndex.asObservable()
        
        Observable.combineLatest(searchObserverable, genderOptionObserverable)
                    .skip(1) // skip the initial empty filter
                    .observeOn(MainScheduler.instance)
                    .subscribe(
                            onNext: { [weak self] search, genderOptionIndex in
                                print("filter next: search - \(search), gender - \(genderOptionIndex)")
                                self?.filterUpdated(searchQuery: search, genderFilter: GenderFilter(rawValue: genderOptionIndex)!)
                            },
                            onError: { error in
                                print("filter error: \(error)")
                            },
                            onCompleted: {
                                print("filter complete")
                            })
                    .disposed(by: self.disposeBag)
    }
}

extension UserListViewModel {
    func refreshRandomUsers() {
        guard !self.isLoading.value else {
            return
        }
        self.searchQuery.value = ""
        self.selectedGenderOptionIndex.value = GenderFilter.FemaleAndMale.rawValue
        self.seed = UUID().uuidString
        self.page = 1
        self.fetchUsersFromBackendAndStoreResultsInCoreData {
        }
    }
    
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        if let cell = cell as? UserTableViewCell {
            cell.configure(user: self.coreDataFetcher.fetchedResultsController.object(at: indexPath))
        }
    }
    
    func setUpAndRun(frcDelegate: NSFetchedResultsControllerDelegate, completionHandler: @escaping () -> Void) {
        self.coreDataFetcher.fetchedResultsController.delegate = frcDelegate
        self.fetchUsersFromCoreData()
        self.fetchUsersFromBackendAndStoreResultsInCoreData(completionHandler: completionHandler)
    }
    
    func fetchUsersFromBackendAndStoreResultsInCoreData(completionHandler: @escaping () -> Void) {
        print("call fetchAndStore")
        guard Thread.isMainThread else {
            fatalError("fetchAndStore must be called in the main thread")
        }
        
        if self.isLoading.value {
            return
        }
        self.isLoading.value = true
        
        self.fetcher.fetchUsers(page: self.page, count: self.countPerPage, seed: self.seed)
            .observeOn(MainScheduler.instance)
            .subscribe(
                    onNext: { response in
                        print("got response, main thread: \(Thread.isMainThread)")
                        if self.page == 1 {
                            // the first page response for a new seed
                            // clear the old data for a different seed
                            self.clearUserEntityData()
                        }
                        self.store(response: response, currentPage: self.page)
                        self.page = self.page + 1
                    },
                    onError: { error in
                        self.isLoading.value = false
                        print(error.localizedDescription)
                        completionHandler()
                    },
                    onCompleted: {
                        print("Completed event, main thread: \(Thread.isMainThread)")
                        self.isLoading.value = false
                        completionHandler()
                    })
            .disposed(by: self.disposeBag)
    }
    
    private func clearUserEntityData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: UserEntity.coreDataEntityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        do {
            let deleteResult = try managedObjectContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            
            let objectIDArray = deleteResult?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey : objectIDArray]
            // merge the deletion into the current managedObjectContext
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [managedObjectContext])
            
            print("Existing data cleared")
        } catch {
            // unlikely to happen
            print("Failed to delete existing data for UserEntity")
        }
    }
    
    private func store(response: RandomUserApiResponse, currentPage: Int) {
        guard let users = response.results, let apiInfo = response.info else {
            return
        }
        
        print("store users")
        var userEntities: [UserEntity] = []
        for i in 0..<users.count {
            let index = (currentPage - 1) * self.countPerPage + i
            
            let userEntity = UserEntity.newInstance(context: self.managedObjectContext, user: users[i], apiInfo: apiInfo, index: Int64(index))
            
            userEntities.append(userEntity)
        }
        do {
            try self.managedObjectContext.save()
        } catch {
            print(error)
        }
    }

    private func filterUpdated(searchQuery: String, genderFilter: GenderFilter) {
        let nameQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if nameQuery == "", genderFilter == .FemaleAndMale {
            self.filterApplied.value = false
        } else {
            self.filterApplied.value = true
        }
        
        print("filterUpdated - filterApplied: \(filterApplied.value), gender: \(genderFilter), search: \(nameQuery), main thread: \(Thread.isMainThread)")
        self.fetchUsersFromCoreData(nameSearchQuery: nameQuery, genderFilter: genderFilter)
        // the call above will not trigger call on controllerDidChangeContent(controller:)
        // so we need to call delegate.dataRefreshed
        self.delegate.dataRefreshed(self, filterApplied: self.filterApplied.value)
    }
    
    private func updateStateIsDataSetEmpty() {
        guard let sections = self.frc.sections else {
            self.isDataSetEmpty.value = true
            return
        }
        let sectionInfo = sections[0]
        self.isDataSetEmpty.value = sectionInfo.numberOfObjects == 0
    }
    
    private func fetchUsersFromCoreData(nameSearchQuery: String = "", genderFilter: GenderFilter = .FemaleAndMale) {
        self.coreDataFetcher.fetch(nameSearchQuery: nameSearchQuery, genderFilter: genderFilter)
        self.updateStateIsDataSetEmpty()
    }
}

