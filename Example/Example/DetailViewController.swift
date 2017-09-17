//
//  DetailViewController.swift
//  Example
//
//  Created by Yosuke Ishikawa on 2017/09/17.
//  Copyright © 2017年 ishkawa. All rights reserved.
//

import UIKit
import DIKit

final class DetailViewController: UIViewController, Injectable {
    struct Dependency {
        let index: Int
        let apiClient: APIClient
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let label = UILabel()
        label.text = String(dependency.index)
        label.frame = view.bounds
        label.textAlignment = .center
        view.addSubview(label)
    }
}
