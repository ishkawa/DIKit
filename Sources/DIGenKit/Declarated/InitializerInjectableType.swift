//
//  InitializerInjectableType.swift
//  DIGenKitTests
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation
import SourceKittenFramework

struct InitializerInjectableType {
    struct Error: LocalizedError, Findable {
        enum Reason {
            case protocolConformanceNotFound
            case associatedTypeNotFound
            case initializerNotFound
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
                return "Type is not declared as conformer of 'Injectable'"
            case .associatedTypeNotFound:
                return "Associated type 'Dependency' declared in 'Injectable' is not found"
            case .initializerNotFound:
                return "Initializer 'init(dependency:)' declared in 'Injectable' is not found"
            case .nonStructAssociatedType:
                return "Associated type 'Dependency' must be a struct"
            }
        }
    }

    let name: String
    let dependencyProperties: [Property]

    init(type: Type) throws {
        guard
            type.inheritedTypeNames.contains("Injectable") ||
            type.inheritedTypeNames.contains("DIKit.Injectable") else {
            throw Error(type: type, reason: .protocolConformanceNotFound)
        }

        guard let dependencyType = type.nestedTypes.first(where: { $0.name == "Dependency" }) else {
            throw Error(type: type, reason: .associatedTypeNotFound)
        }

        guard dependencyType.kind == .struct else {
            throw Error(type: type, reason: .nonStructAssociatedType)
        }

        guard
            let initializer = type.methods.first(where: { $0.name == "init(dependency:)" }),
            let parameter = initializer.parameters.first, parameter.typeName == "Dependency" else {
            throw Error(type: type, reason: .initializerNotFound)
        }

        name = type.name
        dependencyProperties = dependencyType.properties.filter { !$0.isStatic }
    }
}
