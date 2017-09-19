//
//  Node.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

struct Node {
    enum Kind {
        case initializer
        case factoryMethod
        case providerMethod
    }

    struct Dependency {
        let name: String
        let typeName: String
    }

    let kind: Kind
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

        kind = .initializer
        typeName = injectableType.name
        dependencies = properties.map { Dependency(name: $0.name, typeName: $0.typeName) }
        instantiatingFunction = initializer
    }

    init?(factoryMethodInjectableType type: Type) {
        guard
            let factoryMethod = type.functions.filter({ $0.name == "makeInstance(dependency:)" }).first,
            factoryMethod.isStatic,
            type.inheritedTypeNames.contains("FactoryMethodInjectable") ||
            type.inheritedTypeNames.contains("DIKit.FactoryMethodInjectable") else {
            return nil
        }

        let properties = Array(type.nestedTypes
            .filter { $0.name == "Dependency" }
            .map { $0.properties.filter { !$0.isStatic } }
            .joined())

        kind = .factoryMethod
        typeName = type.name
        dependencies = properties.map { Dependency(name: $0.name, typeName: $0.typeName) }
        instantiatingFunction = factoryMethod
    }

    init?(providerMethod: Function) {
        guard
            providerMethod.name.hasPrefix("provide"),
            providerMethod.returnTypeName != "Void" else {
            return nil
        }

        kind = .providerMethod
        typeName = providerMethod.returnTypeName
        dependencies = providerMethod.parameters.map { Dependency(name: $0.name, typeName: $0.typeName) }
        instantiatingFunction = providerMethod
    }
}
