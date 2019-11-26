//
//  UserListViewModel.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum GenderFilter: Int {
    case FemaleAndMale = 0
    case Female = 1
    case Male = 2
}

protocol UserListViewModelDelegate: class {
    func showUserDetails(user: User?, indexPath: IndexPath)
}


class UserListViewModel: NSObject {
    private weak var delegate: UserListViewModelDelegate!
    
    private let disposeBag = DisposeBag()
    private var fetcher: UserFetcher
    
    init(delegate: UserListViewModelDelegate) {
        self.delegate = delegate
        self.fetcher = UserFetcher()
        super.init()
        
        print("call fetchUsers")
        do {
            try self.fetcher.fetchUsers(page: 1, count: 30, seed: UUID().uuidString)
                .subscribe(
                onNext: { result in
                   print("got result")
                },
                onError: { error in
                   print(error.localizedDescription)
                },
                onCompleted: {
                   print("Completed event.")
                }).disposed(by: disposeBag)
        } catch {
            
        }
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
