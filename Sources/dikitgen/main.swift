import Foundation
import DIGenKit

guard CommandLine.arguments.count == 2 else {
    print("error: invalid arguments")
    print("usage: dikitgen <path to source code directory>")
    exit(1)
}

let path = CommandLine.arguments[1]
let generator = CodeGenerator(path: path)
print(try generator.generate())
