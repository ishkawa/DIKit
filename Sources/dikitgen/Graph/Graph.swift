//
//  Graph.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation

struct Providable {
    let type: Type
    let provider: Function

    init(type: Type, provider: Function) {
        self.type = type
        self.provider = provider
    }

    init(injectableType: Type) throws {
        guard injectableType.inheritedTypes.contains("Injectable") else {
            throw GraphError(message: "\(injectableType.name) does not conform to Injectable.")
        }

        let initializers = injectableType.functions.filter({ $0.isInitializer })
        guard initializers.count == 1, let initializer = initializers.first else {
            throw GraphError(message: "Number of initializer of injectable type must be 1.")
        }

        self.type = injectableType
        self.provider = initializer
    }
}

struct Graph {
    let blueprint: Type
    let blueprintExtension: Extension?
    let providables: [Providable]

    init(blueprint: Type, blueprintExtension: Extension?, types: [Type]) {
        self.blueprint = blueprint
        self.blueprintExtension = blueprintExtension

        // TODO: handle error
        let injectables = types
            .filter { $0.inheritedTypes.contains("Injectable") }
            .flatMap { try? Providable(injectableType: $0) }
        
        let providables = types
            .flatMap { type -> Providable? in
                return blueprintExtension?.functions
                    .filter { $0.kind == .functionMethodStatic }
                    .filter { $0.name.hasPrefix("provide") }
                    .filter { $0.returnTypeName == type.name }
                    .first
                    .map { Providable(type: type, provider: $0) }
            }

        self.providables = injectables + providables
    }

    private func buildModuleName() throws -> String {
        let suffix = "Blueprint"
        guard blueprint.name.hasSuffix(suffix) else {
            throw GraphError(message: "Blueprint type must have suffix \(suffix).")
        }

        return blueprint.name.trimmingSuffix("Blueprint")
    }

    private func buildNodes() throws -> [Node] {
        let unorderedUniqueNodes: [Node] = try {
            var nodes = try blueprint.properties
                .map { property -> Node in
                    return try Node(
                        name: property.name,
                        typeName: property.typeName,
                        accessControl: .public,
                        providables: providables)
                }

            func appendDependencies(of node: Node) {
                node.dependencies.forEach { node in
                    let typeNames = nodes.map { $0.type.name }
                    if !typeNames.contains(node.type.name) {
                        nodes.append(node)
                    }
                    appendDependencies(of: node)
                }
            }

            nodes.forEach(appendDependencies(of:))

            return nodes
        }()

        let orderedUniqueNodes: [Node] = try {
            var resolvedNodes = [] as [Node]
            while resolvedNodes.count < unorderedUniqueNodes.count {
                var resolved = false
                for node in unorderedUniqueNodes {
                    let resolvedTypeNames = resolvedNodes.map { $0.type.name }
                    guard !resolvedTypeNames.contains(node.type.name) else {
                        continue
                    }
                    
                    let isResolvable = node.dependencies
                        .reduce(true) { $0 && resolvedTypeNames.contains($1.type.name) }

                    if isResolvable {
                        resolvedNodes.append(node)
                        resolved = true
                        break
                    }
                }

                if !resolved {
                    throw GraphError(message: "Could not resolve dependencies.")
                }
            }

            return resolvedNodes
        }()

        return orderedUniqueNodes
    }

    func generateCode() throws -> Code {
        let moduleName = try buildModuleName()
        let nodes = try buildNodes()

        var code = Code()

        do {
            code.append("final class \(moduleName): \(blueprint.name) {")
            code.incrementIndentDepth()
            defer {
                code.decrementIndentDepth()
                code.append("}")
            }

            let publicPropertyDeclarations = nodes
                .filter { $0.accessControl == .public }
                .map { "let \($0.name): \($0.type.name)" }

            let privatePropertyDeclarations = nodes
                .filter { $0.accessControl == .private }
                .map { "private let \($0.name): \($0.type.name)" }
            
            code.append(publicPropertyDeclarations.joined(separator: "\n"))
            code.append("")
            code.append(privatePropertyDeclarations.joined(separator: "\n"))
            code.append("")

            do {
                code.append("init() {")
                code.incrementIndentDepth()
                defer {
                    code.decrementIndentDepth()
                    code.append("}")
                }

                for node in nodes {
                    code.append(node.generateInstatiationCode(withResolvedNodes: nodes, moduleName: moduleName).content)
                }
            }
        }

        return code
    }
}
