//
//  Protocols.swift
//  DIKit
//
//  Created by Yosuke Ishikawa on 2017/09/15.
//

public protocol Injectable {}

public protocol InitializerInjectable {
    associatedtype Dependency
    init(dependency: Dependency)
}

public protocol FactoryMethodInjectable {
    associatedtype Dependency
    static func makeInstance(dependency: Dependency) -> Self
}

public protocol PropertyInjectable {
    associatedtype Dependency
    var dependency: Dependency! { get set }
}

public protocol MethodInjectable {
    associatedtype Dependency
    func inject(dependency: Dependency)
}

public protocol Resolver {}
