import Foundation

enum TerrainMapError: Error {

    case unknownMapFile
    case failedToReadMapName
    case failedToReadMapDimensions
    case invalidMapDimensions
    case failedToReadMapLine
    case mapLineToShort(line: Int)
    case mapHasTwoFewLines(lineCount: Int)
    case unknownTileType
}

class TerrainMap {
    enum TileType: Int {
        case none = 0
        case grass
        case dirt
        case rock
        case tree
        case stump
        case water
        case wall
        case wallDamaged
        case rubble
        case max

        // MARK: Static Functions

        static func from(string: String) -> TileType {
            switch string {
            case string where string.hasPrefix("grass"): return .grass
            case string where string.hasPrefix("dirt"): return .dirt
            case string where string.hasPrefix("tree"): return .tree
            case string where string.hasPrefix("water"): return .water
            case string where string.hasPrefix("rock"): return .rock
            case string where string.hasPrefix("stump"): return .rock
            case string where string.hasPrefix("wall-damaged"): return .wallDamaged
            case string where string.hasPrefix("wall"): return .wall
            case string where string.hasPrefix("rubble"): return .rubble
            default: return .max
            }
        }

        static func from(charCode: Character) -> TileType {
            switch charCode {
            case "G": return .grass
            case "F": return .tree
            case "D": return .dirt
            case "W": return .wall
            case "w": return .wallDamaged
            case "R": return .rock
            case " ": return .water
            default: return .max
            }
        }
    }

    var map: [[TileType]] = []
    private(set) var stringMap: [String] = []
    private(set) var playerCount: Int = 0
    private(set) var mapName: String = ""

    init() {
    }

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

    func loadMap(source: DataSource) throws {
        map.removeAll()
        let lineSource = LineDataSource(dataSource: source)

        guard let mapName = lineSource.readLine() else {
            throw TerrainMapError.failedToReadMapName
        }
        self.mapName = mapName

        guard let dimensionsLine = lineSource.readLine() else {
            throw TerrainMapError.failedToReadMapDimensions
        }
        let tokens = Tokenizer.tokenize(data: dimensionsLine)
        guard tokens.count == 2, let widthString = tokens.first, let heightString = tokens.last else {
            throw TerrainMapError.invalidMapDimensions
        }
        guard let mapWidth = Int(widthString), let mapHeight = Int(heightString), mapWidth > 8 && mapHeight > 8 else {
            throw TerrainMapError.invalidMapDimensions
        }

        while stringMap.count < mapHeight + 2 {
            guard let currentLine = lineSource.readLine() else {
                throw TerrainMapError.failedToReadMapLine
            }
            stringMap.append(currentLine)
            if stringMap.last!.characters.count < mapWidth + 2 {
                throw TerrainMapError.mapLineToShort(line: stringMap.count)
            }
        }

        if stringMap.count < mapHeight + 2 {
            throw TerrainMapError.mapHasTwoFewLines(lineCount: stringMap.count)
        }

        map = stringMap.map { line in
            return line.characters.map { charCode in
                return TileType.from(charCode: charCode)
            }
        }

        try map.forEach { line in
            guard !line.contains(.max) else {
                throw TerrainMapError.unknownTileType
            }
        }
    }
}
