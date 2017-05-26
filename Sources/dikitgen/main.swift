import Foundation
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
        let typeName: String

        init?(structure: Structure) {
            guard structure.kind == .varParameter,
                let name = structure.name,
                let type = structure.typeName else {
                return nil
            }

            self.name = name
            self.typeName = type
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

struct Property {
    let name: String
    let typeName: String

    init(name: String, typeName: String) {
        self.name = name
        self.typeName = typeName
    }

    init?(structure: Structure) {
        guard structure.kind == .varInstance,
            let name = structure.name,
            let typeName = structure.typeName else {
            return nil
        }

        self.name = name
        self.typeName = typeName
    }
}

struct Type {
    private static var declarationKinds: [SwiftDeclarationKind] {
        return [.struct, .class, .enum, .protocol]
    }

    let name: String
    let kind: SwiftDeclarationKind
    let functions: [Function]
    let properties: [Property]
    let inheritedTypes: [String]

    init?(structure: Structure) {
        guard
            let kind = structure.kind, Type.declarationKinds.contains(kind),
            let name = structure.name else {
            return nil
        }

        self.name = name
        self.kind = kind
        self.functions = structure.substructures.flatMap(Function.init)
        self.properties = structure.substructures.flatMap(Property.init)
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

    var typeName: String? {
        return self[.typeName] as? String
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
        return parameters + injectable.functions.reduce([] as [String]) { parameters, function -> [String] in
            return parameters + function.parameters.reduce([] as [String]) { parameters, parameter -> [String] in
                return parameters.contains(parameter.typeName) ? parameters : parameters + [parameter.typeName]
            }
        }
    }

struct GraphError: Error {
    let message: String
}

struct Node {
    let type: Type
    let dependencies: [Node]

    init(name: String, injectables: [Type]) throws {
        guard let type = injectables.filter({ $0.name == name }).first else {
            throw GraphError(message: "Injectable type named \(name) is not found.")
        }

        let initializerParameters = Array(type.functions
            .filter { $0.isInitializer }
            .map { $0.parameters }
            .joined())

        var dependencies: [Node] = []
        for parameter in initializerParameters {
            guard let type = injectables.filter({ $0.name == parameter.typeName}).first else {
                throw GraphError(message: "Injectable type named \(name) is not found.")
            }

            let node = try Node(name: type.name, injectables: injectables)
            dependencies.append(node)
        }

        self.type = type
        self.dependencies = dependencies
    }
}

struct ModuleBuiler {
    let moduleName: String
    let nodes: [Node]
    let publicProperties: [Property]
    let privateProperties: [Property]

    init(blueprint: Type, injectables: [Type]) throws {
        let suffix = "Blueprint"
        guard blueprint.name.hasSuffix(suffix) else {
            throw GraphError(message: "Blueprint type must have suffix \(suffix).")
        }

        self.moduleName = {
            let name = blueprint.name
            return name[name.startIndex..<name.index(name.endIndex, offsetBy: -suffix.characters.count)]
        }()

        self.nodes = try blueprint.properties.map { try Node(name: $0.typeName, injectables: injectables) }

        let publicProperties = blueprint.properties
        var privateProperties = [Property]()
        func extractNode(node: Node) {
            node.dependencies.forEach(extractNode(node:))

            let resolvedTypeNames = publicProperties.map { $0.typeName } + privateProperties.map { $0.typeName }

            if !resolvedTypeNames.contains(node.type.name) {
                var name = node.type.name
                name = name.replacingCharacters(
                    in: name.startIndex..<name.index(name.startIndex, offsetBy: 1),
                    with: String(name[name.startIndex]).lowercased())

                let property = Property(name: name, typeName: node.type.name)
                privateProperties.append(property)
            }
        }

        self.nodes.forEach { extractNode(node: $0) }
        self.publicProperties = publicProperties
        self.privateProperties = privateProperties
    }
}

let blueprints = types.filter { $0.inheritedTypes.contains("ModuleBlueprint") }

for blueprint in blueprints {
    let builder = try! ModuleBuiler(blueprint: blueprint, injectables: injectables)
    print(
        "final class \(builder.moduleName): \(blueprint.name) {\n" +
        "\(builder.publicProperties.map({ "    let \($0.name): \($0.typeName)"}).joined())\n" +
        "\(builder.privateProperties.map({ "    private let \($0.name): \($0.typeName)"}).joined())\n" +
        "}"
    )
}
