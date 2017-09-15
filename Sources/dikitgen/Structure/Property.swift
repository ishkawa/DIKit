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
    let isStatic: Bool

    init(name: String, typeName: String, isStatic: Bool = false) {
        self.name = name
        self.typeName = typeName
        self.isStatic = isStatic
    }

    init?(structure: Structure) {
        guard structure.kind == .varInstance || structure.kind == .varStatic,
            let name = structure.name,
            let typeName = structure.typeName else {
            return nil
        }

        self.name = name
        self.typeName = typeName
        self.isStatic = structure.kind == .varStatic
    }
}
