import Foundation
import DIKit
import SourceKittenFramework

struct A: Injectable {
    init() {}
}

struct B: Injectable {
    init(ba: A) {}
}

struct C: Injectable {
    init(ca: A) {}
}

struct D {}

protocol AModuleBlueprint: ModuleBlueprint {
    var b: B { get }
    var c: C { get }
}

extension AModuleBlueprint {
    static func provideD() -> D {
        return D()
    }
}

let file = File(path: #file)!
let structure = Structure(file: file)
let types = structure.substructures.flatMap(Type.init)

let injectables = types.filter { $0.inheritedTypes.contains("Injectable") }
let blueprints = types.filter { $0.inheritedTypes.contains("ModuleBlueprint") }

for blueprint in blueprints {
    let graph = Graph(blueprint: blueprint, injectables: injectables)
    let code = try graph.generateCode()
    print(code.content)
}
