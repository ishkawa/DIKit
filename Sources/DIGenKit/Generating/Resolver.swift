//
//  Resolver.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

import Foundation
import SourceKittenFramework

struct Resolver {
    struct Error: LocalizedError, Findable {
        enum Reason {
            case protocolConformanceNotFound
            case unresolvableDependecyGraph
        }

        let type: Type
        let reason: Reason

        var file: File {
            return type.file
        }

        var offset: Int64 {
            return type.offset
        }

        var errorDescription: String? {
            switch reason {
            case .protocolConformanceNotFound:
                return "Type does not conform to 'Resolver' protocol"
            case .unresolvableDependecyGraph:
                return "Could not resolve dependency graph"
            }
        }
    }

    
    let name: String

    let resolveMethods: [ResolveMethod]
    let injectMethods: [InjectMethod]
    let sortedGeneratedMethods: [GeneratedMethod]

    init(type: Type, allTypes: [Type]) throws {
        guard
            type.inheritedTypeNames.contains("Resolver") ||
            type.inheritedTypeNames.contains("DIKit.Resolver") else {
            throw Error(type: type, reason: .protocolConformanceNotFound)
        }

        name = type.name

        let providerMethods = try ProviderMethod
            .providerMethods(inResolverType: type)
            .map { Node.Declaration.providerMethod($0) }

        var registeredTypeNames = providerMethods.map({ $0.typeName })
        let initializerInjectableTypes = try allTypes
            .compactMap { type in
                guard !registeredTypeNames.contains(type.name) else {
                    return nil
                }

                do {
                    return try InitializerInjectableType(type: type)
                } catch let error as InitializerInjectableType.Error where error.reason == .protocolConformanceNotFound {
                    return nil
                } catch {
                    throw error
                }
            }
            .map { Node.Declaration.initializerInjectableType($0) }

        registeredTypeNames += initializerInjectableTypes.map({ $0.typeName })

        let factoryMethodInjectableTypes = try allTypes
            .compactMap { type in
                guard !registeredTypeNames.contains(type.name) else {
                    return nil
                }

                do {
                    return try FactoryMethodInjectableType(type: type)
                } catch let error as FactoryMethodInjectableType.Error where error.reason == .protocolConformanceNotFound {
                    return nil
                } catch {
                    throw error
                }
            }
            .map { Node.Declaration.factoryMethodInjectableType($0) }

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
                throw Error(type: type, reason: .unresolvableDependecyGraph)
            }
        }

        resolveMethods = nodesForResolverMethods.compactMap(ResolveMethod.init(node:))

        let propertyInjectableTypes = try allTypes
            .compactMap { type in
                do {
                    return try PropertyInjectableType(type: type)
                } catch let error as PropertyInjectableType.Error where error.reason == .protocolConformanceNotFound {
                    return nil
                } catch {
                    throw error
                }
            }
            .map { Node.Declaration.propertyInjectableType($0) }

        unresolvedDeclarations = propertyInjectableTypes
        var nodesForInjectMethods = [] as [Node]

        while !unresolvedDeclarations.isEmpty {
            var resolved = false
            for (index, declaration) in unresolvedDeclarations.enumerated() {
                guard let node = Node(declaration: declaration, allDeclarations: allDeclarations, availableNodes: nodesForResolverMethods) else {
                    continue
                }

                unresolvedDeclarations.remove(at: index)
                nodesForInjectMethods.append(node)
                resolved = true
                break
            }

            if !resolved {
                throw Error(type: type, reason: .unresolvableDependecyGraph)
            }
        }

        injectMethods = nodesForInjectMethods.compactMap(InjectMethod.init(node:))
        let generatedMethods = resolveMethods as [GeneratedMethod] + injectMethods as [GeneratedMethod]
        sortedGeneratedMethods = generatedMethods.sorted { (lhs, rhs) in return lhs.name < rhs.name }
    }
}
