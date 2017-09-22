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

public protocol FactoryMethodInjectable {
    associatedtype Dependency
    static func makeInstance(dependency: Dependency) -> Self
}

public protocol PropertyInjectable: class {
    associatedtype Dependency
    var dependency: Dependency! { get set }
}
