//
//  MethodTests.swift
//  DIKitPackageDescription
//
//  Created by Yosuke Ishikawa on 2017/09/21.
//

import Foundation
import XCTest
import SourceKittenFramework

@testable import DIGenKit

final class MethodTests: XCTestCase {
    func test() throws {
        let code = """
            struct Test {
                func someFunction(a: A, b: B) -> C {}
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)
        let method = type?.methods.first

        XCTAssertEqual(method?.name, "someFunction(a:b:)")
        XCTAssertEqual(method?.nameWithoutParameters, "someFunction")
        XCTAssertEqual(method?.parameters[0].name, "a")
        XCTAssertEqual(method?.parameters[0].typeName, "A")
        XCTAssertEqual(method?.parameters[1].name, "b")
        XCTAssertEqual(method?.parameters[1].typeName, "B")
        XCTAssertEqual(method?.returnTypeName, "C")

        XCTAssertEqual(method?.isStatic, false)
        XCTAssertEqual(method?.isInitializer, false)
    }

    func testInitializer() throws {
        let code = """
            struct Test {
                init(a: A, b: B) {}
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)
        let method = type?.methods.first

        XCTAssertEqual(method?.name, "init(a:b:)")
        XCTAssertEqual(method?.nameWithoutParameters, "init")
        XCTAssertEqual(method?.parameters[0].name, "a")
        XCTAssertEqual(method?.parameters[0].typeName, "A")
        XCTAssertEqual(method?.parameters[1].name, "b")
        XCTAssertEqual(method?.parameters[1].typeName, "B")

        XCTAssertEqual(method?.isStatic, false)
        XCTAssertEqual(method?.isInitializer, true)
    }

    func testStatic() throws {
        let code = """
            struct Test {
                static func someFunction(a: A, b: B) -> D {}
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)
        let method = type?.methods.first

        XCTAssertEqual(method?.name, "someFunction(a:b:)")
        XCTAssertEqual(method?.nameWithoutParameters, "someFunction")
        XCTAssertEqual(method?.parameters[0].name, "a")
        XCTAssertEqual(method?.parameters[0].typeName, "A")
        XCTAssertEqual(method?.parameters[1].name, "b")
        XCTAssertEqual(method?.parameters[1].typeName, "B")
        XCTAssertEqual(method?.returnTypeName, "D")

        XCTAssertEqual(method?.isStatic, true)
        XCTAssertEqual(method?.isInitializer, false)
    }

    func testNoParameters() throws {
        let code = """
            struct Test {
                func someFunction() -> A {}
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)
        let method = type?.methods.first
        XCTAssertEqual(method?.name, "someFunction()")
        XCTAssertEqual(method?.returnTypeName, "A")
    }

    func testNoReturnType() throws {
        let code = """
            struct Test {
                func someFunction() {}
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)
        let method = type?.methods.first
        XCTAssertEqual(method?.name, "someFunction()")
        XCTAssertEqual(method?.returnTypeName, "Void")
    }
}
