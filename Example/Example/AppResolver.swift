//
//  AppResolver.swift
//  Example
//
//  Created by Yosuke Ishikawa on 2017/09/17.
//  Copyright © 2017年 ishkawa. All rights reserved.
//

import Foundation
import DIKit

final class APIClient {}

protocol AppResolver: DIKit.Resolver {
    func provideResolver() -> AppResolver
    func provideAPIClient() -> APIClient
}

final class AppResolverImpl: AppResolver {
    private let apiClient = APIClient()

    func provideResolver() -> AppResolver {
        return self
    }

    func provideAPIClient() -> APIClient {
        return apiClient
    }
}
