//
//  Node.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

struct Node {
    enum Declaration {
        case initializerInjectableType(InitializerInjectableType)
        case factoryMethodInjectableType(FactoryMethodInjectableType)
        case propertyInjectableType(PropertyInjectableType)
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
            case .propertyInjectableType(let type):
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
            case .propertyInjectableType(let type):
                return type.dependencyProperties.map { Dependency(name: $0.name, typeName: $0.typeName) }
            case .providerMethod(let method):
                return method.parameters.map { Dependency(name: $0.name, typeName: $0.typeName) }
            }
        }
    }

    struct Parameter {
        let name: String
        let typeName: String
    }

    enum Dependency {
        case node(name: String, node: Node)
        case parameter(Parameter)
    }

    let declaration: Declaration
    let dependencies: [Dependency]

    init?(declaration: Declaration, allDeclarations: [Declaration], availableNodes: [Node]) {
        self.declaration = declaration
        self.dependencies = declaration.dependencies
            .compactMap { dependency -> Dependency? in
                let declarationTypeNames = allDeclarations.map { $0.typeName }
                if let resolvableNode = availableNodes.first(where: { $0.declaration.typeName == dependency.typeName }) {
                    return .node(name: dependency.name, node: resolvableNode)
                } else if !declarationTypeNames.contains(dependency.typeName) {
                    return .parameter(Parameter(name: dependency.name, typeName: dependency.typeName))
                } else {
                    return nil
                }
            }

        if dependencies.count != declaration.dependencies.count {
            // Could not fulfill all dependencies
            return nil
        }
    }

    var shallowDependencyNodes: [Node] {
        return dependencies
            .compactMap { dependency -> Node? in
                if case .node(_, let node) = dependency {
                    return node
                } else {
                    return nil
                }
            }
    }

    var deepDependencyParameters: [Parameter] {
        return Node.recursiveDependencyParameters(of: self)
    }

    static func recursiveDependencyParameters(of node: Node) -> [Parameter] {
        let dependencyNodes = node.dependencies
            .compactMap { dependency -> Node? in
                if case .node(_, let node) = dependency {
                    return node
                } else {
                    return nil
                }
            }

        let dependencyParameter = node.dependencies
            .compactMap { dependency -> Parameter? in
                if case .parameter(let parameter) = dependency {
                    return parameter
                } else {
                    return nil
                }
            }

        let inheritedParameters = Array(dependencyNodes.map({ Node.recursiveDependencyParameters(of: $0) }).joined())

        return dependencyParameter + inheritedParameters
    }
}
