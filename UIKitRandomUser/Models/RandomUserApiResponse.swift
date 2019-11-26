//
//  RandomUserApiResponse.swift
//  RandomUser
//
//  Created by Haoming Ma on 14/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import Foundation

struct ApiInfo: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

struct RandomUserApiResponse: Codable {
    let results: [DecodedUser]?
    let info: ApiInfo?
    let error: String?
}
