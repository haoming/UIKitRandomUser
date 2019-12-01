//
//  UserFetcherTests.swift
//  UIKitRandomUserTests
//
//  Created by Haoming Ma on 1/12/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import XCTest
@testable import UIKit_RUser
import RxSwift
import RxCocoa
import RxBlocking

class UserFetcherTests: XCTestCase {
    
    private let seed = "abc"
    private let disposeBag = DisposeBag()
    
    private var fetcher = UIKit_RUser.UserFetcher()
    
    override func setUp() {
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchUsers() {
        do {
            if let response = try self.fetcher.fetchUsers(page: 1, count: 3, seed: seed)
                .toBlocking().first() {
                
                XCTAssertEqual(self.seed, response.info!.seed)
                XCTAssertEqual(3, response.info!.results)
                
                let users = response.results!
                XCTAssertEqual(3, users.count)
                
                XCTAssertEqual("Louane", users[0].name!.first!)
                XCTAssertEqual("Vidal", users[0].name!.last!)
                XCTAssertEqual("female", users[0].gender!)
                XCTAssertEqual("louane.vidal@example.com", users[0].email!)
                
                XCTAssertEqual("don.white@example.com", users[1].email!)
                XCTAssertEqual("loan.lucas@example.com", users[2].email!)
                
            } else {
                XCTFail("Failed to fetch users.")
            }
        } catch {
            XCTFail("Failed to fetch users. Please check your Internet connection.")
        }
    }

}
