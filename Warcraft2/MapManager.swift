//
//  MapManager.swift
//  Warcraft2
//
//  Created by Andrew van Tonningen on 1/19/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation
import SpriteKit

class MapManager {

    var mapFileName = ".map"
    var mapTileTypes: [[TerrainManager.ETileType]] =
        Array(repeating: Array(repeating: .ttGrass, count: 20), count: 20)

    func loadMap() {

        // In future, will load .map file

        // Load map width and height

        // Load map tile types
    }
}
