//
//  Structure+Property.swift
//  DIKit
//
//  Created by ishkawa on 2017/05/29.
//
//

import Foundation
import SourceKittenFramework

extension Structure {
    subscript(key: SwiftDocKey) -> SourceKitRepresentable? {
        get {
            return dictionary[key.rawValue]
        }
        set {
            var dictionary = self.dictionary
            dictionary[key.rawValue] = newValue
            self = Structure(sourceKitResponse: dictionary)
        }
    }

    var name: String? {
        return self[.name] as? String
    }

    var kind: SwiftDeclarationKind? {
        return (self[.kind] as? String).flatMap(SwiftDeclarationKind.init)
    }

    var typeName: String? {
        return self[.typeName] as? String
    }

    var substructures: [Structure] {
        guard let dictionaries = self[.substructure] as? [[String: SourceKitRepresentable]] else {
            return []
        }

        return dictionaries.map(Structure.init(sourceKitResponse:))
    }

    var elements: [Structure] {
        guard let dictionaries = self.dictionary["key.elements"] as? [[String: SourceKitRepresentable]] else {
            return []
        }

        return dictionaries.map(Structure.init(sourceKitResponse:))
    }

    var offset: Int? {
        return self[.offset] as? Int
    }
    
    var length: Int? {
        return self[.length] as? Int
    }
}
