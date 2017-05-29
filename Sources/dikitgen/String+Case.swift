//
//  String+Case.swift
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
}
