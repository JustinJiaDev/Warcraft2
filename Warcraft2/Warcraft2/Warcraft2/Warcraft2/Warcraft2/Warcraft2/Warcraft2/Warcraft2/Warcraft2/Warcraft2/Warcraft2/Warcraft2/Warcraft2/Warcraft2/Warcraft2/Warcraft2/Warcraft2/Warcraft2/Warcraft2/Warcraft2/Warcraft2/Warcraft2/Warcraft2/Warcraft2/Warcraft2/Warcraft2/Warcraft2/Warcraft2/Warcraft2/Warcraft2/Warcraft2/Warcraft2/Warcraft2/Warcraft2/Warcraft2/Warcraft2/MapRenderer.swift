enum MapRendererError: Error {

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

class MapRenderer {
    var tileset: GraphicTileset
    var map: TerrainMap
    var grassIndices: [Int] = []
    var treeIndices: [Int] = []
    var dirtIndices: [Int] = []
    var waterIndices: [Int] = []
    var rockIndices: [Int] = []
    var wallIndices: [Int] = []
    var wallDamagedIndices: [Int] = []
    var pixelIndices: [Int] = []

    var treeUnknown: [Int: Int] = [:]
    var waterUnknown: [Int: Int] = [:]
    var dirtUnknown: [Int: Int] = [:]
    var rockUnknown: [Int: Int] = [:]

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

    func makeHammingSet(value: Int, hammingSet: inout [Int]) {
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
            throw MapRendererError.failedToReadItemCount
        }

        for _ in 0 ..< itemCount {
            guard let currentLine = lineSource.readLine() else {
                throw MapRendererError.failedToReadItemLine
            }
            let tokens = Tokenizer.tokenize(data: currentLine)
            guard tokens.count >= 2 else {
                throw MapRendererError.invalidItemLine(string: currentLine)
            }
            let pixelType = TerrainMap.TileType.from(string: tokens[0])
            guard let colorHex = MapRenderer.number(fromHexString: tokens[1]), colorHex >= 0 else {
                throw MapRendererError.invalidColorHex(string: tokens[1])
            }
            pixelIndices[pixelType.rawValue] = colorHex
        }

        var index = 0
        while true {
            let value = self.tileset.findTile(with: "grass-\(index)")
            if value < 0 {
                break
            }
            grassIndices.append(value)
            index += 1
        }

        for index in 0 ..< 0x40 {
            treeIndices.append(self.tileset.findTile(with: "tree-\(index)"))
        }

        for index in 0 ..< 0x100 {
            dirtIndices.append(self.tileset.findTile(with: "dirt-\(index)"))
        }

        for index in 0 ..< 0x100 {
            waterIndices.append(self.tileset.findTile(with: "water-\(index)"))
        }

        waterIndices[0x00] = dirtIndices[0xff]

        for index in 0 ..< 0x100 {
            rockIndices.append(self.tileset.findTile(with: "rock-\(index)"))
        }

        for index in 0 ..< 0x10 {
            wallIndices.append(self.tileset.findTile(with: "wall-\(index)"))
        }

        for index in 0 ..< 0x10 {
            wallDamagedIndices.append(self.tileset.findTile(with: "wall-damaged-\(index)"))
        }

        guard let secondItemCountString = lineSource.readLine(), let secondItemCount = Int(secondItemCountString) else {
            throw MapRendererError.failedToReadItemCount
        }

        for _ in 0 ..< secondItemCount {
            guard let currentLine = lineSource.readLine() else {
                throw MapRendererError.failedToReadSecondItemLine
            }
            let tokens = Tokenizer.tokenize(data: currentLine)
            guard tokens.count >= 3 else {
                throw MapRendererError.invalidItemLine(string: currentLine)
            }
            let indices = try tokens.dropFirst().map { token -> Int in
                guard let index = MapRenderer.number(fromHexString: token) else {
                    throw MapRendererError.invalidSourceIndexHex(string: token)
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
            default: throw MapRendererError.invalidType(String: tokens[0])
            }
        }
    }

    func drawMap(surface: GraphicSurface, typeSurface: GraphicSurface, rect: Rectangle, level: Int) throws {
        let tileWidth = tileset.tileWidth
        let tileHeight = tileset.tileHeight
        var unknownTree: [Bool] = []
        var unknownWater: [Bool] = []
        var unknownDirt: [Bool] = []
        var unknownRock: [Bool] = []
        var unknownUnknownTree: [Int: Bool] = [:]
        var unknownUnknownWater: [Int: Bool] = [:]
        var unknownUnknownDirt: [Int: Bool] = [:]
        var unknownUnknownRock: [Int: Bool] = [:]

        if unknownTree.isEmpty {
            unknownTree = Array(repeating: false, count: 0x100)
            unknownWater = Array(repeating: false, count: 0x100)
            unknownDirt = Array(repeating: false, count: 0x100)
            unknownRock = Array(repeating: false, count: 0x100)
        }

        if level == 0 {
            try typeSurface.clear(x: 0, y: 0, width: typeSurface.width, height: typeSurface.height)

            var yIndex = rect.yPosition / tileHeight
            for yPos in stride(from: -(rect.yPosition % tileHeight), to: rect.height, by: tileHeight) {
                var xIndex = rect.xPosition / tileWidth
                for xPos in stride(from: -(rect.xPosition % tileWidth), to: rect.width, by: tileWidth) {
                    let pixelType = PixelType(tileType: map.tileTypeAt(x: xIndex, y: yIndex))
                    let thisTileType = map.tileTypeAt(x: xIndex, y: yIndex)

                    if thisTileType == .tree {
                        var treeIndex = 0, treeMask = 0x1, unknownMask = 0, displayIndex = -1
                        for yOff in 0 ..< 2 {
                            for xOff in -1 ..< 2 {
                                let tile = map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff)
                                if tile == .tree {
                                    treeIndex |= treeMask
                                } else if tile == .none {
                                    unknownMask |= treeMask
                                }
                                treeMask <<= 1
                            }
                        }

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

                        if displayIndex != -1 {
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: pixelType.pixelColor)
                        }
                    } else if thisTileType == .water {
                        var waterIndex = 0, waterMask = 0x1, unknownMask = 0, displayIndex = -1
                        for yOff in -1 ..< 2 {
                            for xOff in -1 ..< 2 {
                                if xOff != 0 || yOff != 0 {
                                    let tile = map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff)
                                    if tile == .water {
                                        waterIndex |= waterMask
                                    } else if tile == .none {
                                        unknownMask |= waterMask
                                    }
                                    waterMask <<= 1
                                }
                            }
                        }

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

                        if displayIndex != -1 {
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: pixelType.pixelColor)
                        }
                    } else if thisTileType == .grass {
                        var otherIndex = 0, otherMask = 0x1, unknownMask = 0, displayIndex = -1
                        for yOff in -1 ..< 2 {
                            for xOff in -1 ..< 2 {
                                if xOff != 0 || yOff != 0 {
                                    let tile = map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff)
                                    if tile == .water || tile == .dirt || tile == .rock {
                                        otherIndex |= otherMask
                                    } else if tile == .none {
                                        unknownMask |= otherMask
                                    }
                                    otherMask <<= 1
                                }
                            }
                        }

                        if otherIndex != 0 {
                            if dirtIndices[otherIndex] == -1 {
                                if !unknownDirt[otherIndex] && unknownMask == 0 {
                                    printError("Unknown dirt \(otherIndex) @ (\(xIndex), \(yIndex))")
                                    unknownDirt[otherIndex] = true
                                }
                                displayIndex = findUnknown(type: .dirt, known: otherIndex, unknown: unknownMask)
                                if displayIndex == -1 {
                                    if unknownUnknownDirt[(otherIndex << 8) | unknownMask] == nil {
                                        unknownUnknownDirt[(otherIndex << 8) | unknownMask] = true
                                        printError("Unknown dirt \(otherIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                                    }
                                }
                            } else {
                                displayIndex = dirtIndices[otherIndex]
                            }

                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: pixelType.pixelColor)
                        } else {
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: grassIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: grassIndices[0x00], rgb: pixelType.pixelColor)
                        }
                    } else if thisTileType == .rock {
                        var rockIndex = 0, rockMask = 0x1, unknownMask = 0, displayIndex = -1
                        for yOff in -1 ..< 2 {
                            for xOff in -1 ..< 2 {
                                if xOff != 0 || yOff != 0 {
                                    let tile = map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff)
                                    if tile == .rock {
                                        rockIndex |= rockMask
                                    } else if tile == .none {
                                        unknownMask |= rockMask
                                    }
                                    rockMask <<= 1
                                }
                            }
                        }

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

                        if displayIndex != -1 {
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: pixelType.pixelColor)
                        }
                    } else if thisTileType == .wall || thisTileType == .wallDamaged {
                        var wallIndex = 0, wallMask = 0x1, displayIndex = -1
                        var xOffsets = [0, 1, 0, -1]
                        var yOffsets = [ -1, 0, 1, 0]
                        for index in 0 ..< xOffsets.count {
                            let tile = map.tileTypeAt(x: xIndex + xOffsets[index], y: yIndex + yOffsets[index])
                            if tile == .wall || tile == .wallDamaged || tile == .rubble {
                                wallIndex |= wallMask
                            }
                            wallMask <<= 1
                        }
                        displayIndex = .wall == thisTileType ? wallIndices[wallIndex] : wallDamagedIndices[wallIndex]
                        if displayIndex != -1 {
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: pixelType.pixelColor)
                        }
                    } else {
                        switch map.tileTypeAt(x: xIndex, y: yIndex) {
                        case .grass:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: grassIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: grassIndices[0x00], rgb: pixelType.pixelColor)
                            break
                        case .dirt:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: dirtIndices[0xff])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: dirtIndices[0xff], rgb: pixelType.pixelColor)
                            break
                        case .rock:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: rockIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: rockIndices[0x00], rgb: pixelType.pixelColor)
                            break
                        case .tree:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: treeIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: treeIndices[0x00], rgb: pixelType.pixelColor)
                            break
                        case .stump:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: treeIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: treeIndices[0x00], rgb: pixelType.pixelColor)
                            break
                        case .water:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: waterIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: waterIndices[0x00], rgb: pixelType.pixelColor)
                            break
                        case .wall:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: wallIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: wallIndices[0x00], rgb: pixelType.pixelColor)
                            break
                        case .wallDamaged:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: wallDamagedIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: wallDamagedIndices[0x00], rgb: pixelType.pixelColor)
                            break
                        case .rubble:
                            try tileset.drawTile(on: surface, x: xPos, y: yPos, index: wallIndices[0x00])
                            try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: wallIndices[0x00], rgb: pixelType.pixelColor)
                            break
                        default:
                            break
                        }
                    }
                    xIndex += 1
                }
                yIndex += 1
            }
        } else {
            var yIndex = rect.yPosition / tileHeight
            for yPos in stride(from: -(rect.yPosition % tileHeight), to: rect.height, by: tileHeight) {
                var xIndex = rect.xPosition / tileWidth
                for xPos in stride(from: -(rect.xPosition % tileWidth), to: rect.width, by: tileWidth) {
                    if (map.tileTypeAt(x: xIndex, y: yIndex + 1) == .tree) && (map.tileTypeAt(x: xIndex, y: yIndex) != .tree) {
                        let pixelType = PixelType(tileType: .tree)
                        var treeIndex = 0, treeMask = 0x1

                        for yOff in 0 ..< 2 {
                            for xOff in -1 ..< 2 {
                                if map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff) == .tree {
                                    treeIndex |= treeMask
                                }
                                treeMask <<= 1
                            }
                        }

                        try tileset.drawTile(on: surface, x: xPos, y: yPos, index: treeIndices[treeIndex])
                        try tileset.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: treeIndices[treeIndex], rgb: pixelType.pixelColor)
                    }
                    xIndex += 1
                }
                yIndex += 1
            }
        }
    }

    func drawMiniMap(surface: GraphicSurface) {
        let resourceContext = surface.createResourceContext()
        resourceContext.setLineWidth(1)
        resourceContext.setLineCap(GraphicResourceContext.LineCap.square)
        for yPos in 0 ..< map.height {
            var xPos = 0

            while xPos < map.width {
                let tileType = map.tileTypeAt(x: xPos, y: yPos)
                let xAnchor = xPos
                while xPos < map.width && map.tileTypeAt(x: xPos, y: yPos) == tileType {
                    xPos += 1
                }
                if .none != tileType {
                    resourceContext.setSourceRGB(UInt32(pixelIndices[tileType.rawValue]))
                    resourceContext.moveTo(xPosition: xAnchor, yPosition: yPos)
                    resourceContext.lineTo(xPosition: xPos - 1, yPosition: yPos)
                    resourceContext.stroke()
                }
            }
        }
    }
}
