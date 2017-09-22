//
//  GeneratedMethod.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

protocol GeneratedMethod {
    var name: String { get }
    var returnTypeName: String { get }
    var bodyLines: [String] { get }
    var parametersDeclaration: String { get }
}

extension ResolveMethod: GeneratedMethod {}
extension InjectMethod: GeneratedMethod {}
