//
//  InitializerInjectableType.swift
//  DIGenKitTests
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation

struct InitializerInjectableType {
    let name: String
    let dependencyProperties: [Property]

    init?(type: Type) {
        guard
            type.inheritedTypeNames.contains("Injectable") ||
            type.inheritedTypeNames.contains("DIKit.Injectable") else {
            // Type is not declared as conformer of Injectable.
            return nil
        }

        guard let dependencyType = type.nestedTypes.filter({ $0.name == "Dependency" }).first else {
            // Associated type 'Dependency' declared in 'Injectable' is not found.
            return nil
        }

        guard dependencyType.kind == .struct else {
            // Associated type 'Dependency' must be a struct.
            return nil
        }

        guard
            let initializer = type.methods.filter({ $0.name == "init(dependency:)" }).first,
            let parameter = initializer.parameters.first, parameter.typeName == "Dependency" else {
            // Initializer 'init(dependency:)' declared in 'Injectable' is not found.
            return nil
        }

        name = type.name
        dependencyProperties = dependencyType.properties.filter { !$0.isStatic }
    }
}
