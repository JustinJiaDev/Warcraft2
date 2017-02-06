import UIKit

class MapView: UIView {

    weak var mapRenderer: MapRenderer?
    weak var assetRenderer: AssetRenderer?

    convenience init(frame: CGRect, mapRenderer: MapRenderer, assetRenderer: AssetRenderer) {
        self.init(frame: frame)
        self.mapRenderer = mapRenderer
        self.assetRenderer = assetRenderer
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self), let previousLocation = touches.first?.previousLocation(in: self) else {
            return
        }
        frame.origin.x += location.x - previousLocation.x
        frame.origin.y += location.y - previousLocation.y
        frame.origin.x = max(min(frame.origin.x, 0), -frame.size.width + UIScreen.main.bounds.width)
        frame.origin.y = max(min(frame.origin.y, 0), -frame.size.height + UIScreen.main.bounds.height)
    }

    override func draw(_ rect: CGRect) {
        guard let mapRenderer = mapRenderer, let assetRenderer = assetRenderer else {
            return
        }
        do {
            let rectangle = Rectangle(xPosition: 0, yPosition: 0, width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)
            let layer = GraphicFactory.createSurface(width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight, format: .a1)!
            let typeLayer = GraphicFactory.createSurface(width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight, format: .a1)!
            try mapRenderer.drawMap(on: layer, typeSurface: typeLayer, in: rectangle, level: 0)
            try assetRenderer.drawAssets(on: layer, typeSurface: layer, in: rectangle)
            try mapRenderer.drawMap(on: layer, typeSurface: typeLayer, in: rectangle, level: 1)
            // let builder = PlayerAsset(playerAsset: PlayerAssetType())
            // try assetRenderer.drawPlacement(on: layer, in: rectangle, position: Position(x: 100, y: 100), type: .goldMine, builder: builder)
            // try assetRenderer.drawOverlays(on: layer, in: rectangle)
            let context = UIGraphicsGetCurrentContext()!
            context.draw(layer as! CGLayer, in: rect)
            context.draw(typeLayer as! CGLayer, in: rect)
        } catch {
            print(error.localizedDescription) // TODO: Handle Error
        }
    }
}
