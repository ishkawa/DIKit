//
//  String+Name.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation

extension String {
    var firstCharacterLowerCased: String {
        return replacingCharacters(
            in: startIndex..<index(startIndex, offsetBy: 1),
            with: String(self[startIndex]).lowercased())
    }

    func trimmingSuffix(_ suffix: String) -> String {
        return String(self[startIndex..<index(endIndex, offsetBy: -suffix.characters.count)])
    }
}
