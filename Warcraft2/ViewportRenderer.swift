class ViewportRenderer {
    private var mapRenderer: MapRenderer
    private var assetRenderer: AssetRenderer
    private var fogRenderer: FogRenderer! // FIXME: MAKE FOG RENDERER GREAT AGAIN
    var viewportX: Int
    var viewportY: Int
    var lastViewportWidth: Int
    var lastViewportHeight: Int

    // FIXME: MAKE FOG RENDERER GREAT AGAIN
    init(mapRender: MapRenderer, assetRender: AssetRenderer, fogRender: FogRenderer! = nil) {
        mapRenderer = mapRender
        assetRenderer = assetRender
        fogRenderer = fogRender
        viewportX = 0
        viewportY = 0
        lastViewportWidth = mapRender.detailedMapWidth
        lastViewportHeight = mapRender.detailedMapHeight
    }

    func initViewportDimensions(width: Int, height: Int) {
        lastViewportWidth = width
        lastViewportHeight = height
    }

    @discardableResult func viewportX(_ x: Int) -> Int {
        viewportX = x

        if viewportX + lastViewportWidth >= mapRenderer.detailedMapWidth {
            viewportX = mapRenderer.detailedMapWidth - lastViewportWidth
        }
        if viewportX < 0 {
            viewportX = 0
        }
        return viewportX
    }

    @discardableResult func viewportY(_ y: Int) -> Int {
        viewportY = y
        if viewportY + lastViewportHeight >= mapRenderer.detailedMapHeight {
            viewportY = mapRenderer.detailedMapHeight - lastViewportHeight
        }
        if viewportY < 0 {
            viewportY = 0
        }
        return viewportY
    }

    func centerViewport(position: Position) {
        viewportX(position.x - lastViewportWidth / 2)
        viewportY(position.y - lastViewportHeight / 2)
    }

    func detailedPosition(of position: Position) -> Position {
        return Position(x: position.x + viewportX, y: position.y + viewportY)
    }

    func panNorth(_ distance: Int) {
        viewportY -= distance
        if viewportY < 0 {
            viewportY = 0
        }
    }

    func panEast(_ distance: Int) {
        viewportX(viewportX + distance)
    }

    func panSouth(_ distance: Int) {
        viewportY(viewportY + distance)
    }

    func panWest(_ distance: Int) {
        viewportX -= distance
        if viewportX < 0 {
            viewportX = 0
        }
    }

    func drawViewport(on surface: GraphicSurface, typeSurface: GraphicSurface, selectionMarkerList: [PlayerAsset], selectRect: Rectangle, currentCapability: AssetCapabilityType) throws {
        var tempRectangle = Rectangle()
        var placeType = AssetType.none
        let builder = selectionMarkerList.first ?? PlayerAsset(playerAssetType: PlayerAssetType())

        lastViewportWidth = surface.width
        lastViewportHeight = surface.height

        if viewportX + lastViewportWidth >= mapRenderer.detailedMapWidth {
            viewportX = mapRenderer.detailedMapWidth - lastViewportWidth
        }
        if viewportY + lastViewportHeight >= mapRenderer.detailedMapHeight {
            viewportY = mapRenderer.detailedMapHeight - lastViewportHeight
        }

        tempRectangle.xPosition = viewportX
        tempRectangle.yPosition = viewportY
        tempRectangle.width = lastViewportWidth
        tempRectangle.height = lastViewportHeight

        switch currentCapability {
        case .buildFarm: placeType = .farm
        case .buildTownHall: placeType = .townHall
        case .buildBarracks: placeType = .barracks
        case .buildLumberMill: placeType = .lumberMill
        case .buildBlacksmith: placeType = .blacksmith
        case .buildScoutTower: placeType = .scoutTower
        default: break
        }

        try mapRenderer.drawMap(on: surface, typeSurface: typeSurface, in: tempRectangle, level: 0)
        try assetRenderer.drawSelections(on: surface, in: tempRectangle, selectionList: selectionMarkerList, selectRect: selectRect, highlightBuilding: placeType != .none)
        try assetRenderer.drawAssets(on: surface, typeSurface: typeSurface, in: tempRectangle)
        try mapRenderer.drawMap(on: surface, typeSurface: typeSurface, in: tempRectangle, level: 1)
        try assetRenderer.drawOverlays(on: surface, in: tempRectangle)
        try assetRenderer.drawPlacement(on: surface, in: tempRectangle, position: Position(x: selectRect.xPosition, y: selectRect.yPosition), type: placeType, builder: builder)
        // FIXME: MAKE FOG RENDERER GREAT AGAIN
        // try fogRenderer.drawMap(on: surface, rectangle: tempRectangle)
    }
}
