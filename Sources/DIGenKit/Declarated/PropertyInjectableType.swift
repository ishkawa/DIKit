//
//  PropertyInjectableType.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation
import SourceKittenFramework

struct PropertyInjectableType {
    struct Error: LocalizedError, Findable {
        enum Reason {
            case protocolConformanceNotFound
            case associatedTypeNotFound
            case propertyNotFound
            case nonStructAssociatedType
        }

        let type: Type
        let reason: Reason

        var file: File {
            return type.file
        }

        var offset: Int64 {
            return type.offset
        }

        var errorDescription: String? {
            switch reason {
            case .protocolConformanceNotFound:
                return "Type is not declared as conformer of 'PropertyInjectableType'"
            case .associatedTypeNotFound:
                return "Associated type 'Dependency' declared in 'PropertyInjectableType' is not found"
            case .propertyNotFound:
                return "Instance property 'dependency' declared in 'PropertyInjectable' is not found"
            case .nonStructAssociatedType:
                return "Associated type 'Dependency' must be a struct"
            }
        }
    }

    let name: String
    let dependencyProperties: [Property]

    init(type: Type) throws {
        guard
            type.inheritedTypeNames.contains("PropertyInjectable") ||
            type.inheritedTypeNames.contains("DIKit.PropertyInjectable") else {
            throw Error(type: type, reason: .protocolConformanceNotFound)
        }

        guard let dependencyType = type.nestedTypes.first(where: { $0.name == "Dependency" }) else {
            throw Error(type: type, reason: .associatedTypeNotFound)
        }

        guard dependencyType.kind == .struct else {
            throw Error(type: type, reason: .nonStructAssociatedType)
        }

        guard
            let property = type.properties.first(where: { $0.name == "dependency" }),
            !property.isStatic && property.typeName == "Dependency!" else {
            throw Error(type: type, reason: .propertyNotFound)
        }

        name = type.name
        dependencyProperties = dependencyType.properties.filter { !$0.isStatic }
    }
}
