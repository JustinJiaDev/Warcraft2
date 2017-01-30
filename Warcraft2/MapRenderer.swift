class MapRenderer {
    var tileSet: GraphicTileset
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
        if type == TerrainMap.TileType.tree {
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
        } else if type == TerrainMap.TileType.water {
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
        } else if type == TerrainMap.TileType.dirt {
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
        } else if type == TerrainMap.TileType.rock {
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

    init(config: DataSource, tileSet: GraphicTileset, map: TerrainMap) {
        let lineSource = LineDataSource(dataSource: config)
        var tempString: String?
        self.tileSet = tileSet
        self.map = map
        pixelIndices = Array(repeating: -1, count: TerrainMap.TileType.max.rawValue)

        tempString = lineSource.readLine()
        if tempString == nil { return }

        var itemCount = Int(tempString!)!
        for _ in 0 ..< itemCount {
            tempString = lineSource.readLine()
            if tempString == nil { return }
            let tokens = Tokenizer.tokenize(data: tempString!)
            guard let colorValue = Int(tokens[1]) else {
                fatalError("String to Int coversion failed. It is likely that the conversion was not ported correctly.")
            }
            assert(colorValue >= 0)

            let pixelType = TerrainMap.TileType.from(string: tokens[0])
            pixelIndices[pixelType.rawValue] = colorValue
        }

        var index = 0
        while true {
            let value = self.tileSet.findTile(with: "grass-\(index)")
            if 0 > value {
                break
            }
            grassIndices.append(value)
            index += 1
        }

        for index in 0 ..< 0x40 {
            treeIndices.append(self.tileSet.findTile(with: "tree-\(index)"))
        }

        for index in 0 ..< 0x100 {
            dirtIndices.append(self.tileSet.findTile(with: "dirt-\(index)"))
        }

        for index in 0 ..< 0x100 {
            waterIndices.append(self.tileSet.findTile(with: "water-\(index)"))
        }

        waterIndices[0x00] = dirtIndices[0xff]
        for index in 0 ..< 0x100 {
            rockIndices.append(self.tileSet.findTile(with: "rock-\(index)"))
        }

        for index in 0 ..< 0x10 {
            wallIndices.append(self.tileSet.findTile(with: "wall-\(index)"))
        }

        for index in 0 ..< 0x10 {
            wallDamagedIndices.append(self.tileSet.findTile(with: "wall-damaged-\(index)"))
        }

        tempString = lineSource.readLine()
        if tempString == nil { return }
        itemCount = Int(tempString!)!
        for _ in 0 ..< itemCount {
            tempString = lineSource.readLine()
            if tempString == nil { return }
            let tokens = Tokenizer.tokenize(data: tempString!)
            guard let sourceIndex = Int(tokens[1]) else {
                fatalError("String to Int coversion failed. It is likely that the conversion was not ported correctly.")
            }

            switch tokens[0] {
            case "dirt": for i in 2 ..< tokens.count { dirtIndices[Int(tokens[i])!] = dirtIndices[sourceIndex] }
            case "rock": for i in 2 ..< tokens.count { rockIndices[Int(tokens[i])!] = rockIndices[sourceIndex] }
            case "tree": for i in 2 ..< tokens.count { treeIndices[Int(tokens[i])!] = treeIndices[sourceIndex] }
            case "water": for i in 2 ..< tokens.count { waterIndices[Int(tokens[i])!] = waterIndices[sourceIndex] }
            case "wall": for i in 2 ..< tokens.count { wallIndices[Int(tokens[i])!] = wallIndices[sourceIndex] }
            case "wall-damaged": for i in 2 ..< tokens.count { wallDamagedIndices[Int(tokens[i])!] = wallDamagedIndices[sourceIndex] }
            default: break
            }
        }
    }

    func mapWidth() -> Int {
        return map.width
    }

    func mapHeight() -> Int {
        return map.height
    }

    func detailedMapWidth() -> Int {
        return map.width * tileSet.tileWidth
    }

    func detailedMapHeight() -> Int {
        return map.height * tileSet.tileHeight
    }

    func drawMap(surface: GraphicSurface, typeSurface: GraphicSurface, rect: Rectangle, level: Int) throws {
        let tileWidth = tileSet.tileWidth
        let tileHeight = tileSet.tileHeight
        var unknownTree: [Bool] = []
        var unknownWater: [Bool] = []
        var unknownDirt: [Bool] = []
        var unknownRock: [Bool] = []
        var unknownUnknownTree: [Int: Bool] = [:]
        var unknownUnknownWater: [Int: Bool] = [:]
        var unknownUnknownDirt: [Int: Bool] = [:]
        var unknownUnknownRock: [Int: Bool] = [:]
    
        if level == 0 {
            typeSurface.clear()
            
            // Rewrite nested multiple-variable for loops
            var yIndex = rect.yPosition / tileHeight
            for yPos in stride(from: -(rect.yPosition % tileHeight), to: rect.height, by: tileHeight) {
                var xIndex = rect.xPosition / tileWidth
                for xPos in stride(from: -(rect.xPosition % tileWidth), to: rect.width, by: tileWidth){
                    _ = PixelType.init(tileType: map.tileTypeAt(x: xIndex, y: yIndex))
                    let thisTileType = map.tileTypeAt(x: xIndex, y: yIndex)
                    
                    if thisTileType == TerrainMap.TileType.tree {
                        var treeIndex = 0, treeMask = 0x1, unknownMask = 0, displayIndex = -1
                        for yOff in 0..<2 {
                            for xOff in -1..<2 {
                                let tile = map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff)
                                if tile == TerrainMap.TileType.tree {
                                    treeIndex |= treeMask
                                } else if tile == TerrainMap.TileType.none {
                                    unknownMask |= treeMask
                                }
                                treeMask <<= 1
                            }
                        }
                        
                        if treeIndices[treeIndex] == -1 {
                            if !unknownTree[treeIndex] && unknownMask == 0 {
                                printError("Unknown tree \(treeIndex) @ (\(xIndex), \(yIndex))")
                                unknownTree[treeIndex] = true;
                            }
                            displayIndex = findUnknown(type: TerrainMap.TileType.tree, known: treeIndex, unknown: unknownMask)
                            if displayIndex == -1 {
                                if unknownUnknownTree[(treeIndex<<8) | unknownMask] == nil {
                                    unknownUnknownTree[(treeIndex<<8) | unknownMask] = true
                                    printError("Unknown tree \(treeIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                                }
                            }
                        } else {
                            displayIndex = treeIndices[treeIndex]
                        }
                        
                        if displayIndex != -1{
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: PixelType.toPixelColor())
                        }
                    } else if thisTileType == TerrainMap.TileType.water {
                        var waterIndex = 0, waterMask = 0x1, unknownMask = 0, displayIndex = -1
                        for yOff in -1..<2 {
                            for xOff in -1..<2 {
                                if xOff != 0 || yOff != 0 {
                                    let tile = map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff)
                                    if tile == TerrainMap.TileType.water {
                                        waterIndex |= waterMask
                                    } else if tile == TerrainMap.TileType.none {
                                        unknownMask |= waterMask
                                    }
                                    waterMask <<= 1
                                }
                            }
                        }
                        
                        if waterIndices[waterIndex] == -1 {
                            if !unknownWater[waterIndex] && unknownMask == 0 {
                                printError("Unknown water \( waterIndex) @ (\(xIndex), \(yIndex))")
                                unknownWater[ waterIndex] = true;
                            }
                            displayIndex = findUnknown(type: TerrainMap.TileType.water, known: waterIndex, unknown: unknownMask)
                            if displayIndex == -1 {
                                if unknownUnknownWater[(waterIndex<<8) | unknownMask] == nil {
                                    unknownUnknownWater[(waterIndex<<8) | unknownMask] = true
                                    printError("Unknown water \(waterIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                                }
                            }
                        } else {
                            displayIndex = waterIndices[waterIndex]
                        }
                        
                        if displayIndex != -1{
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: PixelType.toPixelColor())
                        }
                    } else if thisTileType == TerrainMap.TileType.grass {
                        var otherIndex = 0, otherMask = 0x1, unknownMask = 0, displayIndex = -1
                        for yOff in -1..<2 {
                            for xOff in -1..<2 {
                                if xOff != 0 || yOff != 0 {
                                    let tile = map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff)
                                    if tile == TerrainMap.TileType.water || tile == TerrainMap.TileType.dirt || tile == TerrainMap.TileType.rock {
                                        otherIndex |= otherMask
                                    } else if tile == TerrainMap.TileType.none {
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
                                    unknownDirt[otherIndex] = true;
                                }
                                displayIndex = findUnknown(type: TerrainMap.TileType.dirt, known: otherIndex, unknown: unknownMask)
                                if displayIndex == -1 {
                                    if unknownUnknownDirt[(otherIndex<<8) | unknownMask] == nil {
                                        unknownUnknownDirt[(otherIndex<<8) | unknownMask] = true
                                         printError("Unknown water \(otherIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                                    }
                                }
                            } else {
                                displayIndex = dirtIndices[otherIndex];
                            }
                            
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: PixelType.toPixelColor())
                        } else{
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: grassIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: grassIndices[0x00], rgb: PixelType.toPixelColor())
                        }
                    } else if thisTileType == TerrainMap.TileType.rock {
                        var rockIndex = 0, rockMask = 0x1, unknownMask = 0, displayIndex = -1
                        for yOff in -1..<2 {
                            for xOff in -1..<2 {
                                if xOff != 0 || yOff != 0 {
                                    let tile = map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff)
                                    if tile == TerrainMap.TileType.rock {
                                        rockIndex |= rockMask
                                    } else if tile == TerrainMap.TileType.none {
                                        unknownMask |= rockMask
                                    }
                                    rockMask <<= 1
                                }
                            }
                        }
                        
                        if rockIndices[rockIndex] == -1 {
                            if !unknownRock[rockIndex] && unknownMask == 0 {
                                printError("Unknown rock \(rockIndex) @ (\(xIndex), \(yIndex))")
                                unknownRock[rockIndex] = true;
                            }
                            displayIndex = findUnknown(type: TerrainMap.TileType.rock, known: rockIndex, unknown: unknownMask)
                            if displayIndex == -1 {
                                if unknownUnknownRock[(rockIndex<<8) | unknownMask] == nil {
                                    unknownUnknownRock[(rockIndex<<8) | unknownMask] = true
                                    printError("Unknown rock \(rockIndex)/\(unknownMask) @ (\(xIndex), \(yIndex))")
                                }
                            }
                        } else {
                            displayIndex = rockIndices[rockIndex]
                        }
                        
                        if displayIndex != -1 {
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: PixelType.toPixelColor())
                        }
                    } else if thisTileType == TerrainMap.TileType.wall || thisTileType == TerrainMap.TileType.wallDamaged {
                        var wallIndex = 0, wallMask = 0x1, displayIndex = -1
                        var xOffsets = [0, 1, 0, -1]
                        var yOffsets = [-1, 0, 1, 0]
                        for index in 0..<xOffsets.capacity {
                            let tile = map.tileTypeAt(x: xIndex + xOffsets[index], y: yIndex + yOffsets[index])
                            if tile == TerrainMap.TileType.wall || tile == TerrainMap.TileType.wallDamaged || tile == TerrainMap.TileType.rubble {
                                wallIndex |= wallMask
                            }
                            wallMask <<= 1
                        }
                        displayIndex = TerrainMap.TileType.wall == thisTileType ? wallIndices[wallIndex] : wallDamagedIndices[wallIndex]
                        if displayIndex != -1 {
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: displayIndex)
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: displayIndex, rgb: PixelType.toPixelColor())
                        }
                    } else {
                        switch map.tileTypeAt(x: xIndex, y: yIndex) {
                        case TerrainMap.TileType.grass:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: grassIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: grassIndices[0x00], rgb: PixelType.toPixelColor())
                            break;
                        case TerrainMap.TileType.dirt:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: dirtIndices[0xFF])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: dirtIndices[0xFF], rgb: PixelType.toPixelColor())
                            break;
                        case TerrainMap.TileType.rock:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: rockIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: rockIndices[0x00], rgb: PixelType.toPixelColor())
                            break;
                        case TerrainMap.TileType.tree:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: treeIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: treeIndices[0x00], rgb: PixelType.toPixelColor())
                            break;
                        case TerrainMap.TileType.stump:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: treeIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: treeIndices[0x00], rgb: PixelType.toPixelColor())
                            break;
                        case TerrainMap.TileType.water:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: waterIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: waterIndices[0x00], rgb: PixelType.toPixelColor())
                            break;
                        case TerrainMap.TileType.wall:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: wallIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: wallIndices[0x00], rgb: PixelType.toPixelColor())
                            break;
                        case TerrainMap.TileType.wallDamaged:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: wallIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: wallIndices[0x00], rgb: PixelType.toPixelColor())
                            break;
                        case TerrainMap.TileType.rubble:
                            try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: wallIndices[0x00])
                            // PixelType.toPixelColor() not yet implemented
                            // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: wallIndices[0x00], rgb: PixelType.toPixelColor())
                            break;
                        default:
                            break;
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
                    if (map.tileTypeAt(x: xIndex, y: yIndex+1) == TerrainMap.TileType.tree) && (map.tileTypeAt(x: xIndex, y: yIndex) != TerrainMap.TileType.tree) {
                        _ = PixelType.init(tileType: TerrainMap.TileType.tree)
                        var treeIndex = 0, treeMask = 0x1
                        
                        for yOff in 0..<2 {
                            for xOff in -1..<2 {
                                if map.tileTypeAt(x: xIndex + xOff, y: yIndex + yOff) == TerrainMap.TileType.tree {
                                    treeIndex |= treeMask
                                }
                                treeMask <<= 1
                            }
                        }
                        
                        try tileSet.drawTile(on: surface, x: xPos, y: yPos, index: treeIndices[treeIndex])
                        // PixelType.toPixelColor() not yet implemented
                        // tileSet.drawClippedTile(on: typeSurface, x: xPos, y: yPos, index: treeIndices[treeIndex], rgb: PixelType.toPixelColor())
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
                if TerrainMap.TileType.none != tileType {
                    resourceContext.setSourceRGB(UInt32(pixelIndices[tileType.rawValue]))
                    resourceContext.moveTo(xPosition: xAnchor, yPosition: yPos)
                    resourceContext.lineTo(xPosition: xPos - 1, yPosition: yPos)
                    resourceContext.stroke()
                }
            }
        }
    }
}
