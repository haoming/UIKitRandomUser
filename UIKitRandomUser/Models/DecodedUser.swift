//
//  DecodedUser.swift
//  RandomUser
//
//  Created by Haoming Ma on 14/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import Foundation

// Model structs revised based on the generated code at https://app.quicktype.io

// MARK: - DecodedUser
struct DecodedUser: Codable {
    let gender: String?
    let name: Name?
    let location: Location?
    let email: String?
    let login: Login?
    let dob, registered: DateTime?
    let phone, cell: String?
    let id: ID?
    let picture: Picture?
    let nat: String?
}

extension DecodedUser {
    var dateOfBirth: Date? {
        get {
            return DateUtils.parse(self.dob?.date)
        }
    }
    
    var registeredTime: Date? {
        get {
            return DateUtils.parse(self.registered?.date)
        }
    }
}

// MARK: - DateTime
struct DateTime: Codable {
    // use String instead of Date to make the JSON parsing more robust to allow ill-formed date time strings
    let date: String?
}

// MARK: - ID
struct ID: Codable {
    let name, value: String?
}

// MARK: - Location
struct Location: Codable {
    let street: Street?
    let city, state, country: String?
    let coordinates: Coordinates?
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let latitude, longitude: String?
}

// MARK: - Street
struct Street: Codable {
    let number: Int?
    let name: String?
}

// MARK: - Login
struct Login: Codable {
    let uuid, username, password, salt: String?
    let md5, sha1, sha256: String?
}

// MARK: - Name
struct Name: Codable {
    let title, first, last: String?
}

// MARK: - Picture
struct Picture: Codable {
    let large, medium, thumbnail: String?
}
