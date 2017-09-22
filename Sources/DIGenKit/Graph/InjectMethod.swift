//
//  InjectMethod.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation

struct InjectMethod {
    struct Parameter {
        let name: String
        let typeName: String
    }

    let name: String
    let returnTypeName: String
    let parameters: [Parameter]

    let bodyLines: [String]
    let parametersDeclaration: String

    init?(node: Node) {
        let dependencyInstantiation = node.shallowDependencyNodes
            .map { node in
                let parameters = node.deepDependencyParameters
                    .map { "\($0.name): \($0.name)" }
                    .joined(separator: ", ")

                return "let \(node.declaration.typeName.firstWordLowercased) = resolve\(node.declaration.typeName)(\(parameters))"
            }
            .joined(separator: "\n")

        let selfInjection: String = {
            let parameters = node.dependencies
                .map { dependency in
                    switch dependency {
                    case .node(let name, let node):
                        return "\(name): \(node.declaration.typeName.firstWordLowercased)"
                    case .parameter(let parameter):
                        return "\(parameter.name): \(parameter.name)"
                    }
                }
                .joined(separator: ", ")

            switch node.declaration {
            case .propertyInjectableType:
                return "\(node.declaration.typeName.firstWordLowercased).dependency = \(node.declaration.typeName).Dependency(\(parameters))"
            default:
                fatalError("\(node.declaration) node can't be resolved by inject method")
            }
        }()

        bodyLines = [dependencyInstantiation, selfInjection]
            .joined(separator: "\n")
            .components(separatedBy: CharacterSet.newlines)
            .filter { !$0.isEmpty }

        name = "injectTo" + node.declaration.typeName
        returnTypeName = "Void"

        let targetParameter = Parameter(
            name: "_ \(node.declaration.typeName.firstWordLowercased)",
            typeName: node.declaration.typeName)

        parameters = [targetParameter] + node.deepDependencyParameters.map { Parameter(name: $0.name, typeName: $0.typeName) }
        parametersDeclaration = parameters
            .map { "\($0.name): \($0.typeName)" }
            .joined(separator: ", ")
    }
}
