//
//  UserListViewModel.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit

protocol UserListViewModelDelegate: class {
    func showUserDetails(user: User?, indexPath: IndexPath)
}


class UserListViewModel: NSObject {
    private weak var delegate: UserListViewModelDelegate!
    
    init(delegate: UserListViewModelDelegate) {
        super.init()
        self.delegate = delegate
    }
}

extension UserListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.nibName) as! UserTableViewCell
        return cell
    }
    
}

extension UserListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        self.delegate.showUserDetails(user: nil, indexPath: indexPath)
    }
}
