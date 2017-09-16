//
//  Tests.swift
//  dikitgenTests
//
//  Created by Yosuke Ishikawa on 2017/09/16.
//

import XCTest
import DIGenKit
import DIKit

struct A: Injectable {
    struct Dependency {}
    init(dependency: Dependency) {}
}

struct B: Injectable {
    struct Dependency {
        let ba: A
    }

    init(dependency: Dependency) {}
}

struct C: Injectable {
    struct Dependency {
        let ca: A
        let cd: D
    }

    init(dependency: Dependency) {}
}

struct D {}

protocol DemoResolver: DIKit.Resolver {
    func provideD() -> D
}

final class Tests: XCTestCase {
    func test() {
        let generator = CodeGenerator(path: #file)
        let contents = try! generator.generate()
        print(contents)
    }
}
