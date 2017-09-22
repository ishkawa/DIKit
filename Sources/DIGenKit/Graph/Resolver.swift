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
            .map { Node.Declaration.initializerInjectableType($0) }

        let factoryMethodInjectableTypes = allTypes
            .flatMap(FactoryMethodInjectableType.init(type:))
            .map { Node.Declaration.factoryMethodInjectableType($0) }

        let providerMethods = ProviderMethod
            .providerMethods(inResolverType: type)
            .map { Node.Declaration.providerMethod($0) }

        let allDeclarations = initializerInjectableTypes + factoryMethodInjectableTypes + providerMethods
        var unresolvedDeclarations = allDeclarations
        var nodes = [] as [Node]

        while !unresolvedDeclarations.isEmpty {
            var resolved = false
            for (index, declaration) in unresolvedDeclarations.enumerated() {
                guard let node = Node(declaration: declaration, allDeclarations: allDeclarations, availableNodes: nodes) else {
                    continue
                }

                unresolvedDeclarations.remove(at: index)
                nodes.append(node)
                resolved = true
                break
            }

            if !resolved {
                // TODO: Throw error
                return nil
            }
        }

        name = type.name
        resolveMethods = nodes.flatMap(ResolveMethod.init(node:))
    }
}
