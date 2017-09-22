//
//  Property.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation
import SourceKittenFramework

struct Property {
    let name: String
    let typeName: String
    let isStatic: Bool

    let file: File
    let offset: Int64

    init?(structure: Structure, file: File) {
        guard structure.kind == .varInstance || structure.kind == .varStatic,
            let name = structure.name,
            let typeName = structure.typeName,
            let offset = structure.offset else {
            return nil
        }

        self.name = name
        self.typeName = typeName
        self.isStatic = structure.kind == .varStatic
        self.file = file
        self.offset = offset
    }
}
