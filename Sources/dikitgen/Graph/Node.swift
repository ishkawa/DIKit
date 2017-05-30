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

    private let provider: Function

    init(name: String, typeName: String, accessControl: AccessControl, providables: [Providable]) throws {
        guard let providable = providables.filter({ $0.type.name == typeName }).first else {
            throw GraphError(message: "Injectable type named \(typeName) is not found.")
        }

        var dependencies: [Node] = []
        for parameter in providable.provider.parameters {
            guard let providable = providables.filter({ $0.type.name == parameter.typeName}).first else {
                throw GraphError(message: "Injectable type named \(parameter.typeName) is not found.")
            }

            let node = try Node(
                name: providable.type.name.firstCharacterLowerCased,
                typeName: providable.type.name,
                accessControl: .private,
                providables: providables)
            
            dependencies.append(node)
        }

        self.name = name
        self.type = providable.type
        self.provider = providable.provider
        self.accessControl = accessControl
        self.dependencies = dependencies
    }

    func generateInstatiationCode(withResolvedNodes resolvedNodes: [Node], moduleName: String) -> Code {
        let parameters = provider.parameters
            .map { parameter -> String in
                guard let node = resolvedNodes.filter({ $0.type.name == parameter.typeName }).first else {
                    fatalError("TODO: throw error")
                }
                return "\(parameter.name): \(node.name)"
            }
            .joined(separator: ", ")

        if provider.isInitializer {
            return Code(content: "\(name) = \(type.name)(\(parameters))", indentDepth: 0)
        } else {
            let providerName = provider.name.replacingOccurrences(of: "()", with: "")
            return Code(content: "\(name) = \(moduleName).\(providerName)(\(parameters))", indentDepth: 0)
        }
    }
}
