//
//  User.swift
//  RandomUser
//
//  Created by Haoming Ma on 16/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import Foundation
import CoreLocation

protocol User {
    var firstName: String {get}
    var lastName: String {get}
    var title: String? {get}
    
    var email: String? {get}
    var phone: String? {get}
    var cellPhone: String? {get}
    var registeredTime: Date? {get}
    
    var gender: String? {get}
    var dateOfBirth: Date? {get}
    var nationality: String? {get}
    
    var thumbnailUrl: String? {get}
    var mediumPictureUrl: String? {get}
    var largePictureUrl: String? {get}
    
    var streetNumber: String? {get}
    var streetName: String? {get}
    var city: String? {get}
    var state: String? {get}
    var country: String? {get}
    var coordinate: CLLocationCoordinate2D? {get}
}

extension User {
    var fullName: String {
        get {
            return "\(self.firstName) \(self.lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    var genderEmoji: String? {
        if gender == "Male" || gender == "male" {
            return "♂️"
        } else if gender == "Female" || gender == "female" {
            return "♀️"
        } else {
            return nil
        }
    }
    
    var nationalityCountryCode: CountryCodeIso3166? {
        if let nat = self.nationality, let natCode = CountryCodeIso3166(rawValue: nat.uppercased()) {
            return natCode
        } else {
            return nil
        }
    }
    
    var avatarUrl: URL? {
            get {
                // the resolution of thumbnail is not good enough to use as avatars
    //            if let thumbnail = self.thumbnailUrl, let thumbnailURL = URL(string: thumbnail) {
    //                return thumbnailURL
    //            } else
                    
                if let mediumPic = self.mediumPictureUrl, let mediumPicURL = URL(string: mediumPic) {
                    return mediumPicURL
                } else if let largePic = self.largePictureUrl, let largePicURL = URL(string: largePic) {
                    return largePicURL
                } else {
                    return nil
                }
            }
        }
        
    var largeAvatarUrl: URL? {
        get {
            if let largePic = self.largePictureUrl, let largePicURL = URL(string: largePic) {
                return largePicURL
            } else if let mediumPic = self.mediumPictureUrl, let mediumPicURL = URL(string: mediumPic) {
                return mediumPicURL
            } else if let thumbnail = self.thumbnailUrl, let thumbnailURL = URL(string: thumbnail) {
                return thumbnailURL
            } else {
                return nil
            }
        }
    }
    
    var address: String? {
        get {
            var address = ""
            if let streetNumber = self.streetNumber {
                address = address + streetNumber + " "
            }
            if let streetName = self.streetName {
                address = address + streetName + ", "
            }
            if let city = self.city {
                address = address + city + ", "
            }
            if let state = self.state {
                address = address + state + ", "
            }
            if let country = self.country {
                address = address + country
            }
            
            return address
        }
    }
}
