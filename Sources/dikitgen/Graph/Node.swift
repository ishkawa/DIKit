//
//  Node.swift
//  DIKit
//
//  Created by Yosuke Ishikawa on 2017/08/07.
//
//

import Foundation

enum Node {
    case injectable(type: Type, dependencies: [(Property, Node)], initializer: Function)
    case providable(type: Type)

    var type: Type {
        switch self {
        case .injectable(let type, _, _):
            return type
        case .providable(let type):
            return type
        }
    }
}
