//
//  Code.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation

import Foundation

struct Code {
    private(set) var content: String
    private var indentDepth: Int

    init(content: String = "", indentDepth: Int = 0) {
        self.content = content
        self.indentDepth = indentDepth
    }

    var indent: String {
        return Array(repeating: "    ", count: indentDepth).joined()
    }

    var isMultipleLines: Bool {
        return content.components(separatedBy: "\n").count > 2
    }

    mutating func append(_ texts: String...) {
        let characters = texts.flatMap { $0.characters }

        for character in characters {
            if content.characters.last == "\n" && character != "\n" {
                content.append(indent)
            }

            content.append(character)
        }

        content.append("\n")
    }

    mutating func incrementIndentDepth() {
        indentDepth += 1
    }

    mutating func decrementIndentDepth() {
        indentDepth -= 1
    }
}
