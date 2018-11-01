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

    let file: File
    let offset: Int64

    var instanceName: String {
        return name.firstWordLowercased
    }

    init?(structure: Structure, file: File) {
        guard
            let kind = structure.kind, Type.declarationKinds.contains(kind),
            let name = structure.name,
            let offset = structure.offset else {
            return nil
        }

        self.name = name
        self.kind = kind
        self.file = file
        self.offset = offset
        self.methods = structure.substructures.compactMap { Method(structure: $0, file: file) }
        self.properties = structure.substructures.compactMap { Property(structure: $0, file: file) }
        self.nestedTypes = structure.substructures.compactMap { Type(structure: $0, file: file) }
        self.inheritedTypeNames = (structure[.inheritedtypes] as [[String: SourceKitRepresentable]]?)?
            .compactMap { $0["key.name"] as? String } ?? []
    }
}
