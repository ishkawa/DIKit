//
//  PropertyInjectableType.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation

struct PropertyInjectableType {
    let name: String
    let dependencyProperties: [Property]

    init?(type: Type) {
        guard
            type.inheritedTypeNames.contains("PropertyInjectable") ||
            type.inheritedTypeNames.contains("DIKit.PropertyInjectable") else {
            // Type is not declared as conformer of 'PropertyInjectableType'.
            return nil
        }

        guard let dependencyType = type.nestedTypes.filter({ $0.name == "Dependency" }).first else {
            // Associated type 'Dependency' declared in 'PropertyInjectableType' is not found.
            return nil
        }

        guard dependencyType.kind == .struct else {
            // Associated type 'Dependency' must be a struct.
            return nil
        }

        guard
            let property = type.properties.filter({ $0.name == "dependency" }).first,
            !property.isStatic && property.typeName == "Dependency!" else {
            // Instance property 'dependency' declared in 'PropertyInjectable' is not found.
            return nil
        }

        name = type.name
        dependencyProperties = dependencyType.properties.filter { !$0.isStatic }
    }
}
