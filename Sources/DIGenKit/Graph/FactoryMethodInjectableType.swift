//
//  FactoryMethodInjectableType.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation

struct FactoryMethodInjectableType {
    let name: String
    let dependencyProperties: [Property]

    init?(type: Type) {
        guard
            type.inheritedTypeNames.contains("FactoryMethodInjectable") ||
            type.inheritedTypeNames.contains("DIKit.FactoryMethodInjectable") else {
            // Type is not declared as conformer of 'FactoryMethodInjectable'.
            return nil
        }

        guard let dependencyType = type.nestedTypes.filter({ $0.name == "Dependency" }).first else {
            // Associated type 'Dependency' declared in 'FactoryMethodInjectable' is not found.
            return nil
        }

        guard dependencyType.kind == .struct else {
            // Associated type 'Dependency' must be a struct.
            return nil
        }

        guard
            let factoryMethod = type.methods.filter({ $0.name == "makeInstance(dependency:)" }).first, factoryMethod.isStatic,
            let parameter = factoryMethod.parameters.first, parameter.typeName == "Dependency" else {
            // Static factory method 'makeInstance(dependency:)' declared in 'FactoryMethodInjectable' is not found.
            return nil
        }

        name = type.name
        dependencyProperties = dependencyType.properties.filter { !$0.isStatic }
    }
}
