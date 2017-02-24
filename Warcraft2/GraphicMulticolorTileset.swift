import SpriteKit

class GraphicMulticolorTileset: GraphicTileset {
    private var coloredTilesets: [[SKTexture]] = []
    private var colorMap: GraphicRecolorMap?

    var colorCount: Int {
        return coloredTilesets.count
    }

    func findColor(with colorName: String) -> Int {
        return colorMap?.findColor(with: colorName) ?? -1
    }

    func loadTileset(colorMap: GraphicRecolorMap, from dataSource: DataSource) throws {
        guard let surfaceTileset = surfaceTileset else {
            throw GameError.missingTileset
        }
        try loadTileset(from: dataSource)
        //        coloredTilesets.removeAll()
        //        coloredTilesets.append(surfaceTileset)
        //        for colorIndex in 1 ..< colorMap.groupCount {
        //            coloredTilesets.append(try colorMap.recolorSurface(at: colorIndex, on: surfaceTileset))
        //        }
        //        self.colorMap = colorMap
    }

    func drawTile(on surface: GraphicSurface, x: Int, y: Int, tileIndex: Int, colorIndex: Int) throws {
        // FIXME: MAKE DRAW TILE GREAT AGAIN
        // HACK - BEGIN
        surface.draw(from: surfaceTileset![tileIndex], x: x, y: y, width: tileWidth, height: tileHeight)
        // HACK - END
        // ORIGINAL - BEGIN
        //        guard tileIndex >= 0 && tileIndex < tileCount else {
        //            throw GameError.indexOutOfBound(index: tileIndex)
        //        }
        //        guard colorIndex >= 0 && colorIndex < coloredTilesets.count else {
        //            throw GameError.indexOutOfBound(index: colorIndex)
        //        }
        //        try surface.draw(from: coloredTilesets[colorIndex], dx: x, dy: y, width: tileWidth, height: tileHeight, sx: 0, sy: tileIndex * tileHeight)
        // ORIGINAL - END
    }
}
