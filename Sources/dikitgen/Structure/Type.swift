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
    let functions: [Function]
    let properties: [Property]
    let inheritedTypeNames: [String]
    let typerefs: [Structure]

    var isInjectable: Bool {
        return inheritedTypeNames.contains("Injectable")
    }

    var instanceName: String {
        return name.replacingCharacters(
            in: name.startIndex..<name.index(name.startIndex, offsetBy: 1),
            with: String(name[name.startIndex]).lowercased())
    }

    init?(structure: Structure) {
        guard
            let kind = structure.kind, Type.declarationKinds.contains(kind),
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.kind = kind
        self.functions = structure.substructures.flatMap(Function.init)
        self.properties = structure.substructures.flatMap(Property.init)
        self.inheritedTypeNames = (structure[.inheritedtypes] as? [[String: SourceKitRepresentable]])?
            .flatMap { $0["key.name"] as? String } ?? []

        self.typerefs = structure.elements.filter { $0[.kind] as? String == "source.lang.swift.structure.elem.typeref" }
    }
}
