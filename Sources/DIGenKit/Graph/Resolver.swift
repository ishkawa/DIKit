//
//  Resolver.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

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
}
