//
//  LineDataSource.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/20/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class LineDataSource {
    private var dataSource: DataSource

    init(source: DataSource) {
        dataSource = source
    }

    func read(line: inout String) -> Bool {
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        line.removeAll()
        while true {
            if dataSource.read(data: pointer, length: 1) > 0 {
                if UnicodeScalar(pointer.pointee) == "\n" {
                    return true
                } else if UnicodeScalar(pointer.pointee) != "\r" {
                    line += String(UnicodeScalar(pointer.pointee))
                }
            } else {
                return line.characters.count > 0
            }
        }
    }
}
