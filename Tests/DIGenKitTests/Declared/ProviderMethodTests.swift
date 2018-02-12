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
    func test() throws {
        let code = """
            protocol Test: Resolver {
                func provideA(b: B, c: C) -> A
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let method = (try? ProviderMethod.providerMethods(inResolverType: type))?.first
        XCTAssertEqual(method?.nameWithoutParameters, "provideA")
        XCTAssertEqual(method?.returnTypeName, "A")
        XCTAssertEqual(method?.parameters.count, 2)
        XCTAssertEqual(method?.parameters[0].name, "b")
        XCTAssertEqual(method?.parameters[0].typeName, "B")
        XCTAssertEqual(method?.parameters[1].name, "c")
        XCTAssertEqual(method?.parameters[1].typeName, "C")
    }

    func testNonResolverType() throws {
        let code = """
            protocol Test {
                func provideA(b: B, c: C) -> A
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try ProviderMethod.providerMethods(inResolverType: type)
            XCTFail()
        } catch let error as ProviderMethod.Error {
            XCTAssertEqual(error.reason, .nonResolverTypeMethod)
        } catch {
            XCTFail()
        }
    }

    func testMissingReturnType() throws {
        let code = """
            protocol Test: Resolver {
                func provideA(b: B, c: C)
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try ProviderMethod.providerMethods(inResolverType: type)
            XCTFail()
        } catch let error as ProviderMethod.Error {
            XCTAssertEqual(error.reason, .returnTypeNotFound)
        } catch {
            XCTFail()
        }
    }

    func testStatic() throws {
        let code = """
            protocol Test: Resolver {
                static func provideA(b: B, c: C) -> A
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try ProviderMethod.providerMethods(inResolverType: type)
            XCTFail()
        } catch let error as ProviderMethod.Error {
            XCTAssertEqual(error.reason, .nonInstanceMethod)
        } catch {
            XCTFail()
        }
    }
}
