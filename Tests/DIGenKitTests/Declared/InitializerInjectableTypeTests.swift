//
//  InitializerInjectableTypeTests.swift
//  DIGenKitTests
//
//  Created by Yosuke Ishikawa on 2017/09/21.
//

import Foundation
import XCTest
import SourceKittenFramework

@testable import DIGenKit

final class InitializerInjectableTypeTests: XCTestCase {
    func test() {
        let code = """
            struct Test: Injectable {
                struct Dependency {
                    let a: A
                    let b: B
                }

                init(dependency: Dependency) {}
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = InitializerInjectableType(type: type)
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

                init(dependency: Dependency) {}
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = InitializerInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testClassAssociatedType() {
        let code = """
            struct Test: Injectable {
                class Dependency {
                    let a: A
                    let b: B
                }

                init(dependency: Dependency) {}
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = InitializerInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testMissingAssociatedType() {
        let code = """
            struct Test: Injectable {
                init(dependency: Dependency) {}
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = InitializerInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testMissingInitializer() {
        let code = """
            struct Test: Injectable {
                struct Dependency {
                    let a: A
                    let b: B
                }
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = InitializerInjectableType(type: type)
        XCTAssertNil(injectableType)
    }

    func testWrongTypeInitializer() {
        let code = """
            struct Test: Injectable {
                struct Dependency {
                    let a: A
                    let b: B
                }

                init(dependency: A) {}
            }
            """

        let file = File(contents: code)
        let structure = Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = InitializerInjectableType(type: type)
        XCTAssertNil(injectableType)
    }
}
