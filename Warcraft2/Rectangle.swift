//
//  Retangle.swift
//  Warcraft2
//
//  Created by Bryce Korte on 1/16/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

struct Rectangle {
    var xPosition = 0
    var yPosition = 0
    var width = 0
    var height = 0

    func contains(x: Int, y: Int) -> Bool {
        return (x >= xPosition) && (x < xPosition + width)
            && (y >= yPosition) && (y < yPosition + height)
    }
}
