//
//  Counter.swift
//  Example
//
//  Created by Yosuke Ishikawa on 2017/12/29.
//  Copyright © 2017年 ishkawa. All rights reserved.
//

import Foundation
import DIKit

final class Counter: Injectable {
    struct Dependency {
        let value: Int
    }
    
    private(set) var value: Int
    
    init(dependency: Dependency) {
        value = dependency.value
    }
    
    func increment() {
        value = min(value + 1, 999999999999)
    }
}
