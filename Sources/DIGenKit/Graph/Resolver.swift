//
//  Resolver.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

struct Resolver {
    let name: String
    let resolveMethods: [ResolveMethod]

    init?(type: Type, allTypes: [Type]) {
        guard
            type.inheritedTypeNames.contains("Resolver") ||
            type.inheritedTypeNames.contains("DIKit.Resolver") else {
            return nil
        }

        let initializerInjectableTypes = allTypes
            .flatMap(InitializerInjectableType.init(type:))
            .map { Node.initializerInjectableType($0) }

        let factoryMethodInjectableTypes = allTypes
            .flatMap(FactoryMethodInjectableType.init(type:))
            .map { Node.factoryMethodInjectableType($0) }

        let providerMethods = ProviderMethod
            .providerMethods(inResoverType: type)
            .map { Node.providerMethod($0) }

        let allNodes = initializerInjectableTypes + factoryMethodInjectableTypes + providerMethods
        var unresolvedNodes = allNodes
        var resolvedFactoryMethods = [] as [ResolveMethod]

        while !unresolvedNodes.isEmpty {
            var resolved = false
            for (index, unresolvedNode) in unresolvedNodes.enumerated() {
                guard let factoryMethod = ResolveMethod(
                    node: unresolvedNode,
                    allNodes: allNodes,
                    factoryMethods: resolvedFactoryMethods) else {
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
        resolveMethods = resolvedFactoryMethods
    }
}
