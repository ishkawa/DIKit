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
}

final class AppResolverImpl: AppResolver {
    func provideResolver() -> AppResolver {
        return self
    }
}
