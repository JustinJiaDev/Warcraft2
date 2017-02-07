class ViewportRenderer {
    private var mapRenderer: MapRenderer
    private var assetRenderer: AssetRenderer
    private var fogRenderer: FogRenderer
    var viewportX: Int
    var viewportY: Int
    var lastViewportWidth: Int
    var lastViewportHeight: Int

    init(mapRender: MapRenderer, assetRender: AssetRenderer, fogRender: FogRenderer) {
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

    func viewportX(x: Int) -> Int {
        viewportX = x

        if viewportX + lastViewportWidth >= mapRenderer.detailedMapWidth {
            viewportX = mapRenderer.detailedMapWidth - lastViewportWidth
        }
        if viewportX < 0 {
            viewportX = 0
        }
        return viewportX
    }

    func viewportY(y: Int) -> Int {
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
        _ = viewportX(x: position.x - lastViewportWidth / 2)
        _ = viewportY(y: position.y - lastViewportHeight / 2)
    }

    func detailedPosition(position: Position) -> Position {
        return Position(x: position.x + viewportX, y: position.y + viewportY)
    }

    func panNorth(pan: Int) {
        viewportY -= pan
        if viewportY < 0 {
            viewportY = 0
        }
    }

    func panEast(pan: Int) {
        _ = viewportX(x: viewportX + pan)
    }

    func panSouth(pan: Int) {
        _ = viewportY(y: viewportY + pan)
    }

    func panWest(pan: Int) {
        viewportX -= pan
        if viewportX < 0 {
            viewportX = 0
        }
    }

    func drawViewport(on surface: GraphicSurface, on typeSurface: GraphicSurface, selectionMarkerList: [PlayerAsset], selectRect: Rectangle, curCapability: AssetCapabilityType) throws {
        var tempRectangle = Rectangle()
        var placeType = AssetType.none
        var builder = PlayerAsset(playerAsset: PlayerAssetType())

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

        switch curCapability {
        case .buildFarm:
            placeType = .farm
            break
        case .buildTownHall:
            placeType = .townHall
            break
        case .buildBarracks:
            placeType = .barracks
            break
        case .buildLumberMill:
            placeType = .lumberMill
            break
        case .buildBlacksmith:
            placeType = .blacksmith
            break
        case .buildScoutTower:
            placeType = .scoutTower
            break
        default:
            break
        }

        try mapRenderer.drawMap(on: surface, typeSurface: typeSurface, in: tempRectangle, level: 0)
        try assetRenderer.drawSelections(on: surface, in: tempRectangle, selectionList: selectionMarkerList, selectRect: selectRect, highlightBuilding: placeType != .none)
        try assetRenderer.drawAssets(on: surface, typeSurface: typeSurface, in: tempRectangle)
        try mapRenderer.drawMap(on: surface, typeSurface: typeSurface, in: tempRectangle, level: 1)
        try assetRenderer.drawOverlays(on: surface, in: tempRectangle)

        if selectionMarkerList.count != 0 {
            builder = selectionMarkerList.first!
        }

        try assetRenderer.drawPlacement(on: surface, in: tempRectangle, position: Position(x: selectRect.xPosition, y: selectRect.yPosition), type: placeType, builder: builder)
        try fogRenderer.drawMap(on: surface, rectangle: tempRectangle)
    }
}
