//
//  PropertyInjectableTests.swift
//  DIGenKitTests
//
//  Created by Yosuke Ishikawa on 2017/09/22.
//

import Foundation
import XCTest
import SourceKittenFramework

@testable import DIGenKit

final class PropertyInjectableTypeTests: XCTestCase {
    func test() {
        let code = """
            struct Test: PropertyInjectable {
                struct Dependency {
                    let a: A
                    let b: B
                }

                var dependency: Dependency!
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = PropertyInjectableType(type: type)
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

                var dependency: Dependency!
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = PropertyInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testClassAssociatedType() {
        let code = """
            struct Test: PropertyInjectable {
                class Dependency {
                    let a: A
                    let b: B
                }

                var dependency: Dependency!
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = PropertyInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testMissingAssociatedType() {
        let code = """
            struct Test: PropertyInjectable {
                var dependency: Dependency!
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = PropertyInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testMissingProperty() {
        let code = """
            struct Test: PropertyInjectable {
                struct Dependency {
                    let a: A
                    let b: B
                }
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = PropertyInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testWrongTypeProperty() {
        let code = """
            struct Test: PropertyInjectable {
                struct Dependency {
                    let a: A
                    let b: B
                }

                var dependency: C!
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = PropertyInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testNonOptionalProperty() {
        let code = """
            struct Test: PropertyInjectable {
                struct Dependency {
                    let a: A
                    let b: B
                }

                var dependency: Dependency
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = PropertyInjectableType(type: type)
        XCTAssertNil(injectableType)
    }
}

