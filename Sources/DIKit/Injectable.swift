//
//  Protocols.swift
//  DIKit
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

public protocol Injectable {
    associatedtype Dependency
    init(dependency: Dependency)
}
