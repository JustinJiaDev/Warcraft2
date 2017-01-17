//
//  Retangle.swift
//  Warcraft2
//
//  Created by Bryce Korte on 1/16/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import CoreGraphics

// Version A:
//
// struct Rectangle {
//     var xPosition = 0
//     var yPosition = 0
//     var width = 0
//     var height = 0
//
//     func pointInside(x: Int, y: Int) -> Bool {
//         return (x >= xPosition) && (x < xPosition + width)
//             && (y >= yPosition) && (y < yPosition + height)
//     }
// }
//
// Usuage
//
// Rectangle(xPosition: 10, yPosition: 10, width: 100, height: 100).pointInside(x: 80, y: 23)

// Version B:
//
// typealias Rectangle = CGRect
// extension Rectangle {
//     func pointInside(x: CGFloat, y: CGFloat) -> Bool {
//         return contains(CGPoint(x: x, y: y))
//     }
// }
//
// Usuage
//
// Rectangle(x: 10, y: 10, width: 100, height: 100).pointInside(x: 80, y: 23)

// Version C:
//
// Use `CGRect` directly
//
// Example:
//
// CGRect(x: 10, y: 10, width: 100, height: 100).contains(CGPoint(x: 80, y: 23))
