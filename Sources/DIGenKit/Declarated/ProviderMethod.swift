//
//  ProviderMethod.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation

struct ProviderMethod {
    struct Error: Swift.Error {
        enum Reason {
            case nonResolverTypeMethod
            case providePrefixNotFound
            case returnTypeNotFound
            case nonInstanceMethod
            case nonMethod
        }

        let type: Type
        let method: Method?
        let reason: Reason

        var localizedDescription: String {
            switch reason {
            case .nonResolverTypeMethod:
                return "Type does not conform to 'Resolver' protocol"
            case .providePrefixNotFound:
                return "Provide method must have 'provide' prefix"
            case .returnTypeNotFound:
                return "Provide method must return non-void type"
            case .nonInstanceMethod:
                return "Provide method must not be static"
            case .nonMethod:
                return "Provide method must not be an initalizer"
            }
        }
    }

    let nameWithoutParameters: String
    let returnTypeName: String
    let parameters: [Method.Parameter]

    private init(type: Type, method: Method) throws {
        guard method.name.hasPrefix("provide") else {
            throw Error(type: type, method: method, reason: .providePrefixNotFound)
        }

        guard method.returnTypeName != "Void" else {
            throw Error(type: type, method: method, reason: .returnTypeNotFound)
        }

        guard !method.isStatic else {
            throw Error(type: type, method: method, reason: .nonInstanceMethod)
        }

        guard !method.isInitializer else {
            throw Error(type: type, method: method, reason: .nonMethod)
        }

        nameWithoutParameters = method.nameWithoutParameters
        returnTypeName = method.returnTypeName
        parameters = method.parameters
    }
    
    static func providerMethods(inResolverType type: Type) throws -> [ProviderMethod] {
        guard 
            type.inheritedTypeNames.contains("Resolver") ||
            type.inheritedTypeNames.contains("DIKit.Resolver") else {
            throw Error(type: type, method: nil, reason: .nonResolverTypeMethod)
        }
        
        return try type.methods.flatMap { try ProviderMethod(type: type, method: $0) }
    }
}
