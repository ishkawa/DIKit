import Foundation
import DIKit

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

protocol DemoResolver: DIKit.Resolver {
    func provideD() -> D
}

guard CommandLine.arguments.count == 2 else {
    print("error: invalid arguments")
    print("usage: dikitgen <path to source code directory>")
    exit(1)
}

let path = CommandLine.arguments[1]
let generator = CodeGenerator(path: path)
print(try generator.generate())
