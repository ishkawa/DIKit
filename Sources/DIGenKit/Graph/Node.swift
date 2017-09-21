//
//  Node.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

enum Node {
    case initializerInjectableType(InitializerInjectableType)
    case factoryMethodInjectableType(FactoryMethodInjectableType)
    case providerMethod(ProviderMethod)

    struct Dependency {
        let name: String
        let typeName: String
    }

    var typeName: String {
        switch self {
        case .initializerInjectableType(let type):
            return type.name
        case .factoryMethodInjectableType(let type):
            return type.name
        case .providerMethod(let method):
            return method.returnTypeName
        }
    }

    var dependencies: [Dependency] {
        switch self {
        case .initializerInjectableType(let type):
            return type.dependencyProperties.map { Dependency(name: $0.name, typeName: $0.typeName) }
        case .factoryMethodInjectableType(let type):
            return type.dependencyProperties.map { Dependency(name: $0.name, typeName: $0.typeName) }
        case .providerMethod(let method):
            return method.parameters.map { Dependency(name: $0.name, typeName: $0.typeName) }
        }
    }
}
