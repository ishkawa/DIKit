//
//  StandardError.swift
//  dikitgen
//
//  Created by Yosuke Ishikawa on 2017/11/12.
//

import Foundation

var standardError = FileHandle.standardError

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}
