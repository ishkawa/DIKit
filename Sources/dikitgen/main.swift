import SourceKittenFramework

protocol Injectable {}
protocol ModuleBlueprint {}

struct A: Injectable {}
struct B: Injectable {
    init(a: A) {}
}

protocol AModuleBlueprint: ModuleBlueprint {
    var b: B { get }
}

struct Function {
    struct Parameter {
        let name: String
        let type: String

        init?(structure: Structure) {
            guard structure.kind == .varParameter,
                let name = structure.name,
                let type = structure.dictionary["key.typename"] as? String else {
                return nil
            }

            self.name = name
            self.type = type
        }
    }

    let name: String
    let parameters: [Parameter]

    var isInitializer: Bool {
        return name.hasPrefix("init(")
    }

    init?(structure: Structure) {
        guard structure.kind == .functionMethodInstance,
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.parameters = structure.substructures.flatMap(Parameter.init)
    }
}

struct Type {
    private static var declarationKinds: [SwiftDeclarationKind] {
        return [.struct, .class, .enum, .protocol]
    }

    let name: String
    let kind: SwiftDeclarationKind
    let fuctions: [Function]
    let inheritedTypes: [String]

    init?(structure: Structure) {
        guard
            let kind = structure.kind, Type.declarationKinds.contains(kind),
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.kind = kind
        self.fuctions = structure.substructures.flatMap(Function.init)
        self.inheritedTypes = (structure[.inheritedtypes] as? [[String: SourceKitRepresentable]])?
            .flatMap { $0["key.name"] as? String } ?? []
    }
}

extension Structure {
    subscript(key: SwiftDocKey) -> SourceKitRepresentable? {
        get {
            return dictionary[key.rawValue]
        }
        set {
            var dictionary = self.dictionary
            dictionary[key.rawValue] = newValue
            self = Structure(sourceKitResponse: dictionary)
        }
    }

    var name: String? {
        return self[.name] as? String
    }

    var kind: SwiftDeclarationKind? {
        return (self[.kind] as? String).flatMap(SwiftDeclarationKind.init)
    }

    var substructures: [Structure] {
        guard let dictionaries = self[.substructure] as? [[String: SourceKitRepresentable]] else {
            return []
        }

        return dictionaries.map(Structure.init(sourceKitResponse:))
    }
}

let file = File(path: #file)!
let structure = Structure(file: file)
let types = structure.substructures.flatMap(Type.init)

let injectables = types.filter { $0.inheritedTypes.contains("Injectable") }
let parameters = injectables
    .reduce([] as [String]) { parameters, injectable -> [String] in
        return parameters + injectable.fuctions.reduce([] as [String]) { parameters, function -> [String] in
            return parameters + function.parameters.reduce([] as [String]) { parameters, parameter -> [String] in
                return parameters.contains(parameter.type) ? parameters : parameters + [parameter.type]
            }
        }
    }

injectables.forEach { print($0, "\n") }
parameters.forEach { print($0, "\n") }

let blueprints = types.filter { $0.inheritedTypes.contains("ModuleBlueprint") }
print(blueprints)
