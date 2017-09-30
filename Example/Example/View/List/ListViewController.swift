//
//  ListViewController.swift
//  Example
//
//  Created by Yosuke Ishikawa on 2017/09/17.
//  Copyright © 2017年 ishkawa. All rights reserved.
//

import UIKit
import DIKit

final class ListViewController: UITableViewController, FactoryMethodInjectable {
    struct Dependency {
        let resolver: AppResolver
    }

    static func makeInstance(dependency: Dependency) -> ListViewController {
        let storyboard = UIStoryboard(name: "List", bundle: nil)
        let viewConroller = storyboard.instantiateInitialViewController() as! ListViewController
        viewConroller.dependency = dependency
        return viewConroller
    }

    private var dependency: Dependency!

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Item \(indexPath.row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = dependency.resolver.resolveDetailViewController(value: indexPath.row)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
