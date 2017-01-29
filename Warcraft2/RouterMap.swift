class RouterMap {

    struct SearchTarget {
        var x: Int
        var y: Int
        var steps: Int
        var tileType: TerrainMap.TileType
        var targetDistanceSquared: Int
        var inDirection: Direction
    }
    
    enum SearchStatus {
        case unvisited
        case visited
        case occupied
    }

    var map: [[SearchStatus]] = []
    var searchTargets: [SearchTarget] = []

    static var idealSearchDirection = Direction.north
    static var mapWidth = 1

    static func movingAway(dir1: Direction, dir2: Direction) -> Bool {
        if 0 > dir2.rawValue || Direction.max.rawValue <= dir2.rawValue {
            return false
        }
        let value = Direction.max.rawValue + dir2.rawValue - dir1.rawValue % Direction.max.rawValue
        if 1 >= value || Direction.max.rawValue - 1 <= value {
            return true
        }
        return false
    }

    func findRoute(resMap: AssetDecoratedMap, asset: PlayerAsset, target: Position) -> Direction {
        fatalError("not yet ported (code is incomplete and has not been checked for correctness)")
        let mapWidth = resMap.width
        let mapHeight = resMap.height
        let startX = asset.tilePositionX()
        let startY = asset.tilePositionY()
        var currentSearch, bestSearch, tempSearch: SearchTarget
        var currentTile, targetTile, tempTile: Position
        var searchDirections: [Direction] = [.north, .east, .south, .west]
        let resMapXOffsets = [0,1,0,-1]
        let resMapYOffsets = [-1,0,1,0]
        let diagCheckXOffset = [0,1,1,1,0,-1,-1,-1]
        let diagCheckYOffset = [-1,-1,0,1,1,1,0,-1]
        var lastInDirection, directionBeforeLast: Direction
        var searchQueueArray: [SearchTarget] = []
        
        targetTile.setToTile(target)
        if map.count != mapHeight + 2 || map[0].count != mapWidth + 2 {
            let lastYIndex = mapHeight + 1
            let lastXIndex = mapWidth + 1
            map = Array(repeating: Array(repeating: .unvisited, count: mapWidth + 2), count: mapHeight + 2)
            for index in 0..<map.count {
                map[index][0] = .visited
                map[index][lastXIndex] = .visited
            }
            for index in 0..<mapWidth {
                map[0][index+1] = .visited
                map[lastYIndex][index+1] = .visited
            }
            RouterMap.mapWidth = mapWidth + 2
        }
        
        if asset.tilePosition == targetTile {
            let deltaX = target.x - asset.positionX()
            let deltaY = target.y - asset.positionY()
            
            if 0 < deltaX {
                if 0 < deltaY {
                    return .northWest
                }
            }
        }
    }
}
