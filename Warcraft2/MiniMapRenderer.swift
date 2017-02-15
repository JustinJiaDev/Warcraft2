class MiniMapRenderer {
    private var mapRenderer: MapRenderer
    private var assetRenderer: AssetRenderer
    private var fogRenderer: FogRenderer
    private var viewportRenderer: ViewportRenderer
    private var workingSurface: GraphicSurface
    var viewportColor: UInt32
    var visibleWidth: Int
    var visibleHeight: Int

    init(mapRender: MapRenderer, assetRender: AssetRenderer, fogRender: FogRenderer, viewport: ViewportRenderer, format: GraphicSurfaceFormat) {
        mapRenderer = mapRender
        assetRenderer = assetRender
        fogRenderer = fogRender
        viewportRenderer = viewport
        viewportColor = 0xffffff

        visibleWidth = mapRenderer.mapWidth
        visibleHeight = mapRenderer.mapHeight

        workingSurface = GraphicFactory.createSurface(width: mapRenderer.mapWidth, height: mapRenderer.mapHeight, format: format)!

        // In GraphicSurface, CreateResourceContext() is a virtual function, which doesn't exist in Swift file
        // just want to make sure if I'm calling the right thing here?
        // C++: auto ResourceContext = surface->CreateResourceContext();
        let resourceContext = workingSurface.resourceContext
        resourceContext.setSourceRGB(0x000000)
        resourceContext.rectangle(x: 0, y: 0, width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)
        resourceContext.fill()
    }

    func viewportColor(color: UInt32) -> UInt32 {
        viewportColor = color
        return viewportColor
    }

    func drawMiniMap(surface: GraphicSurface) {
        // same problem as above. C++: auto ResourceContext = surface->CreateResourceContext();
        let resourceContext = surface.resourceContext
        let miniMapWidth = surface.width
        let miniMapHeight = surface.height
        let MMW_MH = miniMapWidth * mapRenderer.mapHeight
        let MMH_MW = miniMapHeight * mapRenderer.mapWidth
        var drawWidth: Int
        var drawHeight: Int
        var SX = Double(miniMapWidth) / Double(mapRenderer.mapWidth)
        var SY = Double(miniMapHeight) / Double(mapRenderer.mapHeight)

        if SX < SY {
            drawWidth = miniMapWidth
            drawHeight = Int(SX) * mapRenderer.mapHeight
            SY = SX
        } else if SX > SY {
            drawWidth = Int(SY) * mapRenderer.mapWidth
            drawHeight = miniMapHeight
            SX = SY
        } else {
            drawWidth = miniMapWidth
            drawHeight = miniMapHeight
        }

        if MMH_MW > MMW_MH {
            visibleWidth = miniMapWidth
            visibleHeight = (mapRenderer.mapHeight * miniMapWidth) / mapRenderer.mapWidth
        } else if MMH_MW < MMW_MH {
            visibleWidth = (mapRenderer.mapWidth * miniMapHeight) / mapRenderer.mapHeight
            visibleHeight = miniMapHeight
        } else {
            visibleWidth = miniMapWidth
            visibleHeight = miniMapHeight
        }

        mapRenderer.drawMiniMap(on: workingSurface)
        assetRenderer.drawMiniAssets(on: workingSurface)
        fogRenderer.drawMiniMap(on: workingSurface)

        resourceContext.save()
        resourceContext.scale(x: SX, y: SY)
        resourceContext.setSourceSurface(workingSurface, x: 0, y: 0)
        resourceContext.rectangle(x: 0, y: 0, width: drawWidth, height: drawHeight)
        resourceContext.fill()
        resourceContext.restore()

        resourceContext.setSourceRGB(viewportColor)
        let miniMapViewportX = (viewportRenderer.viewportX * visibleWidth) / mapRenderer.detailedMapWidth
        let miniMapViewportY = (viewportRenderer.viewportY * visibleHeight) / mapRenderer.detailedMapHeight
        let miniMapViewportWidth = (viewportRenderer.lastViewportWidth * visibleWidth) / mapRenderer.detailedMapWidth
        let miniMapViewportHeight = (viewportRenderer.lastViewportHeight * visibleHeight) / mapRenderer.detailedMapHeight
        resourceContext.rectangle(x: miniMapViewportX, y: miniMapViewportY, width: miniMapViewportWidth, height: miniMapViewportHeight)
        resourceContext.stroke()
    }
}
