//
//  Findable.swift
//  DIGenKit
//
//  Created by Yosuke Ishikawa on 2017/09/23.
//

import SourceKittenFramework

public protocol Findable {
    var file: File { get }
    var offset: Int64 { get }
}
