//
//  DetailViewController.swift
//  Example
//
//  Created by Yosuke Ishikawa on 2017/09/17.
//  Copyright © 2017年 ishkawa. All rights reserved.
//

import UIKit
import DIKit

final class DetailViewController: UIViewController, FactoryMethodInjectable {
    struct Dependency {
        let index: Int
        let apiClient: APIClient
    }

    private var dependency: Dependency!

    static func makeInstance(dependency: Dependency) -> DetailViewController {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! DetailViewController
        viewController.dependency = dependency
        return viewController
    }

    @IBOutlet private weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = String(dependency.index)
    }
}
