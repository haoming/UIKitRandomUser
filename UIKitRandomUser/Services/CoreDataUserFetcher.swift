//
//  CoreDataUserFetcher.swift
//  RandomUser
//
//  Created by Haoming Ma on 16/11/19.
//  Copyright © 2019 Haoming. All rights reserved.
//

import CoreData

class CoreDataUserFetcher {
    private weak var managedObjectContext: NSManagedObjectContext!
    
    private lazy var fetchedResultsController: NSFetchedResultsController<UserEntity> = {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest() as! NSFetchRequest<UserEntity>

        fetchRequest.fetchBatchSize = 30
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptor]

        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: self.managedObjectContext,
                                          sectionNameKeyPath: nil, cacheName: "UserCoreDataCache")
    }()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func fetch(nameSearchQuery: String = "", genderFilter: GenderFilter = .FemaleAndMale) -> [UserEntity] {
        do {
            if nameSearchQuery == "", genderFilter == .FemaleAndMale {
                self.fetchedResultsController.fetchRequest.predicate = nil
            } else if nameSearchQuery != "", genderFilter == .FemaleAndMale {
                self.fetchedResultsController.fetchRequest.predicate = namePredicate(nameSearchQuery: nameSearchQuery)
            } else if nameSearchQuery == "", genderFilter != .FemaleAndMale {
                self.fetchedResultsController.fetchRequest.predicate = genderPredicate(genderFilter: genderFilter)
            } else { //if nameSearchQuery != "", genderFilter != .FemaleAndMale
                let pred = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    namePredicate(nameSearchQuery: nameSearchQuery),
                    genderPredicate(genderFilter: genderFilter)
                ])
                self.fetchedResultsController.fetchRequest.predicate = pred
            }
            
            try self.fetchedResultsController.performFetch()
            return self.fetchedResultsController.fetchedObjects!
        } catch {
            print("performFetch error: \(error)")
            return []
        }
    }
}


extension CoreDataUserFetcher {
    private func namePredicate(nameSearchQuery: String) -> NSPredicate {
        let arg = nameSearchQuery + "*" // prefix matching makes more sense than containing matching for names
        let firstNamePred = NSPredicate(format: "firstName LIKE[cd] %@", arg)
        let lastNamePred = NSPredicate(format: "lastName LIKE[cd] %@", arg)
        return NSCompoundPredicate(orPredicateWithSubpredicates: [firstNamePred, lastNamePred])
    }
    
    private func genderPredicate(genderFilter: GenderFilter) -> NSPredicate {
        switch genderFilter {
        case .Female:
            return NSPredicate(format: "gender == %@", "female")
        case .Male:
            return NSPredicate(format: "gender == %@", "male")
        case .FemaleAndMale:
            fatalError("genderFilter must be .Female or .Male")
        }
    }
}

