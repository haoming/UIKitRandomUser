//
//  UserListViewController.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit
import CoreData

class UserListViewController: UIViewController {
    private let segueShowUserDetailsId = "segueShowUserDetails"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var genderFilter: UISegmentedControl!
    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var magnifyingGlassImageView: UIImageView!
    
    private var viewModel: UserListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = UserListViewModel(delegate: self)
        
        self.tableView.register(UINib(nibName: UserTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: UserTableViewCell.nibName)
        
        self.tableView.delegate = self.viewModel
        self.tableView.dataSource = self.viewModel
        
        if #available(iOS 13, *) {
            // UIImage(systemName:) is available in iOS 13 and it supports dark mode.
            self.magnifyingGlassImageView.image = UIImage(systemName: "magnifyingglass")
            
        } else {
            self.magnifyingGlassImageView.image = UIImage(named: "Search")?.withRenderingMode(.alwaysTemplate)
            self.magnifyingGlassImageView.tintColor = UIColor.lightGray
        }
        
        self.viewModel.setUpAndRun(frcDelegate: self)
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

extension UserListViewController: UserListViewModelDelegate {
    func showUserDetails(user: User, indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: segueShowUserDetailsId, sender: user)
    }
}

// // MARK: - FetchedResultsController delegate
extension UserListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
          if let indexPath = newIndexPath {
            tableView.insertRows(at: [indexPath], with: .automatic)
          }
        case .delete:
          if let indexPath = indexPath {
            tableView.deleteRows(at: [indexPath], with: .automatic)
          }
        case .update:
          if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
            self.viewModel.configure(cell: cell, indexPath: indexPath)
          }
        case .move:
          if let indexPath = indexPath {
            tableView.deleteRows(at: [indexPath], with: .automatic)
          }
          if let newIndexPath = newIndexPath {
            tableView.insertRows(at: [newIndexPath], with: .automatic)
          }
        default:
            break
        }
    }
}
