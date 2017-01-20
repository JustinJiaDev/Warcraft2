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
    var mapTileTypes: [[TerrainManager.ETileType]] = [
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
        [.ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass, .ttGrass],
    ]

    var mapWidth = 20 // Set in loadMap
    var mapHeight = 20 // Set in loadMap

    func loadMap() {

        // In future, will load .map file

        // Load map width and height

        // Load map tile types
    }
}
