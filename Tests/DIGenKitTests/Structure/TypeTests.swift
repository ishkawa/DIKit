//
//  TypeTests.swift
//  DIGenKitTests
//
//  Created by Yosuke Ishikawa on 2017/09/21.
//

import Foundation
import XCTest
import SourceKittenFramework

@testable import DIGenKit

final class TypeTests: XCTestCase {
    func test() throws {
        let code = """
            struct Test: A, B {
                typealias C = D
                struct E {}
                var someProperty: F
                func someFunction() -> G {}
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)

        XCTAssertEqual(type?.inheritedTypeNames ?? [], ["A", "B"])
        XCTAssertEqual(type?.nestedTypes.count, 1)
        XCTAssertEqual(type?.nestedTypes.first?.name, "E")
        XCTAssertEqual(type?.properties.count, 1)
        XCTAssertEqual(type?.properties.first?.name, "someProperty")
        XCTAssertEqual(type?.methods.count, 1)
        XCTAssertEqual(type?.methods.first?.name, "someFunction()")
    }
}
