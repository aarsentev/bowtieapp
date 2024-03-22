//
//  BowTie+CoreDataProperties.swift
//  CoreDataImages
//
//  Created by Alex Arsentev on 2024-03-22.
//

import Foundation
import CoreData

extension BowTie {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BowTie> {
        return NSFetchRequest<BowTie>(entityName: "BowTie")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var tintColor: NSObject?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var name: String?
    @NSManaged public var lastWorn: Date?
    @NSManaged public var photoData: Data?
    @NSManaged public var rating: Double
    @NSManaged public var url: URL?
    @NSManaged public var searchKey: String?
    
}

extension BowTie: Identifiable {
    
}
