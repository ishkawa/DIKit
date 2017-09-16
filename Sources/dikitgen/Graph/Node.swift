//
//  Node.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

struct Node {
    struct Dependency {
        let name: String
        let typeName: String
    }

    let typeName: String
    let dependencies: [Dependency]
    let instantiatingFunction: Function

    init?(injectableType: Type) {
        guard
            let initializer = injectableType.functions.filter({ $0.name == "init(dependency:)" }).first,
            injectableType.inheritedTypeNames.contains("Injectable") ||
            injectableType.inheritedTypeNames.contains("DIKit.Injectable") else {
            return nil
        }

        let properties = Array(injectableType.nestedTypes
            .filter { $0.name == "Dependency" }
            .map { $0.properties.filter { !$0.isStatic } }
            .joined())

        typeName = injectableType.name
        dependencies = properties.map { Dependency(name: $0.name, typeName: $0.typeName) }
        instantiatingFunction = initializer
    }

    init?(providerMethod: Function) {
        guard
            providerMethod.name.hasPrefix("provide"),
            providerMethod.returnTypeName != "Void" else {
            return nil
        }

        typeName = providerMethod.returnTypeName
        dependencies = providerMethod.parameters.map { Dependency(name: $0.name, typeName: $0.typeName) }
        instantiatingFunction = providerMethod
    }
}
