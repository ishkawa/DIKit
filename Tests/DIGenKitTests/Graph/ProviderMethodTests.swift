//
//  ProviderMethodTests.swift
//  DIGenKitTests
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation
import XCTest
import SourceKittenFramework

@testable import DIGenKit

final class ProviderMethodTests: XCTestCase {
    func test() {
        let code = """
            protocol Test: Resolver {
                func provideA(b: B, c: C) -> A
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let method = ProviderMethod.providerMethods(inResoverType: type).first
        XCTAssertEqual(method?.nameWithoutParameters, "provideA")
        XCTAssertEqual(method?.returnTypeName, "A")
        XCTAssertEqual(method?.parameters.count, 2)
        XCTAssertEqual(method?.parameters[0].name, "b")
        XCTAssertEqual(method?.parameters[0].typeName, "B")
        XCTAssertEqual(method?.parameters[1].name, "c")
        XCTAssertEqual(method?.parameters[1].typeName, "C")
    }

    func testNonResolverType() {
        let code = """
            protocol Test {
                func provideA(b: B, c: C) -> A
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let method = ProviderMethod.providerMethods(inResoverType: type).first
        XCTAssertNil(method)
    }

    func testMissingReturnType() {
        let code = """
            protocol Test: Resolver {
                func provideA(b: B, c: C)
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let method = ProviderMethod.providerMethods(inResoverType: type).first
        XCTAssertNil(method)
    }

    func testStatic() {
        let code = """
            protocol Test: Resolver {
                static func provideA(b: B, c: C) -> A
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let method = ProviderMethod.providerMethods(inResoverType: type).first
        XCTAssertNil(method)
    }

    func testWithoutProvidePrefix() {
        let code = """
            protocol Test: Resolver {
                func makeA(b: B, c: C) -> A
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let method = ProviderMethod.providerMethods(inResoverType: type).first
        XCTAssertNil(method)
    }
}
