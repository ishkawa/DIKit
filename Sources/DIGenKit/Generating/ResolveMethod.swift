//
//  ResolveMethod.swift
//  dikitgen
//
//  Created by Yosuke Ishikawa on 2017/09/16.
//

import Foundation

struct ResolveMethod {
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

        let selfInstantiation: String = {
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
            case .initializerInjectableType(let type):
                return "return \(type.name)(dependency: .init(\(parameters)))"
            case .factoryMethodInjectableType(let type):
                return "return \(type.name).makeInstance(dependency: .init(\(parameters)))"
            case .propertyInjectableType:
                fatalError("propertyInjectableType node can't be resolved by resolve method")
            case .providerMethod(let method):
                return "return \(method.nameWithoutParameters)(\(parameters))"
            }
        }()

        bodyLines = [dependencyInstantiation, selfInstantiation]
            .joined(separator: "\n")
            .components(separatedBy: CharacterSet.newlines)
            .filter { !$0.isEmpty }

        returnTypeName = node.declaration.typeName
        name = "resolve" + node.declaration.typeName

        parameters = node.deepDependencyParameters.map { Parameter(name: $0.name, typeName: $0.typeName) }
        parametersDeclaration = parameters
            .map { "\($0.name): \($0.typeName)" }
            .joined(separator: ", ")
    }
}
