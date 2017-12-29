//
//  Shared.swift
//  DIKit
//
//  Created by Yosuke Ishikawa on 2017/12/29.
//

public struct Shared<Instance> {
    public let instance: Instance
    
    public init(_ instance: Instance) {
        self.instance = instance
    }
}
