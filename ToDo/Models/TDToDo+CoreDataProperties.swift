//
//  TDToDo+CoreDataProperties.swift
//  ToDo
//
//  Created by Rick Wierenga on 01/02/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//
//

import Foundation
import CoreData


extension TDToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TDToDo> {
        return NSFetchRequest<TDToDo>(entityName: "TDToDo")
    }

    @NSManaged public var isDone: Bool
    @NSManaged public var name: String?

}
