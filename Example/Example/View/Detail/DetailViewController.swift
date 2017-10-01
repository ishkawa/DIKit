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
        let multiplier: Multiplier
    }

    static func makeInstance(dependency: Dependency) -> DetailViewController {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! DetailViewController
        viewController.dependency = dependency
        return viewController
    }
    
    private var dependency: Dependency!

    @IBOutlet private weak var label: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabel()
    }

    private func updateLabel() {
        label.text = String(dependency.multiplier.value)
    }

    @IBAction private func doubleButtonTapped() {
        dependency.multiplier.doubleValue()
        updateLabel()
    }

    @IBAction private func tripleButtonTapped() {
        dependency.multiplier.tripleValue()
        updateLabel()
    }
}
