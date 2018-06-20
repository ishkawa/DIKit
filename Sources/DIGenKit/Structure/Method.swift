//
//  Function.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation
import SourceKittenFramework

struct Method {
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
    let nameWithoutParameters: String
    let kind: SwiftDeclarationKind
    let parameters: [Parameter]
    let returnTypeName: String

    let file: File
    let offset: Int64

    var isInitializer: Bool {
        return name.hasPrefix("init(")
    }

    var isStatic: Bool {
        return kind == .functionMethodStatic
    }

    init?(structure: Structure, file: File) {
        guard
            let kind = structure.kind, Method.declarationKinds.contains(kind),
            let name = structure.name,
            let offset = structure.offset,
            let length = structure.length else {
            return nil
        }

        let methodPart: String = {
            let view = file.contents.utf8
            let startIndex = view.index(view.startIndex, offsetBy: Int(offset))
            let endIndex = view.index(startIndex, offsetBy: Int(length))
            return String(view[startIndex..<endIndex])!
        }()

        self.returnTypeName = {
            let endIndex = methodPart.range(of: "{")?.lowerBound ?? methodPart.endIndex
            let declaration = methodPart[methodPart.startIndex..<endIndex]
            let components = declaration.components(separatedBy: "->")

            if components.count == 2 {
                return components[1].trimmingCharacters(in: .whitespaces)
            } else {
                return "Void"
            }
        }()

        self.nameWithoutParameters = name
            .components(separatedBy: "(").first?
            .trimmingCharacters(in: .whitespaces) ?? name

        self.name = name
        self.kind = kind
        self.parameters = structure.substructures.compactMap(Parameter.init)
        self.file = file
        self.offset = offset
    }
}
