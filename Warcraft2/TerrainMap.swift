//
//  TerrainMap.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/20/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class TerrainMap {
    enum TileType {
        case none, grass, dirt, rock, tree, stump, water, wall, wallDamaged, rubble, max
    }

    private(set) var map: [[TileType]] = []
    private(set) var stringMap: [String] = []
    private(set) var playerCount: Int = 0
    private(set) var mapName: String = ""

    init(terrainMap: TerrainMap) {
        map = terrainMap.map
        stringMap = terrainMap.stringMap
        playerCount = terrainMap.playerCount
        mapName = terrainMap.mapName
    }

    var width: Int {
        return map.count > 0 ? map[0].count - 2 : 0
    }

    var height: Int {
        return map.count - 2
    }

    func tileTypeAt(x: Int, y: Int) -> TileType {
        switch (x, y) {
        case (x, y) where x < -1 || y < -1: return .none
        case (x, y) where y + 1 >= map.count: return .none
        case (x, y) where x + 1 >= map[y + 1].count: return .none
        default: return map[y + 1][x + 1]
        }
    }

    func tileTypeAt(position: Position) -> TileType {
        return tileTypeAt(x: position.x, y: position.y)
    }

    func findNearestTileType(position: Position, type: TileType) -> Position {
        let maxDistance = max(width, height)
        let xOffset = position.x + 1, yOffset = position.y + 1
        for searchDistance in 0 ..< maxDistance {
            var positiveX = xOffset + searchDistance, negativeX = xOffset - searchDistance
            var positiveY = yOffset + searchDistance, negativeY = yOffset - searchDistance
            var searchPX = true, searchNX = true, searchPY = true, searchNY = true
            if negativeX <= 0 {
                negativeX = 1
                searchNX = false
            }
            if positiveX + 1 >= map[0].count {
                positiveX = width
                searchPX = false
            }
            if negativeY <= 0 {
                negativeY = 1
                searchNY = false
            }
            if positiveY + 1 >= map.count {
                positiveY = height
                searchPY = false
            }
            guard searchPX || searchNX || searchPY || searchNY else {
                break
            }
            if searchNY {
                for x in negativeX ... positiveX where type == map[negativeY][x] {
                    return Position(x: x - 1, y: negativeY - 1)
                }
            }
            if searchPX {
                for y in negativeY ... positiveY where type == map[y][positiveX] {
                    return Position(x: positiveX - 1, y: y - 1)
                }
            }
            if searchPY {
                for x in (negativeX ... positiveX).reversed() where type == map[positiveY][x] {
                    return Position(x: x - 1, y: positiveY - 1)
                }
            }
            if searchNX {
                for y in (negativeY ... positiveY).reversed() where type == map[y][negativeX] {
                    return Position(x: negativeX - 1, y: y - 1)
                }
            }
        }
        return Position(x: -1, y: -1)
    }

    func changeTileType(x: Int, y: Int, to type: TileType) {
        guard tileTypeAt(x: x, y: y) != .none else {
            return
        }
        map[y + 1][x + 1] = type
    }

    func changeTileType(position: Position, to type: TileType) {
        changeTileType(x: position.x, y: position.y, to: type)
    }

    // TODO: Port this method
    func loadMap(source: DataSource) -> Bool {
        fatalError("You need to override this method.")
    }
}
