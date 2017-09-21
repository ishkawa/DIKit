//
//  Type.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation
import SourceKittenFramework

struct Type {
    private static var declarationKinds: [SwiftDeclarationKind] {
        return [.struct, .class, .enum, .protocol]
    }

    let name: String
    let kind: SwiftDeclarationKind
    let methods: [Method]
    let properties: [Property]
    let nestedTypes: [Type]
    let inheritedTypeNames: [String]

    var instanceName: String {
        return name.firstWordLowercased
    }

    init?(structure: Structure, file: File) {
        guard
            let kind = structure.kind, Type.declarationKinds.contains(kind),
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.kind = kind
        self.methods = structure.substructures.flatMap { Method(structure: $0, file: file) }
        self.properties = structure.substructures.flatMap { Property(structure: $0, file: file) }
        self.nestedTypes = structure.substructures.flatMap { Type(structure: $0, file: file) }
        self.inheritedTypeNames = (structure[.inheritedtypes] as? [[String: SourceKitRepresentable]])?
            .flatMap { $0["key.name"] as? String } ?? []
    }
}
