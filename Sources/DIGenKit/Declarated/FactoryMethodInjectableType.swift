//
//  FactoryMethodInjectableType.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation

struct FactoryMethodInjectableType {
    struct Error: Swift.Error {
        enum Reason {
            case protocolConformanceNotFound
            case associatedTypeNotFound
            case factoryMethodNotFound
            case nonStructAssociatedType
        }

        let type: Type
        let reason: Reason

        var localizedDescription: String {
            switch reason {
            case .protocolConformanceNotFound:
                return "Type is not declared as conformer of 'FactoryMethodInjectable'"
            case .associatedTypeNotFound:
                return "Associated type 'Dependency' declared in 'FactoryMethodInjectable' is not found"
            case .factoryMethodNotFound:
                return "Static factory method 'makeInstance(dependency:)' declared in 'FactoryMethodInjectable' is not found"
            case .nonStructAssociatedType:
                return "Associated type 'Dependency' must be a struct"
            }
        }
    }

    let name: String
    let dependencyProperties: [Property]

    init(type: Type) throws {
        guard
            type.inheritedTypeNames.contains("FactoryMethodInjectable") ||
            type.inheritedTypeNames.contains("DIKit.FactoryMethodInjectable") else {
            throw Error(type: type, reason: .protocolConformanceNotFound)
        }

        guard let dependencyType = type.nestedTypes.filter({ $0.name == "Dependency" }).first else {
            throw Error(type: type, reason: .associatedTypeNotFound)
        }

        guard dependencyType.kind == .struct else {
            throw Error(type: type, reason: .nonStructAssociatedType)
        }

        guard
            let factoryMethod = type.methods.filter({ $0.name == "makeInstance(dependency:)" }).first, factoryMethod.isStatic,
            let parameter = factoryMethod.parameters.first, parameter.typeName == "Dependency" || parameter.typeName == "\(type.name).Dependency" else {
            throw Error(type: type, reason: .factoryMethodNotFound)
        }

        name = type.name
        dependencyProperties = dependencyType.properties.filter { !$0.isStatic }
    }
}
