//
//  UserListViewController.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController {

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
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension UserListViewController: UserListViewModelDelegate {
    func showUserDetails(user: User?, indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "segueShowUserDetails", sender: user)
    }
        
}
