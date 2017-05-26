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
            guard structure.kind == "source.lang.swift.decl.var.parameter",
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
        guard structure.kind == "source.lang.swift.decl.function.method.instance",
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.parameters = structure.substructures.flatMap(Parameter.init)
    }
}

struct Type {
    enum Kind: String {
        case `struct`   = "source.lang.swift.decl.struct"
        case `class`    = "source.lang.swift.decl.class"
        case `enum`     = "source.lang.swift.decl.enum"
        case `protocol` = "source.lang.swift.decl.protocol"
    }
    
    let name: String
    let kind: Kind
    let fuctions: [Function]
    let inheritedTypes: [String]

    init?(structure: Structure) {
        guard
            let kind = structure.kind.flatMap(Kind.init(rawValue:)),
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.kind = kind
        self.fuctions = structure.substructures.flatMap(Function.init)
        self.inheritedTypes = (structure.dictionary["key.inheritedtypes"] as? [[String: SourceKitRepresentable]])?
            .flatMap { $0["key.name"] as? String } ?? []
    }
}

extension Structure {
    var name: String? {
        return dictionary["key.name"] as? String
    }

    var kind: String? {
        return dictionary["key.kind"] as? String
    }

    var substructures: [Structure] {
        guard let dictionaries = dictionary["key.substructure"] as? [[String: SourceKitRepresentable]] else {
            return []
        }

        return dictionaries.map { Structure(sourceKitResponse: $0) }
    }
}

let file = File(path: #file)!
let structure = Structure(file: file)
let injectableTypes = structure.substructures
    .flatMap(Type.init)
    .filter { $0.inheritedTypes.contains("Injectable") }

injectableTypes.forEach { print($0, "\n") }
