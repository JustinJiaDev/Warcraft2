//
//  Retangle.swift
//  Warcraft2
//
//  Created by Bryce Korte on 1/16/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

struct SRectangle {
    var dxPosition = 0
    var dyPosition = 0
    var dWidth = 0
    var dHeight = 0

    func PointInside(x: Int, y: Int) -> Bool {
        return (x >= dxPosition) && (x < dxPosition + dWidth)
            && (y >= dyPosition) && (y < dyPosition + dHeight)
    }
}
