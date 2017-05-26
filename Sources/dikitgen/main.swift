import SourceKittenFramework

protocol Injectable {}

struct A: Injectable {}
struct B: Injectable {
    init(a: A) {}
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

struct ConcreteType {
    let name: String
    let fuctions: [Function]
    let inheritedTypes: [String]

    init?(structure: Structure) {
        guard structure.kind == "source.lang.swift.decl.struct" || structure.kind == "source.lang.swift.decl.class",
            let name = structure.name else {
            return nil
        }

        self.name = name
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
    .flatMap(ConcreteType.init)
    .filter { $0.inheritedTypes.contains("Injectable") }

print(injectableTypes)
