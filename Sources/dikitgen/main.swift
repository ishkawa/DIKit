import Foundation
import DIKit
import SourceKittenFramework

struct A: Injectable {}
struct B: Injectable {
    init(a: A) {}
}

protocol AModuleBlueprint: ModuleBlueprint {
    var b: B { get }
}

let file = File(path: #file)!
let structure = Structure(file: file)
let types = structure.substructures.flatMap(Type.init)

let injectables = types.filter { $0.inheritedTypes.contains("Injectable") }
let parameters = injectables
    .reduce([] as [String]) { parameters, injectable -> [String] in
        return parameters + injectable.functions.reduce([] as [String]) { parameters, function -> [String] in
            return parameters + function.parameters.reduce([] as [String]) { parameters, parameter -> [String] in
                return parameters.contains(parameter.typeName) ? parameters : parameters + [parameter.typeName]
            }
        }
    }

let blueprints = types.filter { $0.inheritedTypes.contains("ModuleBlueprint") }

for blueprint in blueprints {
    let builder = try! ModuleBuiler(blueprint: blueprint, injectables: injectables)
    print(builder.build())
}
