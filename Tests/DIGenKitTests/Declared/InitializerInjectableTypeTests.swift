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
    func test() throws {
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
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        let injectableType = try? InitializerInjectableType(type: type)
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

                init(dependency: Dependency) {}
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try InitializerInjectableType(type: type)
            XCTFail()
        } catch let error as InitializerInjectableType.Error {
            XCTAssertEqual(error.reason, .protocolConformanceNotFound)
        } catch {
            XCTFail()
        }
    }

    func testClassAssociatedType() throws {
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
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try InitializerInjectableType(type: type)
            XCTFail()
        } catch let error as InitializerInjectableType.Error {
            XCTAssertEqual(error.reason, .nonStructAssociatedType)
        } catch {
            XCTFail()
        }
    }

    func testMissingAssociatedType() throws {
        let code = """
            struct Test: Injectable {
                init(dependency: Dependency) {}
            }
            """

        let file = File(contents: code)
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try InitializerInjectableType(type: type)
            XCTFail()
        } catch let error as InitializerInjectableType.Error {
            XCTAssertEqual(error.reason, .associatedTypeNotFound)
        } catch {
            XCTFail()
        }
    }

    func testMissingInitializer() throws {
        let code = """
            struct Test: Injectable {
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
            _ = try InitializerInjectableType(type: type)
            XCTFail()
        } catch let error as InitializerInjectableType.Error {
            XCTAssertEqual(error.reason, .initializerNotFound)
        } catch {
            XCTFail()
        }
    }

    func testWrongTypeInitializer() throws {
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
        let structure = try Structure(file: file).substructures.first!
        let type = Type(structure: structure, file: file)!
        do {
            _ = try InitializerInjectableType(type: type)
            XCTFail()
        } catch let error as InitializerInjectableType.Error {
            XCTAssertEqual(error.reason, .initializerNotFound)
        } catch {
            XCTFail()
        }
    }
}
