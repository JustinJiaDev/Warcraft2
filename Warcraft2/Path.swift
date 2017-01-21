//
//  Path.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/20/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class Path {

    private static var delimiter: String = ""

    private static func decomposePath(decomposedPath: inout [String], path: String) -> Bool {
        fatalError("You need to override this method.")
    }

    static func simplifyPath(sourcePath: Path, destinationPath: Path) -> Path {
        fatalError("You need to override this method.")
    }

    static func relativePath(sourcePath: Path, destinationPath: Path) -> Path {
        fatalError("You need to override this method.")
    }

    static var current: Path {
        fatalError("You need to override this method.")
    }

    static func current(path: Path) {
        fatalError("You need to override this method.")
    }

    private var decomposedPath: [String]
    private(set) var isRelative: Bool
    private(set) var isValid: Bool

    var isAbsolute: Bool {
        return !isRelative
    }

    var componentCount: Int {
        return decomposedPath.count
    }

    func component(at index: Int) -> String {
        guard index >= 0 && index < decomposedPath.count else {
            return ""
        }
        return decomposedPath[index]
    }

    var containing: Path {
        fatalError("You need to override this method.")
    }

    init(path: Path) {
        fatalError("You need to override this method.")
    }

    init(string: String) {
        fatalError("You need to override this method.")
    }

    func toString() -> String {
        fatalError("You need to override this method.")
    }

    func simplify(destinationPath: Path) -> Path {
        fatalError("You need to override this method.")
    }

    func relative(destinationPath: Path) -> Path {
        fatalError("You need to override this method.")
    }

}
