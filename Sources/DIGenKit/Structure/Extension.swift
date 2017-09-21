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
    let functions: [Method]
    let properties: [Property]
    let inheritedTypes: [String]

    init?(structure: Structure, file: File) {
        guard
            let kind = structure.kind, kind == .extension,
            let name = structure.name else {
            return nil
        }
        
        self.name = name
        self.kind = kind
        self.functions = structure.substructures.flatMap { Method(structure: $0, file: file) }
        self.properties = structure.substructures.flatMap { Property(structure: $0, file: file) }
        self.inheritedTypes = (structure[.inheritedtypes] as? [[String: SourceKitRepresentable]])?
            .flatMap { $0["key.name"] as? String } ?? []
    }
}
