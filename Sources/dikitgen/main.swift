import Foundation
import DIGenKit

enum Mode {
    case version
    case generate(path: String, excluding: [String])
}
struct InvalidArgumentsError: Error {}
func mode(from arguments: [String]) throws -> Mode {
    switch arguments.count {
    case 2 where arguments[1] == "--version":
        return .version
    case 2:
        return .generate(path: arguments[1], excluding: [])
    case 3..<Int.max:
        let path = arguments[1]
        var exclusions: [String] = []

        var options = arguments.suffix(from: 2).map { $0 }
        while options.count >= 2 {
            let key = options[0]
            let value = options[1]
            switch key {
            case "--exclude": exclusions.append(value)
            case _: throw InvalidArgumentsError()
            }
            options.removeFirst(2)
        }
        if !options.isEmpty {
            throw InvalidArgumentsError()
        }
        return .generate(path: path, excluding: exclusions)
    case _:
        throw InvalidArgumentsError()
    }
}

let path: String
let exclusions: [String]
do {
    switch try mode(from: CommandLine.arguments) {
    case .version:
        print(Version.current)
        exit(0)
    case .generate(let p, let xs):
        path = p
        exclusions = xs
    }
} catch {
    print("error: invalid arguments", to: &standardError)
    print("usage: dikitgen <path to source code directory> [[--exclude <subpath>] ...]", to: &standardError)
    exit(1)
}

do {
    let generator = try CodeGenerator(path: path, excluding: exclusions)
    print(try generator.generate())
} catch let anyError {
    guard
        let error = anyError as? (Error & Findable),
        let path = error.file.path else {
        print("error: \(anyError.localizedDescription)", to: &standardError)
        exit(1)
    }

    var lineNumber = 1
    for line in error.file.lines {
        if line.range.contains(Int(error.offset)) {
            break
        }
        lineNumber += 1
    }

    print("\(path):\(lineNumber): error: \(error.localizedDescription)", to: &standardError)
    exit(1)
}
