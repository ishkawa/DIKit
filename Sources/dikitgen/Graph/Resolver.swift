//
//  Resolver.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

import Foundation

struct Resolver {
    let name: String
    let factoryMethods: [FactoryMethod]

    init?(type: Type, injectableTypeNodes: [Node]) {
        guard 
            type.inheritedTypeNames.contains("Resolver") ||
            type.inheritedTypeNames.contains("DIKit.Resolver") else {
            return nil
        }

        var unresolvedNodes = injectableTypeNodes + type.functions.flatMap(Node.init(providerMethod:))
        var resolvedFactoryMethods = [] as [FactoryMethod]

        while !unresolvedNodes.isEmpty {
            var resolved = false
            for (index, unresolvedNode) in unresolvedNodes.enumerated() {
                guard let factoryMethod = FactoryMethod(node: unresolvedNode, factoryMethods: resolvedFactoryMethods) else {
                    continue
                }

                unresolvedNodes.remove(at: index)
                resolvedFactoryMethods.append(factoryMethod)
                resolved = true
                break
            }

            if !resolved {
                // TODO: Throw error
                return nil
            }
        }

        name = type.name
        factoryMethods = resolvedFactoryMethods
    }

    struct FactoryMethod {
        let name: String
        let returnTypeName: String
        let bodyLines: [String]

        init?(node: Node, factoryMethods: [FactoryMethod]) {
            let resolvedFactoryMethods = node.dependencies
                .flatMap { dependency in
                    return factoryMethods
                        .filter { $0.returnTypeName == dependency.typeName }
                        .first
                }

            guard resolvedFactoryMethods.count == node.dependencies.count else {
                return nil
            }

            let dependencyInstantiation = resolvedFactoryMethods
                .map { "let \($0.returnTypeName.firstWordLowercased) = \($0.name)()" }
                .joined(separator: "\n")

            let parameters = node.dependencies
                .map { "\($0.name): \($0.typeName.firstWordLowercased)"}
                .joined(separator: ", ")

            let functionName = node.instantiatingFunction.nameWithoutParameters
            let selfInstantiationCode: String
            if functionName == "init" {
                selfInstantiationCode = "return \(node.typeName)(dependency: .init(\(parameters)))"
            } else {
                selfInstantiationCode = "return \(functionName)(\(parameters))"
            }

            bodyLines = [dependencyInstantiation, selfInstantiationCode]
                .joined(separator: "\n")
                .components(separatedBy: CharacterSet.newlines)
                .filter { !$0.isEmpty }

            returnTypeName = node.typeName
            name = "make" + node.typeName
        }
    }
}
