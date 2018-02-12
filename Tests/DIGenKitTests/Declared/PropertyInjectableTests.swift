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
    func test() throws {
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
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = try? PropertyInjectableType(type: type)
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

                var dependency: Dependency!
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try PropertyInjectableType(type: type)
            XCTFail()
        } catch let error as PropertyInjectableType.Error {
            XCTAssertEqual(error.reason, .protocolConformanceNotFound)
        } catch {
            XCTFail()
        }
    }

    func testClassAssociatedType() throws {
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
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try PropertyInjectableType(type: type)
            XCTFail()
        } catch let error as PropertyInjectableType.Error {
            XCTAssertEqual(error.reason, .nonStructAssociatedType)
        } catch {
            XCTFail()
        }
    }

    func testMissingAssociatedType() throws {
        let code = """
            struct Test: PropertyInjectable {
                var dependency: Dependency!
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try PropertyInjectableType(type: type)
            XCTFail()
        } catch let error as PropertyInjectableType.Error {
            XCTAssertEqual(error.reason, .associatedTypeNotFound)
        } catch {
            XCTFail()
        }
    }

    func testMissingProperty() throws {
        let code = """
            struct Test: PropertyInjectable {
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
            _ = try PropertyInjectableType(type: type)
            XCTFail()
        } catch let error as PropertyInjectableType.Error {
            XCTAssertEqual(error.reason, .propertyNotFound)
        } catch {
            XCTFail()
        }
    }

    func testWrongTypeProperty() throws {
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
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try PropertyInjectableType(type: type)
            XCTFail()
        } catch let error as PropertyInjectableType.Error {
            XCTAssertEqual(error.reason, .propertyNotFound)
        } catch {
            XCTFail()
        }
    }

    func testNonOptionalProperty() throws {
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
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try PropertyInjectableType(type: type)
            XCTFail()
        } catch let error as PropertyInjectableType.Error {
            XCTAssertEqual(error.reason, .propertyNotFound)
        } catch {
            XCTFail()
        }
    }
}

