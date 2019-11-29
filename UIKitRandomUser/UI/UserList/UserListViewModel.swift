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
    func showUserDetails(user: User, indexPath: IndexPath)
}


class UserListViewModel: NSObject {
    private weak var delegate: UserListViewModelDelegate!
    private weak var managedObjectContext: NSManagedObjectContext!
    
    private var isLoading: Bool
    private var page: Int
    private let countPerPage: Int
    private var seed: String
    
    private let disposeBag = DisposeBag()
    private var fetcher: UserFetcher
    private var coreDataFetcher: CoreDataUserFetcher
        
    init(delegate: UserListViewModelDelegate, moc: NSManagedObjectContext? = nil) {
        self.delegate = delegate
        self.fetcher = UserFetcher()
        
        self.isLoading = false
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
        
        super.init()
    }
}

extension UserListViewModel {
//    func refreshRandomUsers() {
//        guard !self.isLoading else {
//            return
//        }
//        self.searchQuery = ""
//        self.selectedGenderOptionIndex = GenderFilter.FemaleAndMale.rawValue
//        self.seed = UUID().uuidString
//        self.page = 1
//        self.fetchAndStore()
//    }
    
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        if let cell = cell as? UserTableViewCell {
            cell.configure(user: self.coreDataFetcher.fetchedResultsController.object(at: indexPath))
        }
    }
    
    func setUpAndRun(frcDelegate: NSFetchedResultsControllerDelegate) {
        self.coreDataFetcher.fetchedResultsController.delegate = frcDelegate
        self.coreDataFetcher.fetch()
        self.fetchAndStore()
    }
    
    func fetchAndStore() {
        print("call fetchAndStore")
        guard Thread.isMainThread else {
            fatalError("fetchAndStore must be called in the main thread")
        }
        
        if self.isLoading {
            return
        }
        self.isLoading = true
        
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
                        self.isLoading = false
                        print(error.localizedDescription)
                    },
                    onCompleted: {
                        print("Completed event, main thread: \(Thread.isMainThread)")
                        self.isLoading = false
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

}

extension UserListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.coreDataFetcher.fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        print("numberOfRowsInSection: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.nibName) as! UserTableViewCell
        
        let user = self.coreDataFetcher.fetchedResultsController.object(at: indexPath)
        cell.configure(user: user)
        return cell
    }
    
}

extension UserListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let user = self.coreDataFetcher.fetchedResultsController.object(at: indexPath)
        
        self.delegate.showUserDetails(user: user, indexPath: indexPath)
    }
}
