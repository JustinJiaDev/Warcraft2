class AssetRenderer {
    private var playerData: PlayerData
    private var playerMap: AssetDecoratedMap
    private var tilesets: [GraphicMulticolorTileset] = []
    private var markerTileset: GraphicTileset
    private var fireTilesets: [GraphicTileset] = []
    private var buildingDeathTileset: GraphicTileset
    private var corpseTileset: GraphicTileset
    private var arrowTileset: GraphicTileset
    private var markerIndices: [Int] = []
    private var corpseIndices: [Int] = []
    private var arrowIndices: [Int] = []
    private var placeGoodIndex: Int
    private var placeBadIndex: Int
    private var noneIndices: [[Int]] = [[]]
    private var constructIndices: [[Int]] = [[]]
    private var buildIndices: [[Int]] = [[]]
    private var walkIndices: [[Int]] = [[]]
    private var attackIndices: [[Int]] = [[]]
    private var carryGoldIndices: [[Int]] = [[]]
    private var carryLumberIndices: [[Int]] = [[]]
    private var deathIndices: [[Int]] = [[]]
    private var placeIndices: [[Int]] = [[]]
    private var pixelColors: UInt32
    private var animationDownsample: Int

    init(colors: GraphicRecolorMap, tilesets: [GraphicMulticolorTileset], markertileset: GraphicTileset, corpsetileset: GraphicTileset, firetileset: [GraphicTileset], buildingdeath: GraphicTileset, arrowtileset: GraphicTileset, player: PlayerData, map: AssetDecoratedMap) {
        fatalError("This method is not yet implemented")
    }

    static func updateFrequency(_frequency: Int) -> Int {
        fatalError("This method is not yet implemented")
    }

    func drawAssets(on surface: GraphicSurface, typesurface: GraphicSurface, rect: Rectangle) {
        fatalError("This method is not yet implemented")
    }

    func drawSelections(on surface: GraphicSurface, rect: Rectangle, selectionlist: [PlayerAsset], selectrect: Rectangle, highlightbuilding: Bool) {
        fatalError("This method is not yet implemented")
    }

    func drawOverlays(on surface: GraphicSurface, rect: Rectangle) {
        fatalError("This method is not yet implemented")
    }

    func drawPlacement(on surface: GraphicSurface, rect: Rectangle, position: Position, type: AssetType, builder: PlayerAsset) {
        fatalError("This method is not yet implemented")
    }

    func drawMiniAssets(on surface: GraphicSurface) {
        fatalError("This method is not yet implemented")
    }
}
