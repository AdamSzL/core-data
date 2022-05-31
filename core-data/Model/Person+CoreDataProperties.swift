//
//  Person+CoreDataProperties.swift
//  core-data
//
//  Created by adamszlosarczyk on 20/05/2022.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var nazwisko: String?
    @NSManaged public var pesel: String?
    @NSManaged public var imie: String?

}

extension Person : Identifiable {

}
