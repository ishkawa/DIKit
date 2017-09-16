//
//  Resolver.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

struct Resolver {
    let name: String
    let nodes: [Node]

    init?(type: Type, injectableTypeNodes: [Node]) {
        guard 
            type.inheritedTypeNames.contains("Resolver") ||
            type.inheritedTypeNames.contains("DIKit.Resolver") else {
            return nil
        }

        var unresolvedNodes = injectableTypeNodes + type.functions.flatMap(Node.init(providerMethod:))
        var resolvedNodes = [] as [Node]

        while !unresolvedNodes.isEmpty {
            var resolved = false
            for (index, unresolvedNode) in unresolvedNodes.enumerated() {
                let resolvable = unresolvedNode.dependencyTypeNames
                    .reduce(true) { result, unresolvedNode in
                        return result && resolvedNodes.contains { $0.typeName == unresolvedNode }
                    }

                if resolvable {
                    unresolvedNodes.remove(at: index)
                    resolvedNodes.append(unresolvedNode)
                    resolved = true
                    break
                }
            }

            if !resolved {
                // TODO: Throw error
                return nil
            }
        }

        nodes = resolvedNodes
        name = type.name
    }
}
