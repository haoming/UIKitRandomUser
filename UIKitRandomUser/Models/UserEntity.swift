//
//  UserEntity.swift
//  RandomUser
//
//  Created by Haoming Ma on 13/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import CoreData
import CoreLocation

class UserEntity : NSManagedObject, Identifiable {
    static let coreDataEntityName = "UserEntity"
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var title: String?

    @NSManaged var email: String?
    @NSManaged var phone: String?
    @NSManaged var cellPhone: String?
    @NSManaged var registeredTime: Date?

    @NSManaged var gender: String?
    @NSManaged var dateOfBirth: Date?
    @NSManaged var nationality: String?

    @NSManaged var largePictureUrl: String?
    @NSManaged var mediumPictureUrl: String?
    @NSManaged var thumbnailUrl: String?

    @NSManaged var streetNumber: String?
    @NSManaged var streetName: String?
    @NSManaged var city: String?
    @NSManaged var state: String?
    @NSManaged var country: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?

    @NSManaged var seed: String?
    @NSManaged var index: Int64
    
    static func newInstance(context: NSManagedObjectContext, user: DecodedUser, apiInfo: ApiInfo, index: Int64) -> UserEntity {
        let entity = UserEntity(context: context)
        entity.cellPhone = user.cell
        entity.city = user.location?.city
        entity.country = user.location?.country
        entity.dateOfBirth = user.dateOfBirth
        entity.email = user.email
        entity.firstName = user.name?.first ?? ""
        entity.gender = user.gender?.lowercased()
        entity.index = index
        entity.largePictureUrl = user.picture?.large
        entity.lastName = user.name?.last ?? ""
        
        if let lat = user.location?.coordinates?.latitude,
            let latFloat = Float(lat) {
            entity.latitude = NSNumber(value: latFloat)
        }
        if let lon = user.location?.coordinates?.longitude,
            let lonFloat = Float(lon) {
            entity.longitude = NSNumber(value: lonFloat)
        }
        
        entity.nationality = user.nat
        entity.mediumPictureUrl = user.picture?.medium
        entity.phone = user.phone
        entity.registeredTime = user.registeredTime
        entity.seed = apiInfo.seed
        entity.state = user.location?.state
        entity.streetName = user.location?.street?.name
        if let num = user.location?.street?.number {
            entity.streetNumber = "\(num)"
        }
        
        entity.thumbnailUrl = user.picture?.thumbnail
        entity.title = user.name?.title
        
        return entity
    }
}

extension UserEntity: User {
    
    var coordinate: CLLocationCoordinate2D? {
        if let lat = self.latitude, let lon = self.longitude {
            return CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
        } else {
            return nil
        }
    }
}
