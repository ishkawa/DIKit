//
//  FactoryMethodInjectableTypeTests.swift
//  DIGenKitTests
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation
import XCTest
import SourceKittenFramework

@testable import DIGenKit

final class FactoryMethodInjectableTypeTests: XCTestCase {
    func test() throws {
        let code = """
            struct Test: FactoryMethodInjectable {
                struct Dependency {
                    let a: A
                    let b: B
                }

                static func makeInstance(dependency: Dependency) {
                    return Test()
                }
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = try? FactoryMethodInjectableType(type: type)
        XCTAssertEqual(injectableType?.name, "Test")
        XCTAssertEqual(injectableType?.dependencyProperties.count, 2)
        XCTAssertEqual(injectableType?.dependencyProperties[0].name, "a")
        XCTAssertEqual(injectableType?.dependencyProperties[0].typeName, "A")
        XCTAssertEqual(injectableType?.dependencyProperties[1].name, "b")
        XCTAssertEqual(injectableType?.dependencyProperties[1].typeName, "B")
    }

    func testNonInjectableType() throws {
        let code = """
            struct Test {
                struct Dependency {
                    let a: A
                    let b: B
                }

                static func makeInstance(dependency: Dependency) {
                    return Test()
                }
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try FactoryMethodInjectableType(type: type)
            XCTFail()
        } catch let error as FactoryMethodInjectableType.Error {
            XCTAssertEqual(error.reason, .protocolConformanceNotFound)
        } catch {
            XCTFail()
        }
    }

    func testClassAssociatedType() throws {
        let code = """
            struct Test: FactoryMethodInjectable {
                class Dependency {
                    let a: A
                    let b: B
                }

                static func makeInstance(dependency: Dependency) {
                    return Test()
                }
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try FactoryMethodInjectableType(type: type)
            XCTFail()
        } catch let error as FactoryMethodInjectableType.Error {
            XCTAssertEqual(error.reason, .nonStructAssociatedType)
        } catch {
            XCTFail()
        }
    }

    func testMissingAssociatedType() throws {
        let code = """
            struct Test: FactoryMethodInjectable {
                static func makeInstance(dependency: Dependency) {
                    return Test()
                }
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try FactoryMethodInjectableType(type: type)
            XCTFail()
        } catch let error as FactoryMethodInjectableType.Error {
            XCTAssertEqual(error.reason, .associatedTypeNotFound)
        } catch {
            XCTFail()
        }
    }

    func testMissingFactoryMethod() throws {
        let code = """
            struct Test: FactoryMethodInjectable {
                struct Dependency {
                    let a: A
                    let b: B
                }
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try FactoryMethodInjectableType(type: type)
            XCTFail()
        } catch let error as FactoryMethodInjectableType.Error {
            XCTAssertEqual(error.reason, .factoryMethodNotFound)
        } catch {
            XCTFail()
        }
    }

    func testWrongTypeFactoryMethod() throws {
        let code = """
            struct Test: FactoryMethodInjectable {
                struct Dependency {
                    let a: A
                    let b: B
                }

                static func makeInstance(dependency: A) {
                    return Test()
                }
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try FactoryMethodInjectableType(type: type)
            XCTFail()
        } catch let error as FactoryMethodInjectableType.Error {
            XCTAssertEqual(error.reason, .factoryMethodNotFound)
        } catch {
            XCTFail()
        }
    }
}

