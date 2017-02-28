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

    // FIXME: MAKE LOAD TILESET GREAT AGAIN
    func loadTileset(colorMap: GraphicRecolorMap, from dataSource: FileDataSource) throws {
        try loadTileset(from: dataSource)
        // ORIGINAL - BEGIN
        //        coloredTilesets.removeAll()
        //        coloredTilesets.append(surfaceTileset)
        //        for colorIndex in 1 ..< colorMap.groupCount {
        //            coloredTilesets.append(try colorMap.recolorSurface(at: colorIndex, on: surfaceTileset))
        //        }
        //        self.colorMap = colorMap
        // ORIGINAL - END
    }

    func drawTile(on surface: GraphicSurface, x: Int, y: Int, tileIndex: Int, colorIndex: Int) {
        // FIXME: MAKE DRAW TILE GREAT AGAIN
        // HACK - BEGIN
        surface.draw(from: surfaceTileset![tileIndex], x: x, y: y, width: tileWidth, height: tileHeight)
        // HACK - END
        // ORIGINAL - BEGIN
        //        try surface.draw(from: coloredTilesets[colorIndex], dx: x, dy: y, width: tileWidth, height: tileHeight, sx: 0, sy: tileIndex * tileHeight)
        // ORIGINAL - END
    }
}
