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
    let parameters: [Parameter]

    var isInitializer: Bool {
        return name.hasPrefix("init(")
    }

    init?(structure: Structure) {
        guard structure.kind == .functionMethodInstance,
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.parameters = structure.substructures.flatMap(Parameter.init)
    }
}
