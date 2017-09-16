//
//  Function.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation
import SourceKittenFramework

struct Function {
    private static var declarationKinds: [SwiftDeclarationKind] {
        return [.functionMethodInstance, .functionMethodStatic]
    }

    struct Parameter {
        let name: String
        let typeName: String

        init?(structure: Structure) {
            guard structure.kind == .varParameter,
                let name = structure.name,
                let type = structure.typeName else {
                return nil
            }

            self.name = name
            self.typeName = type
        }
    }

    let name: String
    let kind: SwiftDeclarationKind
    let parameters: [Parameter]
    let returnTypeName: String

    var isInitializer: Bool {
        return name.hasPrefix("init(")
    }

    var isStatic: Bool {
        return kind == .functionMethodStatic
    }

    init?(structure: Structure, file: File) {
        guard
            let kind = structure.kind, Function.declarationKinds.contains(kind),
            let name = structure.name,
            let offset = structure.offset,
            let length = structure.length else {
            return nil
        }

        let view = file.contents.utf16
        let startIndex = view.index(view.startIndex, offsetBy: Int(offset))
        let endIndex = view.index(startIndex, offsetBy: Int(length))
        guard let function = String(view[startIndex..<endIndex]) else {
            return nil
        }

        let declarationEndIndex = function.range(of: "{")?.lowerBound ?? function.endIndex
        let declaration = function[function.startIndex..<declarationEndIndex]
        self.returnTypeName = declaration
            .components(separatedBy: "->").last?
            .trimmingCharacters(in: .whitespaces) ?? "Void"

        self.name = name
        self.kind = kind
        self.parameters = structure.substructures.flatMap(Parameter.init)
    }
}
