//
//  String+Name.swift
//  dikitgen
//
//  Created by Yosuke Ishikawa on 2017/09/16.
//

import Foundation

extension String {
    var firstWordLowercased: String {
        var firstlowercaseIndex: String.Index?
        for (offset, character) in enumerated() where offset > 0 {
            if let scalar = character.unicodeScalars.first,
                character.unicodeScalars.count == 1 &&
                CharacterSet.lowercaseLetters.contains(scalar) {
                if offset == 1 {
                    firstlowercaseIndex = index(startIndex, offsetBy: offset)
                } else {
                    firstlowercaseIndex = index(startIndex, offsetBy: offset - 1)
                }
                break
            }
        }

        let wordRange = ..<(firstlowercaseIndex ?? endIndex)
        var newString = self
        newString.replaceSubrange(wordRange, with: self[wordRange].lowercased())

        return newString
    }
}
