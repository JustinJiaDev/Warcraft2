class RouterMap {

    struct searchTarget {
        var x: Int
        var y: Int
        var steps: Int
        var tileType: TerrainMap.TileType
        var targetDistanceSquared: Int
        var inDirection: Direction
    }

    var map: [[Int]] = []
    var searchTargets: [searchTarget] = []

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

    func findRoute(resMap: AssetDecoratedMap, resource: PlayerAsset, target: Position) -> Direction {
        fatalError("not yet ported")
    }
}
