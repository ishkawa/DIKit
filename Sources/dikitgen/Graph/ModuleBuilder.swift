//
//  ModuleBuilder.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation

struct ModuleBuiler {
    let blueprint: Type
    let nodes: [Node]
    let moduleName: String

    init(blueprint: Type, injectables: [Type]) throws {
        let suffix = "Blueprint"
        guard blueprint.name.hasSuffix(suffix) else {
            throw GraphError(message: "Blueprint type must have suffix \(suffix).")
        }

        self.moduleName = blueprint.name.trimmingSuffix("Blueprint")
        self.blueprint = blueprint

        var nodes = try blueprint.properties
            .map { property -> Node in
                return try Node(
                    name: property.name,
                    typeName: property.typeName,
                    accessControl: .public,
                    injectables: injectables)
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

        self.nodes = nodes
    }

    func build() -> String {
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

                code.append("")
            }
        }

        return code.content
    }
}
