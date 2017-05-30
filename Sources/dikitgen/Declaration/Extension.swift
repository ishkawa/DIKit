//
//  Extension.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/30.
//
//

import Foundation
import SourceKittenFramework

struct Extension {
    let name: String
    let kind: SwiftDeclarationKind
    let functions: [Function]
    let properties: [Property]
    let inheritedTypes: [String]

    init?(structure: Structure) {
        guard
            let kind = structure.kind, kind == .extension,
            let name = structure.name else {
            return nil
        }
        
        self.name = name
        self.kind = kind
        self.functions = structure.substructures.flatMap(Function.init)
        self.properties = structure.substructures.flatMap(Property.init)
        self.inheritedTypes = (structure[.inheritedtypes] as? [[String: SourceKitRepresentable]])?
            .flatMap { $0["key.name"] as? String } ?? []
    }
}
