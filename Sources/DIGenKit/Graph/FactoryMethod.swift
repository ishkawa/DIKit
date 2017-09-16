//
//  FactoryMethod.swift
//  dikitgen
//
//  Created by Yosuke Ishikawa on 2017/09/16.
//

import Foundation

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
