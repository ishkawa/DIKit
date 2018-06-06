//
//  ProviderMethod.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation
import SourceKittenFramework

struct ProviderMethod {
    struct Error: LocalizedError, Findable {
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

        var file: File {
            return method?.file ?? type.file
        }

        var offset: Int64 {
            return method?.offset ?? type.offset
        }

        var errorDescription: String? {
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
    let isShared: Bool

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
        parameters = method.parameters
        
        let components1 = method.returnTypeName.components(separatedBy: "<")
        if components1.count == 2 && components1.first == "Shared",
            let components2 = components1.last?.components(separatedBy: ">"),
            components2.count == 2 && components2[1].isEmpty {
            returnTypeName = components2[0]
            isShared = true
        } else {
            returnTypeName = method.returnTypeName
            isShared = false
        }
    }
    
    static func providerMethods(inResolverType type: Type) throws -> [ProviderMethod] {
        guard 
            type.inheritedTypeNames.contains("Resolver") ||
            type.inheritedTypeNames.contains("DIKit.Resolver") else {
            throw Error(type: type, method: nil, reason: .nonResolverTypeMethod)
        }
        
        return try type.methods
            .compactMap { method in
                do {
                    return try ProviderMethod(type: type, method: method)
                } catch let error as ProviderMethod.Error where error.reason == .providePrefixNotFound {
                    return nil
                } catch {
                    throw error
                }
            }
    }
}
