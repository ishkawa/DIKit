//
//  ModuleBuilder.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation

struct ModuleBuiler {
    let moduleName: String
    let nodes: [Node]
    let publicProperties: [Property]
    let privateProperties: [Property]

    let blueprint: Type

    init(blueprint: Type, injectables: [Type]) throws {
        let suffix = "Blueprint"
        guard blueprint.name.hasSuffix(suffix) else {
            throw GraphError(message: "Blueprint type must have suffix \(suffix).")
        }

        self.moduleName = {
            let name = blueprint.name
            return name[name.startIndex..<name.index(name.endIndex, offsetBy: -suffix.characters.count)]
        }()

        self.nodes = try blueprint.properties.map { try Node(name: $0.name, typeName: $0.typeName, injectables: injectables) }

        let publicProperties = blueprint.properties
        var privateProperties = [Property]()
        func extractNode(node: Node) {
            node.dependencies.forEach(extractNode(node:))

            let resolvedTypeNames = publicProperties.map { $0.typeName } + privateProperties.map { $0.typeName }

            if !resolvedTypeNames.contains(node.type.name) {
                let property = Property(name: node.name, typeName: node.type.name)
                privateProperties.append(property)
            }
        }

        self.nodes.forEach { extractNode(node: $0) }
        self.publicProperties = publicProperties
        self.privateProperties = privateProperties
        self.blueprint = blueprint
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
            
            code.append(publicProperties.map({ "let \($0.name): \($0.typeName)" }).joined())
            code.append("")
            code.append(privateProperties.map({ "private let \($0.name): \($0.typeName)" }).joined())
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
