//
//  Import.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/11/13.
//

import Foundation
import SourceKittenFramework

struct Import {
    let moduleName: String

    static func imports(from file: File) throws -> [Import] {
        let syntaxMap = try SyntaxMap(file: file)
        let importTokenIndices = syntaxMap.tokens.enumerated()
            .compactMap { index, token -> Int? in
                guard token.type == "source.lang.swift.syntaxtype.keyword" else {
                    return nil
                }

                let view = file.contents.utf8
                let startIndex = view.index(view.startIndex, offsetBy: Int(token.offset))
                let endIndex = view.index(startIndex, offsetBy: Int(token.length))
                let value = String(view[startIndex..<endIndex])!
                return value == "import" ? index : nil
            }

        let importedModuleNames = importTokenIndices
            .compactMap { index -> String? in
                let identifierIndex = index + 1
                guard identifierIndex < syntaxMap.tokens.count else {
                    return nil
                }

                let token = syntaxMap.tokens[identifierIndex]
                guard token.type == "source.lang.swift.syntaxtype.identifier" else {
                    return nil
                }

                let view = file.contents.utf8
                let startIndex = view.index(view.startIndex, offsetBy: Int(token.offset))
                let endIndex = view.index(startIndex, offsetBy: Int(token.length))
                return String(view[startIndex..<endIndex])!
            }

        return importedModuleNames.map(Import.init(moduleName:))
    }
}
