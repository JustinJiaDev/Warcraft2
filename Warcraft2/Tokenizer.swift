//
//  Tokenizer.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class Tokenizer {

    private var dataSource: DataSource
    private var delimiters: String

    init(source: DataSource, delimiters: String = "") {
        dataSource = source
        if delimiters.characters.count > 0 {
            self.delimiters = delimiters
        } else {
            self.delimiters = " \t\r\n"
        }
    }

    func read(token: inout String) -> Bool {
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        token = ""
        while true {
            if dataSource.read(data: pointer, length: 1) > 0 {
                let readCharacter = String(UnicodeScalar(pointer.pointee))
                if delimiters.contains(readCharacter) {
                    token += readCharacter
                } else if token.characters.count > 0 {
                    return true
                }
            } else {
                return token.characters.count > 0
            }
        }
    }

    func tokenize(data: String, delimiters: String) -> [String] {
        if delimiters.characters.count > 0 {
            self.delimiters = delimiters
        } else {
            self.delimiters = " \t\r\n"
        }
        var tokens: [String] = []
        var currentToken = ""
        for character in data.characters {
            if !self.delimiters.contains(String(character)) {
                currentToken += String(character)
            } else if currentToken.characters.count > 0 {
                tokens.append(currentToken)
                currentToken = ""
            }
        }
        if currentToken.characters.count > 0 {
            tokens.append(currentToken)
        }
        return tokens
    }
}
