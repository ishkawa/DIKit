//
//  FactoryMethod.swift
//  dikitgen
//
//  Created by Yosuke Ishikawa on 2017/09/16.
//

import Foundation

struct FactoryMethod {
    struct Parameter {
        let name: String
        let typeName: String
    }

    let name: String
    let returnTypeName: String
    let parameters: [Parameter]

    let bodyLines: [String]
    let parametersDeclaration: String

    init?(node: Node, allNodes: [Node], factoryMethods: [FactoryMethod]) {
        let resolvedFactoryMethods = node.dependencies
            .flatMap { dependency in
                return factoryMethods
                    .filter { $0.returnTypeName == dependency.typeName }
                    .first
            }

        let nodeTypeNames = allNodes.map { $0.typeName }
        let nonInjectableDependencies = node.dependencies
            .flatMap { nodeTypeNames.contains($0.typeName) ? nil : $0 }

        guard (resolvedFactoryMethods.count + nonInjectableDependencies.count) == node.dependencies.count else {
            return nil
        }

        let dependencyInstantiation = resolvedFactoryMethods
            .map { factoryMethod in
                let parameters = factoryMethod.parameters
                    .map { "\($0.name): \($0.name)" }
                    .joined(separator: ", ")

                return "let \(factoryMethod.returnTypeName.firstWordLowercased) = \(factoryMethod.name)(\(parameters))"
            }
            .joined(separator: "\n")

        let selfInstantiationParameters = node.dependencies
            .map { dependency in
                return nonInjectableDependencies.contains(where: { $0.typeName == dependency.typeName })
                    ? "\(dependency.name): \(dependency.name)"
                    : "\(dependency.name): \(dependency.typeName.firstWordLowercased)"
            }
            .joined(separator: ", ")

        let functionName = node.instantiatingFunction.nameWithoutParameters
        let selfInstantiationCode: String
        if functionName == "init" {
            selfInstantiationCode = "return \(node.typeName)(dependency: .init(\(selfInstantiationParameters)))"
        } else {
            selfInstantiationCode = "return \(functionName)(\(selfInstantiationParameters))"
        }

        bodyLines = [dependencyInstantiation, selfInstantiationCode]
            .joined(separator: "\n")
            .components(separatedBy: CharacterSet.newlines)
            .filter { !$0.isEmpty }

        returnTypeName = node.typeName
        name = "resolve" + node.typeName

        let selfParameters = nonInjectableDependencies.map { Parameter(name: $0.name, typeName: $0.typeName) }
        let inheritedParameters = Array(factoryMethods
            .map { $0.parameters }
            .joined())
            .filter { parameter in node.dependencies.contains(where: { $0.typeName == parameter.typeName }) }

        parameters = selfParameters + inheritedParameters
        parametersDeclaration = parameters
            .map { "\($0.name): \($0.typeName)" }
            .joined(separator: ", ")
    }
}
