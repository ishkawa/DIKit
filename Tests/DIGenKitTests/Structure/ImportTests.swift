//
//  ImportTests.swift
//  DIGenKitTests
//
//  Created by Yosuke Ishikawa on 2017/11/13.
//

import Foundation
import XCTest
import SourceKittenFramework

@testable import DIGenKit

final class ImportTests: XCTestCase {
    func test() throws {
        let code = """
            import Foundation
            import DIKit

            struct Test: A, B {
                typealias C = D
                struct E {}
                var someProperty: F
                func someFunction() -> G {}
            }

            import Foundation
            """

        let file = File(contents: code)
        let imports = try Import.imports(from: file)
        let moduleNames = imports.map { $0.moduleName }

        XCTAssertEqual(moduleNames, ["Foundation", "DIKit", "Foundation"])
    }
}

