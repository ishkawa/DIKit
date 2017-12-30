//
//  Multiplier.swift
//  Example
//
//  Created by Yosuke Ishikawa on 2017/10/01.
//  Copyright © 2017年 ishkawa. All rights reserved.
//

import Foundation
import DIKit

final class Multiplier: Injectable {
    struct Dependency {
        let value: Int
    }

    private(set) var value: Int

    init(dependency: Dependency) {
        value = dependency.value
    }

    func doubleValue() {
        value = min(value * 2, 999999999999)
    }

    func tripleValue() {
        value = min(value * 3, 999999999999)
    }
}
