//
//  UserFetcher.swift
//  UIKitRandomUser
//
//  Created by Haoming Ma on 26/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum RandomUserError: Error, Equatable {
  case parsing(description: String)
  case network(description: String)
}

public class UserFetcher {
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetchUsers(page: Int, count: Int, seed: String, gender: String? = nil, nationality: String? = nil) -> Observable<RandomUserApiResponse> {
        let url = getQueryURLComponents(page: page, count: count, seed: seed, gender: gender, nationality: nationality)
        return fetch(urlComponents: url)
    }
    
    private func fetch<T>(urlComponents: URLComponents) -> Observable<T> where T: Decodable {
        guard let url = urlComponents.url else {
            return Observable.create { observer in
                let error = RandomUserError.network(description: "Couldn't create URL")
                observer.onError(error)
                return Disposables.create {}
            }
        }

        return self.urlSession.rx.data(request: URLRequest(url: url))
            .map { data in
                if let json = String(data: data, encoding: .utf8) {
                    print("response json:")
                    print(json)
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(T.self, from: data)
                    return result
                } catch {
                    print(error)
                    throw RandomUserError.parsing(description: error.localizedDescription)
                }
            }
    }
}

// MARK: - RandomUser APIs
private extension UserFetcher {
  struct RandomUserAPI {
    static let scheme = "https"
    static let host = "randomuser.me"
    static let path = "/api/1.3/"
  }
  
  func getQueryURLComponents(page: Int, count: Int, seed: String, gender: String? = nil, nationality: String? = nil) -> URLComponents {
    var components = URLComponents()
    components.scheme = RandomUserAPI.scheme
    components.host = RandomUserAPI.host
    components.path = RandomUserAPI.path
    
    var queryItems = [
      URLQueryItem(name: "page", value: "\(page)"),
      URLQueryItem(name: "results", value: "\(count)"),
      URLQueryItem(name: "seed", value: seed)
    ]
    if let gender = gender {
        queryItems.append(URLQueryItem(name: "gender", value: gender))
    }
    if let nationality = nationality {
        queryItems.append(URLQueryItem(name: "nat", value: nationality))
    }
    components.queryItems = queryItems
    return components
  }
}
