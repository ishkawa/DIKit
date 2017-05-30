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
    init(ca: A, cd: D) {}
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
let extensions = structure.substructures.flatMap(Extension.init)

let blueprints = types.filter { $0.inheritedTypes.contains("ModuleBlueprint") }

for blueprint in blueprints {
    let blueprintExtension = extensions
        .filter { $0.name == blueprint.name }
        .first
    
    let graph = Graph(blueprint: blueprint, blueprintExtension: blueprintExtension, types: types)
    let code = try graph.generateCode()
    print(code.content)
}
