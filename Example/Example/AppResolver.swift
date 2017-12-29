//
//  AppResolver.swift
//  Example
//
//  Created by Yosuke Ishikawa on 2017/09/17.
//  Copyright © 2017年 ishkawa. All rights reserved.
//

import Foundation
import DIKit

protocol AppResolver: DIKit.Resolver {
    func provideResolver() -> AppResolver
    func provideCounter() -> Shared<Counter>
}

final class AppResolverImpl: AppResolver {
    var sharedInstances = [:] as [String : Any]
    
    func provideResolver() -> AppResolver {
        return self
    }
    
    func provideCounter() -> Shared<Counter> {
        let counter = Counter(dependency: .init(value: 0))
        return Shared(counter)
    }
}
