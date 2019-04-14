//
//  AppDelegate.swift
//  Example
//
//  Created by Yosuke Ishikawa on 2017/09/17.
//  Copyright © 2017年 ishkawa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let appResolver = AppResolverImpl()

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let viewController = appResolver.resolveListViewController()
        let navigationController = UINavigationController(rootViewController: viewController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        return true
    }
}
