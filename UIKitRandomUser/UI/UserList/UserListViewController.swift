//
//  UserListViewController.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class UserListViewController: UIViewController {
    private let segueShowUserDetailsId = "segueShowUserDetails"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var genderFilter: UISegmentedControl!
    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var magnifyingGlassImageView: UIImageView!
        
    @IBOutlet var emptyMessageView: UIView!
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet var filterAppliedFooter: UIView!
    
    private var loadMoreControl: LoadMoreControl!
    private var viewModel: UserListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView.register(UINib(nibName: UserTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: UserTableViewCell.nibName)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.loadMoreControl = LoadMoreControl(scrollView: tableView, spacingFromLastCell: 10, indicatorHeight: 60)
        self.loadMoreControl.delegate = self
        
        if #available(iOS 13, *) {
            // UIImage(systemName:) is available in iOS 13 and it supports dark mode.
            self.magnifyingGlassImageView.image = UIImage(systemName: "magnifyingglass")
            
        } else {
            self.magnifyingGlassImageView.image = UIImage(named: "Search")?.withRenderingMode(.alwaysTemplate)
            self.magnifyingGlassImageView.tintColor = self.genderFilter.tintColor
        }
        
        self.viewModel = UserListViewModel(delegate: self)
        self.setUpRxBindings()
        self.subscribeViewModelState()
        self.viewModel.setUpAndRun(frcDelegate: self) { [weak self] in
            self?.loadMoreControl.stop()
        }
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == segueShowUserDetailsId,
            let data = sender,
            let user = data as? User,
            let userDetailsVC = segue.destination as? UserDetailsViewController {
            userDetailsVC.setUp(user: user)
        }
    }
}

// // MARK: - FetchedResultsController delegate
extension UserListViewController: NSFetchedResultsControllerDelegate {
    
    // We don't use func controller(_ controller: didChange: at indexPath: for type: newIndexPath:)
    // because it results in shaking animations when appending items due to unordered 'insert' operations.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent")
        self.tableView.reloadData()
    }
}

extension UserListViewController: UserListViewModelDelegate {
    func dataRefreshed(_ viewModel: UserListViewModel, filterApplied: Bool) {
        print("dataRefreshed, filterApplied: \(filterApplied)")
        self.tableView.reloadData()
    }
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.viewModel.frc.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        print("numberOfRowsInSection: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.nibName) as! UserTableViewCell
        
        let user = self.viewModel.frc.object(at: indexPath)
        cell.configure(user: user)
        return cell
    }
    
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let user = self.viewModel.frc.object(at: indexPath)
        self.performSegue(withIdentifier: segueShowUserDetailsId, sender: user)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreControl.didScroll()
    }
}

extension UserListViewController: LoadMoreControlDelegate {
    func loadMoreControl(didStartAnimating loadMoreControl: LoadMoreControl) {
        print("didStartAnimating")
        self.viewModel.fetchUsersFromBackendAndStoreResultsInCoreData { [weak self] in
            self?.loadMoreControl.stop()
        }
    }

    func loadMoreControl(didStopAnimating loadMoreControl: LoadMoreControl) {
        print("didStopAnimating")
    }
}

// MARK: - Set up rx bindings and observe view model states
extension UserListViewController {
    
    private func setUpRxBindings() {
        self.searchInput.rx.text.orEmpty
            .bind(to: self.viewModel.searchQuery)
            .disposed(by: self.viewModel.disposeBag)
        self.genderFilter.rx.value
            .bind(to: self.viewModel.selectedGenderOptionIndex)
            .disposed(by: self.viewModel.disposeBag)
    }
    
    private func subscribeViewModelState() {
        Observable.combineLatest(
            self.viewModel.filterApplied.asObservable(),
            self.viewModel.isDataSetEmpty.asObservable(),
            self.viewModel.isLoading.asObservable())
        .skip(1)
        .observeOn(MainScheduler.instance)
        .subscribe(
                onNext: { [weak self] filterApplied, isDataSetEmpty, isLoading  in
                    print("subscribeViewModelState filterApplied: \(filterApplied), isDataSetEmpty: \(isDataSetEmpty), isLoading: \(isLoading)")
                                        
                    if isDataSetEmpty {
                        self?.loadMoreControl.enabled = false
                        self?.tableView.backgroundView = self?.emptyMessageView
                        self?.tableView.tableFooterView = UIView()
                        
                        if isLoading {
                            self?.emptyMessageLabel.text = "Loading..."
                            return
                        }
                        
                        if filterApplied {
                            self?.emptyMessageLabel.text = "No user found.\n\nNote: the name and gender filters apply to users already loaded. Clear the filters and scroll down to load more users."
                        } else {
                            self?.emptyMessageLabel.text = "No user found. Please check your Internet connection."
                        }
                    } else {
                        self?.tableView.backgroundView = nil
                        
                        if filterApplied {
                            self?.loadMoreControl.enabled = false
                            self?.tableView.tableFooterView = self?.filterAppliedFooter
                        } else {
                            self?.loadMoreControl.enabled = true
                            self?.tableView.tableFooterView = UIView()
                        }
                    }
                })
        .disposed(by: self.viewModel.disposeBag)
    }
}
