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

    init(configuration: DataSource, tileset: GraphicTileset, map: TerrainMap) {
        let lineSource = LineDataSource(dataSource: configuration)
        var tempString: String?
        self.tileSet = tileset
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

    func drawMap(surface: GraphicSurface, typeSurface: GraphicSurface, rest: Rectangle, level: Int) {
        fatalError("Not yet ported")
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
