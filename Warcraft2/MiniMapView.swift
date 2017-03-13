import UIKit

class MiniMapView: UIView {
    private var mapRenderer: MapRenderer
    private var assetRenderer: AssetRenderer
    private var fogRenderer: FogRenderer
    private var viewportRenderer: ViewportRenderer
    var visibleWidth: Int
    var visibleHeight: Int

    init(mapRenderer: MapRenderer, assetRenderer: AssetRenderer, fogRenderer: FogRenderer, viewportRenderer: ViewportRenderer) {
        self.mapRenderer = mapRenderer
        self.assetRenderer = assetRenderer
        self.fogRenderer = fogRenderer
        self.viewportRenderer = viewportRenderer
        self.visibleWidth = mapRenderer.mapWidth
        self.visibleHeight = mapRenderer.mapHeight
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)))
    }

    override init(frame: CGRect) {
        fatalError("View can't be initialized using this method.")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("View can't be initialized using this method.")
    }

    override func draw(_ rect: CGRect) {
        let resourceContext = UIGraphicsGetCurrentContext()!

        mapRenderer.drawMiniMap(on: resourceContext)
        assetRenderer.drawMiniAssets(on: resourceContext)
        fogRenderer.drawMiniMap(on: resourceContext)

        // draw viewport box
        let miniMapWidth = mapRenderer.mapWidth
        let miniMapHeight = mapRenderer.mapHeight
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
        resourceContext.setSourceRGB(0xffffff)
        let miniMapViewportX = (viewportRenderer.viewportX * visibleWidth) / mapRenderer.detailedMapWidth
        let miniMapViewportY = (viewportRenderer.viewportY * visibleHeight) / mapRenderer.detailedMapHeight
        let miniMapViewportWidth = (viewportRenderer.lastViewportWidth * visibleWidth) / mapRenderer.detailedMapWidth
        let miniMapViewportHeight = (viewportRenderer.lastViewportHeight * visibleHeight) / mapRenderer.detailedMapHeight
        resourceContext.rectangle(x: miniMapViewportX, y: miniMapViewportY, width: miniMapViewportWidth, height: miniMapViewportHeight)
        resourceContext.stroke()
    }
}
