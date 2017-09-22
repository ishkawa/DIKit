//
//  Resolver.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

struct Resolver {
    let name: String

    let resolveMethods: [ResolveMethod]
    let injectMethods: [InjectMethod]
    let generatedMethods: [GeneratedMethod]

    init?(type: Type, allTypes: [Type]) {
        guard
            type.inheritedTypeNames.contains("Resolver") ||
            type.inheritedTypeNames.contains("DIKit.Resolver") else {
            return nil
        }

        name = type.name

        let initializerInjectableTypes = allTypes
            .flatMap { try? InitializerInjectableType(type: $0) }
            .map { Node.Declaration.initializerInjectableType($0) }

        let factoryMethodInjectableTypes = allTypes
            .flatMap(FactoryMethodInjectableType.init(type:))
            .map { Node.Declaration.factoryMethodInjectableType($0) }

        let providerMethods = ProviderMethod
            .providerMethods(inResolverType: type)
            .map { Node.Declaration.providerMethod($0) }

        let allDeclarations = initializerInjectableTypes + factoryMethodInjectableTypes + providerMethods
        var unresolvedDeclarations = allDeclarations
        var nodesForResolverMethods = [] as [Node]

        while !unresolvedDeclarations.isEmpty {
            var resolved = false
            for (index, declaration) in unresolvedDeclarations.enumerated() {
                guard let node = Node(declaration: declaration, allDeclarations: allDeclarations, availableNodes: nodesForResolverMethods) else {
                    continue
                }

                unresolvedDeclarations.remove(at: index)
                nodesForResolverMethods.append(node)
                resolved = true
                break
            }

            if !resolved {
                // TODO: Throw error
                return nil
            }
        }

        resolveMethods = nodesForResolverMethods.flatMap(ResolveMethod.init(node:))

        let propertyInjectableTypes = allTypes
            .flatMap(PropertyInjectableType.init(type:))
            .map { Node.Declaration.propertyInjectableType($0) }

        unresolvedDeclarations = propertyInjectableTypes
        var nodesForInjectMethods = [] as [Node]

        while !unresolvedDeclarations.isEmpty {
            var resolved = false
            for (index, declaration) in unresolvedDeclarations.enumerated() {
                guard let node = Node(declaration: declaration, allDeclarations: allDeclarations, availableNodes: nodesForResolverMethods) else {
                    continue
                }

                print(node.declaration)
                unresolvedDeclarations.remove(at: index)
                nodesForInjectMethods.append(node)
                resolved = true
                break
            }

            if !resolved {
                // TODO: Throw error
                return nil
            }
        }

        injectMethods = nodesForInjectMethods.flatMap(InjectMethod.init(node:))
        generatedMethods = resolveMethods as [GeneratedMethod] + injectMethods as [GeneratedMethod]
    }
}
