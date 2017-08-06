//
//  Function.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation
import SourceKittenFramework

struct Function {
    private static var declarationKinds: [SwiftDeclarationKind] {
        return [.functionMethodInstance, .functionMethodStatic]
    }

    struct Parameter {
        let name: String
        let typeName: String

        init?(structure: Structure) {
            guard structure.kind == .varParameter,
                let name = structure.name,
                let type = structure.typeName else {
                return nil
            }

            self.name = name
            self.typeName = type
        }
    }

    let name: String
    let kind: SwiftDeclarationKind
    let parameters: [Parameter]
    let returnTypeName: String

    var isInitializer: Bool {
        return name.hasPrefix("init(")
    }

    var isStatic: Bool {
        return kind == .functionMethodStatic
    }

    init?(structure: Structure) {
        guard
            let kind = structure.kind, Function.declarationKinds.contains(kind),
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.kind = kind
        self.parameters = structure.substructures.flatMap(Parameter.init)
        self.returnTypeName = structure.substructures
            .flatMap { structure -> String? in
                guard structure.dictionary["key.kind"] as? String == "source.lang.swift.expr.call" else {
                    return nil
                }
                return structure.name
            }
            .first ?? "Void"
    }
    
    init(providableTypeName: String) {
        name = "provide\(providableTypeName)"
        kind = .functionMethodStatic
        parameters = []
        returnTypeName = providableTypeName
    }
}
