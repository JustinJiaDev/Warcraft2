import SpriteKit

class GraphicMulticolorTileset: GraphicTileset {
    private var coloredTilesets: [[SKTexture]] = []
    private var colorMap: GraphicRecolorMap?

    var colorCount: Int {
        return coloredTilesets.count
    }

    func findColor(_ colorName: String) -> Int {
        return colorMap?.findColor(colorName) ?? -1
    }

    func loadTileset(colorMap: GraphicRecolorMap, from dataSource: FileDataSource) throws {
        try loadTileset(from: dataSource)
        coloredTilesets.removeAll()
        coloredTilesets.append(surfaceTileset)
        for colorIndex in 1 ..< colorMap.groupCount {
            coloredTilesets.append(colorMap.recolorTextures(surfaceTileset, at: colorIndex))
        }
        self.colorMap = colorMap
    }

    func drawTile(on surface: GraphicSurface, x: Int, y: Int, tileIndex: Int, colorIndex: Int) {
        surface.draw(from: coloredTilesets[colorIndex][tileIndex], x: x, y: y, width: tileWidth, height: tileHeight)
    }
}
