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

    private let initializer: Function?

    init(name: String, typeName: String, accessControl: AccessControl, injectables: [Type]) throws {
        guard let type = injectables.filter({ $0.name == typeName }).first else {
            throw GraphError(message: "Injectable type named \(typeName) is not found.")
        }

        if type.isInjectable {
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

            self.dependencies = dependencies
            self.initializer = initializer
        } else {
            self.dependencies = []
            self.initializer = nil
        }

        self.name = name
        self.type = type
        self.accessControl = accessControl
    }

    func generateInstatiationCode(withResolvedNodes resolvedNodes: [Node]) -> Code {
        guard let initializer = initializer else {
            return Code(content: "\(name) = FIXME", indentDepth: 0)
        }
        
        let parameters = initializer.parameters
            .map { parameter -> String in
                guard let node = resolvedNodes.filter({ $0.type.name == parameter.typeName }).first else {
                    fatalError("TODO: throw error")
                }
                return "\(parameter.name): \(node.name)"
            }
            .joined(separator: ", ")

        return Code(content: "\(name) = \(type.name)(\(parameters))", indentDepth: 0)
    }
}
