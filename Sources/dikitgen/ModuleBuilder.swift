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

    init(blueprint: Type, injectables: [Type]) throws {
        let suffix = "Blueprint"
        guard blueprint.name.hasSuffix(suffix) else {
            throw GraphError(message: "Blueprint type must have suffix \(suffix).")
        }

        self.moduleName = {
            let name = blueprint.name
            return name[name.startIndex..<name.index(name.endIndex, offsetBy: -suffix.characters.count)]
        }()

        self.nodes = try blueprint.properties.map { try Node(name: $0.typeName, injectables: injectables) }

        let publicProperties = blueprint.properties
        var privateProperties = [Property]()
        func extractNode(node: Node) {
            node.dependencies.forEach(extractNode(node:))

            let resolvedTypeNames = publicProperties.map { $0.typeName } + privateProperties.map { $0.typeName }

            if !resolvedTypeNames.contains(node.type.name) {
                var name = node.type.name
                name = name.replacingCharacters(
                    in: name.startIndex..<name.index(name.startIndex, offsetBy: 1),
                    with: String(name[name.startIndex]).lowercased())

                let property = Property(name: name, typeName: node.type.name)
                privateProperties.append(property)
            }
        }

        self.nodes.forEach { extractNode(node: $0) }
        self.publicProperties = publicProperties
        self.privateProperties = privateProperties
    }
}
