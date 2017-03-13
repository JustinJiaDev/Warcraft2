class MapRenderer {

    enum GameError: Error {
        case failedToReadItemCount
        case failedToReadItemLine
        case failedToReadColor(string: String)
        case invalidItemLine(string: String)
        case invalidColorHex(string: String)
        case failedToReadSecondItemCount
        case failedToReadSecondItemLine
        case invalidSourceIndexHex(string: String)
        case invalidType(String: String)
    }

    private var tileset: GraphicTileset
    private var map: TerrainMap
    private var grassIndices: [Int] = []
    private var treeIndices: [Int] = []
    private var dirtIndices: [Int] = []
    private var waterIndices: [Int] = []
    private var rockIndices: [Int] = []
    private var wallIndices: [Int] = []
    private var wallDamagedIndices: [Int] = []
    private var pixelIndices: [Int] = []

    private var treeUnknown: [Int: Int] = [:]
    private var waterUnknown: [Int: Int] = [:]
    private var dirtUnknown: [Int: Int] = [:]
    private var rockUnknown: [Int: Int] = [:]

    private var unknownTree: [Bool] = []
    private var unknownWater: [Bool] = []
    private var unknownDirt: [Bool] = []
    private var unknownRock: [Bool] = []
    private var unknownUnknownTree: [Int: Bool] = [:]
    private var unknownUnknownWater: [Int: Bool] = [:]
    private var unknownUnknownDirt: [Int: Bool] = [:]
    private var unknownUnknownRock: [Int: Bool] = [:]

    var mapWidth: Int {
        return map.width
    }

    var mapHeight: Int {
        return map.height
    }

    var detailedMapWidth: Int {
        return map.width * tileset.tileWidth
    }

    var detailedMapHeight: Int {
        return map.height * tileset.tileHeight
    }

    private static func number(fromHexString string: String) -> Int? {
        guard string.hasPrefix("0x") || string.hasPrefix("0X") else {
            return nil
        }
        return Int(string.substring(from: string.index(string.startIndex, offsetBy: 2)), radix: 16)
    }

    private func makeHammingSet(value: Int, hammingSet: inout [Int]) {
        var bitCount: Int
        var anchor = 0
        var lastEnd: Int
        hammingSet.removeAll()

        for index in 0 ..< 8 {
            let val = 1 << index
            if val & value != 0 {
                hammingSet.append(val)
            }
        }

        lastEnd = hammingSet.count
        bitCount = hammingSet.count

        if bitCount > 0 {
            for _ in 1 ..< bitCount {
                for lastIndex in anchor ..< lastEnd {
                    for bitIndex in 0 ..< bitCount {
                        let newValue = hammingSet[lastIndex] | hammingSet[bitIndex]
                        if newValue != hammingSet[lastIndex] {
                            var found = false
                            for index in lastEnd ..< hammingSet.count {
                                if newValue == hammingSet[index] {
                                    found = true
                                    break
                                }
                            }
                            if !found {
                                hammingSet.append(newValue)
                            }
                        }
                    }
                }
                anchor = lastEnd + 1
                lastEnd = hammingSet.count
            }
        }
    }

    func findUnknown(type: TerrainMap.TileType, known: Int, unknown: Int) -> Int {
        if type == .tree {
            if let val = treeUnknown[(known << 8) | unknown] {
                return val
            }
            var hammingSet = [Int]()
            makeHammingSet(value: unknown, hammingSet: &hammingSet)
            for value in hammingSet {
                if treeIndices[known | value] != -1 {
                    treeUnknown[(known << 8) | unknown] = treeIndices[known | value]
                    return treeIndices[known | value]
                }
            }
        } else if type == .water {
            if let val = waterUnknown[(known << 8) | unknown] {
                return val
            }
            var hammingSet = [Int]()
            makeHammingSet(value: unknown, hammingSet: &hammingSet)
            for value in hammingSet {
                if waterIndices[known | value] != -1 {
                    waterUnknown[(known << 8) | unknown] = waterIndices[known | value]
                    return waterIndices[known | value]
                }
            }
        } else if type == .dirt {
            if let val = dirtUnknown[(known << 8) | unknown] {
                return val
            }
            var hammingSet = [Int]()
            makeHammingSet(value: unknown, hammingSet: &hammingSet)
            for value in hammingSet {
                if dirtIndices[known | value] != -1 {
                    dirtUnknown[(known << 8) | unknown] = dirtIndices[known | value]
                    return dirtIndices[known | value]
                }
            }
        } else if type == .rock {
            if let val = rockUnknown[(known << 8) | unknown] {
                return val
            }
            var hammingSet = [Int]()
            makeHammingSet(value: unknown, hammingSet: &hammingSet)
            for value in hammingSet {
                if rockIndices[known | value] != -1 {
                    rockUnknown[(known << 8) | unknown] = rockIndices[known | value]
                    return rockIndices[known | value]
                }
            }
        }
        return -1
    }

    init(configuration: DataSource, tileset: GraphicTileset, map: TerrainMap) throws {
        self.tileset = tileset
        self.map = map
        self.pixelIndices = Array(repeating: -1, count: TerrainMap.TileType.max.rawValue)

        let lineSource = LineDataSource(dataSource: configuration)

        guard let itemCountString = lineSource.readLine(), let itemCount = Int(itemCountString) else {
            throw GameError.failedToReadItemCount
        }

        for _ in 0 ..< itemCount {
            guard let currentLine = lineSource.readLine() else {
                throw GameError.failedToReadItemLine
            }
            let tokens = Tokenizer.tokenize(data: currentLine)
            guard tokens.count >= 2 else {
                throw GameError.invalidItemLine(string: currentLine)
            }
            let pixelType = TerrainMap.TileType.from(string: tokens[0])
            guard let colorHex = MapRenderer.number(fromHexString: tokens[1]), colorHex >= 0 else {
                throw GameError.invalidColorHex(string: tokens[1])
            }
            pixelIndices[pixelType.rawValue] = colorHex
        }

        var index = 0
        while true {
            let value = self.tileset.findTile("grass-\(index)")
            if value < 0 {
                break
            }
            grassIndices.append(value)
            index += 1
        }

        for index in 0 ..< 0x40 {
            treeIndices.append(self.tileset.findTile("tree-\(index)"))
        }

        for index in 0 ..< 0x100 {
            dirtIndices.append(self.tileset.findTile("dirt-\(index)"))
        }

        for index in 0 ..< 0x100 {
            waterIndices.append(self.tileset.findTile("water-\(index)"))
        }

        waterIndices[0x00] = dirtIndices[0xff]

        for index in 0 ..< 0x100 {
            rockIndices.append(self.tileset.findTile("rock-\(index)"))
        }

        for index in 0 ..< 0x10 {
            wallIndices.append(self.tileset.findTile("wall-\(index)"))
        }

        for index in 0 ..< 0x10 {
            wallDamagedIndices.append(self.tileset.findTile("wall-damaged-\(index)"))
        }

        guard let secondItemCountString = lineSource.readLine(), let secondItemCount = Int(secondItemCountString) else {
            throw GameError.failedToReadItemCount
        }

        for _ in 0 ..< secondItemCount {
            guard let currentLine = lineSource.readLine() else {
                throw GameError.failedToReadSecondItemLine
            }
            let tokens = Tokenizer.tokenize(data: currentLine)
            guard tokens.count >= 3 else {
                throw GameError.invalidItemLine(string: currentLine)
            }
            let indices = try tokens.dropFirst().map { token -> Int in
                guard let index = MapRenderer.number(fromHexString: token) else {
                    throw GameError.invalidSourceIndexHex(string: token)
                }
                return index
            }
            switch tokens[0] {
            case "dirt": for i in 1 ..< indices.count { dirtIndices[indices[i]] = dirtIndices[indices[0]] }
            case "rock": for i in 1 ..< indices.count { rockIndices[indices[i]] = rockIndices[indices[0]] }
            case "tree": for i in 1 ..< indices.count { treeIndices[indices[i]] = treeIndices[indices[0]] }
            case "water": for i in 1 ..< indices.count { waterIndices[indices[i]] = waterIndices[indices[0]] }
            case "wall": for i in 1 ..< indices.count { wallIndices[indices[i]] = wallIndices[indices[0]] }
            case "wall-damaged": for i in 1 ..< indices.count { wallDamagedIndices[indices[i]] = wallDamagedIndices[indices[0]] }
            default: throw GameError.invalidType(String: tokens[0])
            }
        }
    }

    func drawBottomLevelMap(on surface: GraphicSurface, in rect: Rectangle) {
        unknownTree = Array(repeating: false, count: 0x100)
        unknownWater = Array(repeating: false, count: 0x100)
        unknownDirt = Array(repeating: false, count: 0x100)
        unknownRock = Array(repeating: false, count: 0x100)
        unknownUnknownTree = [:]
        unknownUnknownWater = [:]
        unknownUnknownDirt = [:]
        unknownUnknownRock = [:]

        let tileWidth = tileset.tileWidth
        let tileHeight = tileset.tileHeight

        var displayIndex = -1
        var yIndex = rect.y / tileHeight
        for y in stride(from: -(rect.y % tileHeight), to: rect.height, by: tileHeight) {
            var xIndex = rect.x / tileWidth
            for x in stride(from: -(rect.x % tileWidth), to: rect.width, by: tileWidth) {
                let tileType = map.tileTypeAt(x: xIndex, y: yIndex)
                switch tileType {
                case .tree:
                    let (treeIndex, unknownMask) = findIndexAndUnknownMask(types: [.tree], x: xIndex, y: yIndex, yRange: [0, 1], xRange: [ -1, 0, 1], checkZeros: false)
                    if treeIndices[treeIndex] == -1 {
                        if !unknownTree[treeIndex] && unknownMask == 0 {
                            printError("Unknown tree \(treeIndex) @ (\(xIndex), \(yIndex))")
                            unknownTree[treeIndex] = true
                        }
                        displayIndex = findUnknown(type: .tree, known: treeIndex, unknown: unknownMask)
                        if displayIndex == -1 {
                            if unknownUnknownTree[(treeIndex << 8) | unknownMask] == nil {
                                unknownUnknownTree[(treeIndex << 8) | unknownMask] = true
                                printError("Unknown tree \(treeIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                            }
                        }
                    } else {
                        displayIndex = treeIndices[treeIndex]
                    }
                case .water:
                    let (waterIndex, unknownMask) = findIndexAndUnknownMask(types: [.water], x: xIndex, y: yIndex, yRange: [ -1, 0, 1], xRange: [ -1, 0, 1], checkZeros: true)
                    if waterIndices[waterIndex] == -1 {
                        if !unknownWater[waterIndex] && unknownMask == 0 {
                            printError("Unknown water \(waterIndex) @ (\(xIndex), \(yIndex))")
                            unknownWater[waterIndex] = true
                        }
                        displayIndex = findUnknown(type: .water, known: waterIndex, unknown: unknownMask)
                        if displayIndex == -1 {
                            if unknownUnknownWater[(waterIndex << 8) | unknownMask] == nil {
                                unknownUnknownWater[(waterIndex << 8) | unknownMask] = true
                                printError("Unknown water \(waterIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                            }
                        }
                    } else {
                        displayIndex = waterIndices[waterIndex]
                    }
                case .grass:
                    let (otherIndex, unknownMask) = findIndexAndUnknownMask(types: [.water, .dirt, .rock], x: xIndex, y: yIndex, yRange: [ -1, 0, 1], xRange: [ -1, 0, 1], checkZeros: true)
                    if otherIndex == 0 {
                        displayIndex = grassIndices[0x00]
                    } else if dirtIndices[otherIndex] == -1 {
                        if !unknownDirt[otherIndex] && unknownMask == 0 {
                            printError("Unknown dirt \(otherIndex) @ (\(xIndex), \(yIndex))")
                            unknownDirt[otherIndex] = true
                        }
                        displayIndex = findUnknown(type: .dirt, known: otherIndex, unknown: unknownMask)
                        if displayIndex == -1, unknownUnknownDirt[(otherIndex << 8) | unknownMask] == nil {
                            unknownUnknownDirt[(otherIndex << 8) | unknownMask] = true
                            printError("Unknown dirt \(otherIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                        }
                    } else {
                        displayIndex = dirtIndices[otherIndex]
                    }
                case .rock:
                    let (rockIndex, unknownMask) = findIndexAndUnknownMask(types: [.rock], x: xIndex, y: yIndex, yRange: [ -1, 0, 1], xRange: [ -1, 0, 1], checkZeros: true)
                    if rockIndices[rockIndex] == -1 {
                        if !unknownRock[rockIndex] && unknownMask == 0 {
                            printError("Unknown rock \(rockIndex) @ (\(xIndex), \(yIndex))")
                            unknownRock[rockIndex] = true
                        }
                        displayIndex = findUnknown(type: .rock, known: rockIndex, unknown: unknownMask)
                        if displayIndex == -1 {
                            if unknownUnknownRock[(rockIndex << 8) | unknownMask] == nil {
                                unknownUnknownRock[(rockIndex << 8) | unknownMask] = true
                                printError("Unknown rock \(rockIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                            }
                        }
                    } else {
                        displayIndex = rockIndices[rockIndex]
                    }
                case .wall, .wallDamaged:
                    var wallIndex = 0, wallMask = 0x1
                    let offsets = [(0, -1), (1, 0), (0, 1), (-1, 0)]
                    for (xOffset, yOffset) in offsets {
                        let tile = map.tileTypeAt(x: xIndex + xOffset, y: yIndex + yOffset)
                        if [.wall, .wallDamaged, .rubble].contains(tile) {
                            wallIndex |= wallMask
                        }
                        wallMask <<= 1
                    }
                    displayIndex = tileType == .wall ? wallIndices[wallIndex] : wallDamagedIndices[wallIndex]
                default:
                    displayIndex = {
                        switch map.tileTypeAt(x: xIndex, y: yIndex) {
                        case .grass: return grassIndices[0x00]
                        case .dirt: return dirtIndices[0xff]
                        case .rock: return rockIndices[0x00]
                        case .tree, .stump: return treeIndices[0x00]
                        case .water: return waterIndices[0x00]
                        case .wall, .rubble: return wallIndices[0x00]
                        case .wallDamaged: return wallDamagedIndices[0x00]
                        default: return -1
                        }
                    }()
                }
                if displayIndex != -1 {
                    tileset.drawTile(on: surface, x: x, y: y, index: displayIndex)
                }
                xIndex += 1
            }
            yIndex += 1
        }
    }

    func drawTopLevelMap(on surface: GraphicSurface, in rect: Rectangle) {
        let tileWidth = tileset.tileWidth
        let tileHeight = tileset.tileHeight

        var yIndex = rect.y / tileHeight
        for y in stride(from: -(rect.y % tileHeight), to: rect.height, by: tileHeight) {
            var xIndex = rect.x / tileWidth
            for x in stride(from: -(rect.x % tileWidth), to: rect.width, by: tileWidth) {
                guard (map.tileTypeAt(x: xIndex, y: yIndex + 1) == .tree) && (map.tileTypeAt(x: xIndex, y: yIndex) != .tree) else {
                    xIndex += 1
                    continue
                }
                var treeIndex = 0, treeMask = 0x1
                for yOffset in 0 ..< 2 {
                    for xOffset in -1 ..< 2 {
                        if map.tileTypeAt(x: xIndex + xOffset, y: yIndex + yOffset) == .tree {
                            treeIndex |= treeMask
                        }
                        treeMask <<= 1
                    }
                }
                // FIXME: Sometimes treeIndices[treeIndex] out of bound (-1).
                // To fix the crash, we check if the index is valid.
                // Figure out why treeIndices[treeIndex] is -1.
                if treeIndices[treeIndex] >= 0 {
                    tileset.drawTile(on: surface, x: x, y: y, index: treeIndices[treeIndex])
                }
                xIndex += 1
            }
            yIndex += 1
        }
    }

    func drawMiniMap(on resourceContext: GraphicResourceContext) {
        resourceContext.setLineWidth(1)
        resourceContext.setLineCap(.square)
        for y in 0 ..< map.height {
            var x = 0
            while x < map.width {
                let tileType = map.tileTypeAt(x: x, y: y)
                let xAnchor = x
                while x < map.width && map.tileTypeAt(x: x, y: y) == tileType {
                    x += 1
                }
                if tileType != .none {
                    resourceContext.setSourceRGB(UInt32(pixelIndices[tileType.rawValue]))
                    resourceContext.moveTo(x: xAnchor, y: y)
                    resourceContext.lineTo(x: x - 1, y: y)
                    resourceContext.stroke()
                }
            }
        }
    }

    func findIndexAndUnknownMask(types: [TerrainMap.TileType], x: Int, y: Int, yRange: [Int], xRange: [Int], checkZeros: Bool) -> (Int, Int) {
        var itemIndex = 0, itemMask = 0x1, unknownMask = 0
        for yOffset in yRange {
            for xOffset in xRange {
                guard !checkZeros || xOffset != 0 || yOffset != 0 else { continue }
                let type = map.tileTypeAt(x: x + xOffset, y: y + yOffset)
                if types.contains(type) {
                    itemIndex |= itemMask
                } else if type == .none {
                    unknownMask |= itemMask
                }
                itemMask <<= 1
            }
        }
        return (itemIndex, unknownMask)
    }
}
