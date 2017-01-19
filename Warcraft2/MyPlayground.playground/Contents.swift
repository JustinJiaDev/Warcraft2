//: Playground - noun: a place where people can play

import UIKit

var text: String = ""

if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

    // let path = dir.absoluteString("../data/img/Terrain.dat")
    let path = dir.appendingPathComponent("../data/img/Terrain.dat")
    print(path)

    do {
        text = try String(contentsOf: path, encoding: String.Encoding.utf8)
    } catch {
        print("Error loading terrain .dat file")
    }

    // Discard line 1
    // Read line 2 and make it the size of the return array
    // Read remaining lines, interpreting each as an ETileType

    let lines: [String] = text.components(separatedBy: "\n")

    print(lines.count)

    for item in lines {
        print(item)
    }
}
