//
//  Node.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

struct Node {
    struct Identifier {
        let name: String?
        let typeName: String
    }

    let identifier: Identifier
    let dependencyIdentifiers: [Identifier]

    init?(injectableType: Type) {
        guard
            injectableType.inheritedTypeNames.contains("Injectable") ||
            injectableType.inheritedTypeNames.contains("DIKit.Injectable") else {
            return nil
        }

        let properties = Array(injectableType.nestedTypes
            .filter { $0.name == "Dependency" }
            .map { $0.properties.filter { !$0.isStatic } }
            .joined())

        identifier = Identifier(name: nil, typeName: injectableType.name)
        dependencyIdentifiers = properties.map { Identifier(name: $0.name, typeName: $0.typeName) }
    }

    init?(providerMethod: Function) {
        guard
            providerMethod.name.hasPrefix("provide"),
            providerMethod.returnTypeName != "Void" else {
            return nil
        }

        identifier = Identifier(
            name: providerMethod.name.replacingOccurrences(of: "provide", with: "").firstWordLowercased,
            typeName: providerMethod.returnTypeName)

        dependencyIdentifiers = providerMethod.parameters
            .map { Identifier(name: $0.name, typeName: $0.typeName) }
    }
}
