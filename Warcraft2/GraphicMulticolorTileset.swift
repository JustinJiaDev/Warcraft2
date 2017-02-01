class GraphicMulticolorTileset: GraphicTileset {
    private var coloredTilesets: [GraphicSurface] = []
    private var colorMap: GraphicRecolorMap

    override init() {
        fatalError("This method is not yet implemented.")
    }

    var colorCount: Int {
        return coloredTilesets.count
    }

    func findColor(colorname: String) -> Int {
        return colorMap.findColor(colorname: colorname)
    }

    func loadTileset(colormap: GraphicRecolorMap, source: DataSource) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    func drawTile(on surface: GraphicSurface, xposition: Int, yposition: Int, tileindex: Int, colorindex: Int) {
        fatalError("This method is not yet implemented.")
    }
}
