//
//  Property.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation
import SourceKittenFramework

struct Property {
    let name: String
    let typeName: String

    init(name: String, typeName: String) {
        self.name = name
        self.typeName = typeName
    }

    init?(structure: Structure) {
        guard structure.kind == .varInstance,
            let name = structure.name,
            let typeName = structure.typeName else {
            return nil
        }

        self.name = name
        self.typeName = typeName
    }
}
