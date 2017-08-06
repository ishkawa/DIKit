//
//  Function.swift
//  DIKit
//
//  Created by ishkawa on 2018/08/07.
//
//

struct Graph {
    enum Error: Swift.Error {
        case dependencyTypeNotFound
        case unresolvableGraph
        case injectableInitializerNotFound
    }

    let resolvedNodes: [Node]
    
    init(injectables: [Type], providables: [Type]) throws {
        struct Backlog {
            let injectable: Type
            let dependencyNames: [String]
        }

        var nodes = providables
            .map { providable -> Node in
                let provider = Function(providableTypeName: providable.name)
                return Node(type: providable, dependencies: [], provider: provider)
            }

        var backlogs = try injectables
            .map { injectable -> Backlog in
                let nestedTypes = injectable.structure.substructures.flatMap(Type.init)
                guard let dependencyType = nestedTypes.filter({ $0.name == "Dependency" }).first else {
                    throw Error.dependencyTypeNotFound
                }

                return Backlog(
                    injectable: injectable,
                    dependencyNames: dependencyType.properties.map { $0.typeName })
            }

        resolve: while !backlogs.isEmpty {
            for (index, backlog) in backlogs.enumerated() {
                let resolvedDependencies = backlog.dependencyNames
                    .flatMap { dependencyName -> Node? in
                        return nodes
                            .index { $0.type.name == dependencyName }
                            .map { nodes[$0] }
                    }

                if backlog.dependencyNames.count == resolvedDependencies.count {
                    let matchedProvider = backlog.injectable.functions
                        .filter { $0.isInitializer }
                        .filter { $0.parameters.count == 1 && $0.parameters[0].name == "dependency" && $0.parameters[0].typeName == "Dependency" }
                        .first

                    guard let provider = matchedProvider else {
                        throw Error.injectableInitializerNotFound
                    }
                    
                    let node = Node(
                        type: backlog.injectable,
                        dependencies: resolvedDependencies,
                        provider: provider)

                    nodes.append(node)
                    backlogs.remove(at: index)
                    continue resolve
                }
            }

            throw Error.unresolvableGraph
        }

        resolvedNodes = nodes
    }

    func generateCode() -> Code {
        var code = Code()

        do {
            code.append("protocol Resolver {")
            code.incrementIndentDepth()
            defer {
                code.decrementIndentDepth()
                code.append("}")
            }

            for node in resolvedNodes where !node.provider.isInitializer && node.provider.isStatic {
                code.append("func \(node.provider.name)() -> \(node.provider.returnTypeName)")
            }
        }

        code.append("")
        
        do {
            code.append("extension Resolver {")
            code.incrementIndentDepth()
            defer {
                code.decrementIndentDepth()
                code.append("}")
            }

            for (index, node) in resolvedNodes.enumerated() where node.type.isInjectable {
                code.append("func make\(node.type.name)() -> \(node.type.name) {")
                code.incrementIndentDepth()
                defer {
                    code.decrementIndentDepth()
                    code.append("}")
                    
                    if index != resolvedNodes.indices.last {
                        code.append("")
                    }
                }

                let returnNode = node
                var instantiatedNodes = [] as [Node]
                func appendDependencyInstantiation(of node: Node) {
                    node.dependencies.forEach(appendDependencyInstantiation(of:))

                    if !instantiatedNodes.contains(where: { $0.type.name == node.type.name }) {
                        instantiatedNodes.append(node)

                        let variable = node.type.name.firstCharacterLowerCased
                        let parameters = node.dependencies
                            .map { "\($0.type.name.firstCharacterLowerCased): \($0.type.name.firstCharacterLowerCased)" }
                            .joined(separator: ", ")

                        if node.type.name == returnNode.type.name {
                            code.append("return \(node.type.name)(dependency: .init(\(parameters)))")
                        } else if node.type.isInjectable {
                            code.append("let \(variable) = \(node.type.name)(dependency: .init(\(parameters)))")
                        } else {
                            code.append("let \(variable) = \(node.provider.name)(\(parameters))")
                        }
                    }
                }

                appendDependencyInstantiation(of: node)
            }
        }

        return code
    }
}
