import Foundation
import DIGenKit

guard CommandLine.arguments.count == 2 else {
    print("error: invalid arguments")
    print("usage: dikitgen <path to source code directory>")
    exit(1)
}

if CommandLine.arguments[1] == "--version" {
    print(Version.current)
    exit(0)
}

let path = CommandLine.arguments[1]

do {
    let generator = try CodeGenerator(path: path)
    print(try generator.generate())
} catch let anyError {
    guard
        let error = anyError as? (Error & Findable),
        let path = error.file.path else {
        print("error: \(anyError.localizedDescription)")
        exit(1)
    }

    var lineNumber = 1
    for line in error.file.lines {
        if line.range.contains(Int(error.offset)) {
            break
        }
        lineNumber += 1
    }

    print("\(path):\(lineNumber): error: \(error.localizedDescription)")
    exit(1)
}

