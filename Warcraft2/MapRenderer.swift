class MapRenderer {
    var tileSet: GraphicTileset
    var map: TerrainMap
    var grassIndices: [Int]
    var treeIndices: [Int]
    var dirtIndices: [Int]
    var waterIndices: [Int]
    var rockIndices: [Int]
    var wallIndices: [Int]
    var wallDamagedIndices: [Int]
    var pixelIndices: [Int]

    var treeUnknown: [Int: Int]
    var waterUnknown: [Int: Int]
    var dirtUnknown: [Int: Int]
    var rockUnknown: [Int: Int]

    func makeHammingSet(value: Int, hammingSet: inout [Int]) {
        fatalError("Not yet ported")
    }

    func findUnknown(type: TerrainMap.TileType, known: Int, unknown: Int) {
        fatalError("Not yet ported")
    }

    init(config: DataSource, tileSet: GraphicTileset, map: TerrainMap) {
        fatalError("Not yet ported")
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
