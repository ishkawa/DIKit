//
//  Node.swift
//  DIKit
//
//  Created by Yosuke Ishikawa on 2017/08/07.
//
//

import Foundation

struct Node {
    let type: Type
    let dependencies: [Node]
    let provider: Function
}
