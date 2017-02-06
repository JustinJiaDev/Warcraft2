import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var miniMapView: MiniMapView!

    private var mapRender: MapRenderer?

    override func viewDidLoad() {
        super.viewDidLoad()
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

            let render = try MapRenderer(configuration: configuration, tileset: tileset, map: map)
            mapView.bounds.size = CGSize(width: render.detailedMapWidth, height: render.detailedMapHeight)
            mapView.mapRender = render
            miniMapView.bounds.size = CGSize(width: render.mapWidth, height: render.mapHeight)
            miniMapView.mapRender = render
            mapRender = render
        } catch {
            print(error.localizedDescription) // TODO: Handle Error
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
