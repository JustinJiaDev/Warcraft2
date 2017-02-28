class ViewportRenderer {
    private let mapRenderer: MapRenderer
    private let assetRenderer: AssetRenderer
    private let fogRenderer: FogRenderer
    private let frame: Rectangle

    init(mapRenderer: MapRenderer, assetRenderer: AssetRenderer, fogRenderer: FogRenderer) {
        self.mapRenderer = mapRenderer
        self.assetRenderer = assetRenderer
        self.fogRenderer = fogRenderer
        self.frame = Rectangle(x: 0, y: 0, width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)
    }

    func drawViewport(on surface: GraphicSurface, typeSurface: GraphicSurface, selectionMarkerList: [PlayerAsset], selectRect: Rectangle, currentCapability: AssetCapabilityType) throws {
        let builder = selectionMarkerList.first ?? PlayerAsset(playerAssetType: PlayerAssetType())
        let placeType: AssetType = {
            switch currentCapability {
            case .buildFarm: return .farm
            case .buildTownHall: return .townHall
            case .buildBarracks: return .barracks
            case .buildLumberMill: return .lumberMill
            case .buildBlacksmith: return .blacksmith
            case .buildScoutTower: return .scoutTower
            default: return .none
            }
        }()

        try mapRenderer.drawMap(on: surface, typeSurface: typeSurface, in: frame, level: 0)
        // try assetRenderer.drawSelections(on: surface, in: frame, selectionList: selectionMarkerList, selectRect: selectRect, highlightBuilding: placeType != .none)
        try assetRenderer.drawAssets(on: surface, typeSurface: typeSurface, in: frame)
        try mapRenderer.drawMap(on: surface, typeSurface: typeSurface, in: frame, level: 1)
        try assetRenderer.drawOverlays(on: surface, in: frame)
        try assetRenderer.drawPlacement(on: surface, in: frame, position: Position(x: selectRect.x, y: selectRect.y), type: placeType, builder: builder)
        // try fogRenderer.drawMap(on: surface, in: frame)
    }
}
