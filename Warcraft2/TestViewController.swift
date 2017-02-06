import UIKit

class TestViewController: UIViewController {

    private var render: MapRenderer = {
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
            return try MapRenderer(configuration: configuration, tileset: tileset, map: map)
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: render.detailedMapWidth, height: render.detailedMapHeight)), render: render)
        let miniMapView = MiniMapView(frame: CGRect(origin: .zero, size: CGSize(width: render.mapWidth, height: render.mapHeight)), render: render)
        view.addSubview(mapView)
        view.addSubview(miniMapView)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
