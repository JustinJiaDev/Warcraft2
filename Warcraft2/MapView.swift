import UIKit

class MapView: UIView {

    var mapRender: MapRenderer!

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
            let map = TerrainMap()
            try map.loadMap(source: mapSource)

            mapRender = try MapRenderer(configuration: configuration, tileset: tileset, map: map)

            bounds.size.width = CGFloat(mapRender.mapWidth)
            bounds.size.height = CGFloat(mapRender.mapHeight)

        } catch {
            print(error.localizedDescription) // TODO: Handle Error
        }
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let surface = GraphicFactory.loadTerrainTilesetSurface()
        context.draw(surface, in: rect)
        //        context.draw(surface, in: rect)
        //        context.draw(surface.layer, at: .zero)
        //        do {
        //            context.draw(surface.layer, at: .zero)
        //            //            try layer.draw(from: surface, dx: 0, dy: 0, width: 100, height: 100, sx: 0, sy: 0)
        //            //            try mapRender.drawMap(surface: layer, typeSurface: layer, rect: Rectangle(xPosition: 0, yPosition: 0, width: mapRender.mapWidth, height: mapRender.mapHeight), level: 0)
        //        } catch {
        //            print(error.localizedDescription) // TODO: Handle Error
        //        }
    }
}
