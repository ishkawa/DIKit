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

    init(name: String, typeName: String, accessControl: AccessControl, injectables: [Type]) throws {
        guard let type = injectables.filter({ $0.name == typeName }).first else {
            throw GraphError(message: "Injectable type named \(typeName) is not found.")
        }

        let initializerParameters = Array(type.functions
            .filter { $0.isInitializer }
            .map { $0.parameters }
            .joined())

        var dependencies: [Node] = []
        for parameter in initializerParameters {
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
    }
}
