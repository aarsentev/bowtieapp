//
//  ColorAttributeTransformer.swift
//  CoreDataImages
//
//  Created by Alex Arsentev on 2024-03-22.
//

import Foundation
import UIKit

class ColorAttributeTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }
    
    static func register() {
        let className = String(describing: ColorAttributeTransformer.self)
        let name = NSValueTransformerName(className)
        let transformer = ColorAttributeTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
