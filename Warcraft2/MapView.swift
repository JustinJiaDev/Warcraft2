import UIKit

class MapView: UIView {

    private var mapRender: MapRenderer!

    override func awakeFromNib() {
        do {
            guard let configurationURL = Bundle.main.url(forResource: "MapRendering", withExtension: "dat") else {
                fatalError()
            }
            let configuration = try FileDataSource(url: configurationURL)

            guard let tilesetURL = Bundle.main.url(forResource: "Terrain", withExtension: "dat") else {
                fatalError()
            }
            let tilesetSource = try FileDataSource(url: tilesetURL)
            let tileset = GraphicTileset()
            try tileset.loadTileset(from: tilesetSource)

            guard let mapURL = Bundle.main.url(forResource: "maze", withExtension: "map") else {
                fatalError()
            }
            let mapSource = try FileDataSource(url: mapURL)
            let map = AssetDecoratedMap()
            try map.loadMap(source: mapSource)

            mapRender = try MapRenderer(configuration: configuration, tileset: tileset, map: map)
            bounds.size = CGSize(width: mapRender.detailedMapWidth, height: mapRender.detailedMapHeight)
        } catch {
            print(error.localizedDescription) // TODO: Handle Error
        }
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
        do {
            let context = UIGraphicsGetCurrentContext()!
            let layer = CGLayer(context, size: bounds.size, auxiliaryInfo: nil)!
            try mapRender.drawMap(on: layer, typeSurface: layer, in: Rectangle(xPosition: 0, yPosition: 0, width: mapRender.detailedMapWidth, height: mapRender.detailedMapHeight), level: 0)
            context.draw(layer, in: rect)
        } catch {
            print(error.localizedDescription) // TODO: Handle Error
        }
    }
}
