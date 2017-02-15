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

        let resourceContext = workingSurface.resourceContext
        resourceContext.setSourceRGB(0x000000)
        resourceContext.rectangle(x: 0, y: 0, width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)
        resourceContext.fill()
    }

    func viewportColor(_ color: UInt32) -> UInt32 {
        viewportColor = color
        return viewportColor
    }

    func drawMiniMap(on surface: GraphicSurface) {
        let resourceContext = surface.resourceContext
        let miniMapWidth = surface.width
        let miniMapHeight = surface.height
        var drawWidth: Int
        var drawHeight: Int
        var sx = Double(miniMapWidth) / Double(mapRenderer.mapWidth)
        var sy = Double(miniMapHeight) / Double(mapRenderer.mapHeight)

        if sx < sy {
            drawWidth = miniMapWidth
            drawHeight = Int(sx) * mapRenderer.mapHeight
            sy = sx
        } else if sx > sy {
            drawWidth = Int(sy) * mapRenderer.mapWidth
            drawHeight = miniMapHeight
            sx = sy
        } else {
            drawWidth = miniMapWidth
            drawHeight = miniMapHeight
        }

        if miniMapHeight * mapRenderer.mapWidth > miniMapWidth * mapRenderer.mapHeight {
            visibleWidth = miniMapWidth
            visibleHeight = (mapRenderer.mapHeight * miniMapWidth) / mapRenderer.mapWidth
        } else if miniMapHeight * mapRenderer.mapWidth < miniMapWidth * mapRenderer.mapHeight {
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
        resourceContext.scale(x: sx, y: sy)
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
