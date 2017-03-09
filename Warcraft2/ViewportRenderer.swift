class ViewportRenderer {
    private var mapRenderer: MapRenderer
    private var assetRenderer: AssetRenderer
    private var fogRenderer: FogRenderer
    var viewportX: Int
    var viewportY: Int
    var lastViewportWidth: Int
    var lastViewportHeight: Int

    init(mapRenderer: MapRenderer, assetRenderer: AssetRenderer, fogRenderer: FogRenderer) {
        self.mapRenderer = mapRenderer
        self.assetRenderer = assetRenderer
        self.fogRenderer = fogRenderer
        self.viewportX = 0
        self.viewportY = 0
        self.lastViewportWidth = mapRenderer.detailedMapWidth
        self.lastViewportHeight = mapRenderer.detailedMapHeight
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

    func drawViewport(on surface: GraphicSurface, typeSurface: GraphicSurface, selectionMarkerList: [PlayerAsset], selectRect: Rectangle, currentCapability: AssetCapabilityType) {
        lastViewportWidth = surface.width
        lastViewportHeight = surface.height

        if viewportX + lastViewportWidth >= mapRenderer.detailedMapWidth {
            viewportX = mapRenderer.detailedMapWidth - lastViewportWidth
        }
        if viewportY + lastViewportHeight >= mapRenderer.detailedMapHeight {
            viewportY = mapRenderer.detailedMapHeight - lastViewportHeight
        }

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
        let tempRectangle = Rectangle(x: viewportX, y: viewportY, width: lastViewportWidth, height: lastViewportHeight)
        mapRenderer.drawBottomLevelMap(on: surface, typeSurface: typeSurface, in: tempRectangle)
        // assetRenderer.drawSelections(on: surface, in: tempRectangle, selectionList: selectionMarkerList, selectRect: selectRect, highlightBuilding: placeType != .none)
        assetRenderer.drawAssets(on: surface, typeSurface: typeSurface, in: tempRectangle)
        mapRenderer.drawTopLevelMap(on: surface, typeSurface: typeSurface, in: tempRectangle)
        assetRenderer.drawOverlays(on: surface, in: tempRectangle)
        assetRenderer.drawPlacement(on: surface, in: tempRectangle, position: Position(x: selectRect.x, y: selectRect.y), type: placeType, builder: builder)
        // try fogRenderer.drawMap(on: surface, in: tempRectangle)
    }
}
