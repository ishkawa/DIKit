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
            let dependencies: [Property]
        }

        var nodes = providables.map { Node.providable(type: $0) }
        var backlogs = try injectables
            .map { injectable -> Backlog in
                let nestedTypes = injectable.structure.substructures.flatMap(Type.init)
                guard let dependencyType = nestedTypes.filter({ $0.name == "Dependency" }).first else {
                    throw Error.dependencyTypeNotFound
                }

                return Backlog(injectable: injectable, dependencies: dependencyType.properties)
            }

        resolve: while !backlogs.isEmpty {
            for (index, backlog) in backlogs.enumerated() {
                let resolvedDependencies = backlog.dependencies
                    .reduce([] as [(Property, Node)]) { resolved, property in
                        if let index = nodes.index(where: { $0.type.name == property.typeName }) {
                            return resolved + [(property, nodes[index])]
                        } else {
                            return resolved
                        }
                    }

                if backlog.dependencies.count == resolvedDependencies.count {
                    let matchedInitializer = backlog.injectable.functions
                        .filter { $0.isInitializer }
                        .filter { $0.parameters.count == 1 && $0.parameters[0].name == "dependency" && $0.parameters[0].typeName == "Dependency" }
                        .first

                    guard let initializer = matchedInitializer else {
                        throw Error.injectableInitializerNotFound
                    }

                    let node = Node.injectable(
                        type: backlog.injectable,
                        dependencies: resolvedDependencies,
                        initializer: initializer)
                    
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
            code.append("extension Resolver {")
            code.incrementIndentDepth()
            defer {
                code.decrementIndentDepth()
                code.append("}")
            }

            for (index, node) in resolvedNodes.enumerated() {
                guard case .injectable(let type, let dependencies, let intializer) = node else {
                    continue
                }
                
                code.append("func make\(type.name)() -> \(type.name) {")
                code.incrementIndentDepth()
                defer {
                    code.decrementIndentDepth()
                    code.append("}")
                    
                    if index != resolvedNodes.indices.last {
                        code.append("")
                    }
                }

                let returnType = type
                var instantiatedNodes = [] as [Node]
                func appendDependencyInstantiation(of node: Node) {
                    if case .injectable(_, let dependencies, _) = node {
                        dependencies
                            .map { $1 }
                            .forEach(appendDependencyInstantiation(of:))
                    }

                    if !instantiatedNodes.contains(where: { $0.type.name == node.type.name }) {
                        instantiatedNodes.append(node)

                        let variable = node.type.name.firstCharacterLowerCased

                        switch node {
                        case .providable(let type):
                            code.append("let \(variable) = provide\(type.name)()")
                        case .injectable(let type, let dependencies, _):
                            let parameters = dependencies
                                .map { "\($0.name): \($1.type.name.firstCharacterLowerCased)" }
                                .joined(separator: ", ")

                            if type.name == returnType.name {
                                code.append("return \(node.type.name)(dependency: .init(\(parameters)))")
                            } else {
                                code.append("let \(variable) = \(node.type.name)(dependency: .init(\(parameters)))")
                            }
                        }
                    }
                }

                appendDependencyInstantiation(of: node)
            }
        }

        return code
    }
}
