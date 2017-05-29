//
//  Node.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation

struct Node {
    enum AccessControl {
        case `private`
        case `public`
    }
    
    let name: String
    let type: Type
    let accessControl: AccessControl
    let dependencies: [Node]

    private let initializer: Function

    init(name: String, typeName: String, accessControl: AccessControl, injectables: [Type]) throws {
        guard let type = injectables.filter({ $0.name == typeName }).first else {
            throw GraphError(message: "Injectable type named \(typeName) is not found.")
        }

        let initializers = type.functions.filter({ $0.isInitializer })
        guard initializers.count == 1, let initializer = initializers.first else {
            throw GraphError(message: "Number of initializer of injectable type must be 1.")
        }

        var dependencies: [Node] = []
        for parameter in initializer.parameters {
            guard let type = injectables.filter({ $0.name == parameter.typeName}).first else {
                throw GraphError(message: "Injectable type named \(parameter.typeName) is not found.")
            }

            let node = try Node(
                name: type.name.firstCharacterLowerCased,
                typeName: type.name,
                accessControl: .private,
                injectables: injectables)
            
            dependencies.append(node)
        }

        self.name = name
        self.type = type
        self.accessControl = accessControl
        self.dependencies = dependencies
        self.initializer = initializer
    }

    func generateInstatiation(withResolvedNodes resolvedNodes: [Node]) -> String {
        let parameters = initializer.parameters
            .map { parameter -> String in
                guard let node = resolvedNodes.filter({ $0.type.name == parameter.typeName }).first else {
                    fatalError("TODO: throw error")
                }
                return "\(parameter.name): \(node.name)"
            }
            .joined(separator: ", ")
        
        return "\(name) = \(type.name)(\(parameters))"
    }
}
