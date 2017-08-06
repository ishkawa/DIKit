import Foundation
import DIKit
import SourceKittenFramework

struct A: Injectable {
    struct Dependency {}
    init(dependency: Dependency) {}
}

struct B: Injectable {
    struct Dependency {
        let ba: A
    }
    
    init(dependency: Dependency) {}
}

struct C: Injectable {
    struct Dependency {
        let ca: A
        let cd: D
    }
    
    init(dependency: Dependency) {}
}

struct D {}

final class Configuration: ResolverConfiguration {
    typealias ProvidableTypes = (D)
}

let file = File(path: #file)!
let structure = Structure(file: file)
let types = structure.substructures.flatMap(Type.init)
let configurations = types.filter { $0.inheritedTypes.contains("ResolverConfiguration") }

guard let configuration = configurations.first, configurations.count == 1 else {
    fatalError("Number of ResolverConfiguration conformers must be exact 1.")
}

// TODO: Get D from cofiguration.
let providableTypeNames = ["D"]

let providables = types.filter { providableTypeNames.contains($0.name) }
let injectables = types.filter { $0.isInjectable }
let graph = try! Graph(injectables: injectables, providables: providables)
print(graph.generateCode().content)


