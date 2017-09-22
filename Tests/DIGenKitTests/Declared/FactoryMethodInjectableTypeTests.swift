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
    func test() {
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
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = FactoryMethodInjectableType(type: type)
        XCTAssertEqual(injectableType?.name, "Test")
        XCTAssertEqual(injectableType?.dependencyProperties.count, 2)
        XCTAssertEqual(injectableType?.dependencyProperties[0].name, "a")
        XCTAssertEqual(injectableType?.dependencyProperties[0].typeName, "A")
        XCTAssertEqual(injectableType?.dependencyProperties[1].name, "b")
        XCTAssertEqual(injectableType?.dependencyProperties[1].typeName, "B")
    }

    func testNonInjectableType() {
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
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = FactoryMethodInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testClassAssociatedType() {
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
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = FactoryMethodInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testMissingAssociatedType() {
        let code = """
            struct Test: FactoryMethodInjectable {
                static func makeInstance(dependency: Dependency) {
                    return Test()
                }
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = FactoryMethodInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testMissingFactoryMethod() {
        let code = """
            struct Test: FactoryMethodInjectable {
                struct Dependency {
                    let a: A
                    let b: B
                }
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = FactoryMethodInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testWrongTypeFactoryMethod() {
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
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = FactoryMethodInjectableType(type: type)
        XCTAssertNil(injectableType)
    }
}

