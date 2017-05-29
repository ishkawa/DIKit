//
//  Node.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation

struct Node {
    let type: Type
    let dependencies: [Node]

    init(name: String, injectables: [Type]) throws {
        guard let type = injectables.filter({ $0.name == name }).first else {
            throw GraphError(message: "Injectable type named \(name) is not found.")
        }

        let initializerParameters = Array(type.functions
            .filter { $0.isInitializer }
            .map { $0.parameters }
            .joined())

        var dependencies: [Node] = []
        for parameter in initializerParameters {
            guard let type = injectables.filter({ $0.name == parameter.typeName}).first else {
                throw GraphError(message: "Injectable type named \(name) is not found.")
            }

            let node = try Node(name: type.name, injectables: injectables)
            dependencies.append(node)
        }

        self.type = type
        self.dependencies = dependencies
    }
}
