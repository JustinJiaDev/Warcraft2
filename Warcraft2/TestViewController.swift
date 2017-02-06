import UIKit
import AVFoundation

class TestViewController: UIViewController {

    private lazy var midiPlayer: AVMIDIPlayer = {
        do {
            let soundFont = Bundle.main.url(forResource: "generalsoundfont", withExtension: "sf2")!
            let midiFile = Bundle.main.url(forResource: "intro", withExtension: "mid")!
            return try AVMIDIPlayer(contentsOf: midiFile, soundBankURL: soundFont)
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }

    }()

    private lazy var map: AssetDecoratedMap = {
        do {
            guard let mapURL = Bundle.main.url(forResource: "maze", withExtension: "map") else {
                fatalError()
            }
            let mapSource = try FileDataSource(url: mapURL)
            let map = AssetDecoratedMap()
            try map.loadMap(source: mapSource)
            return map
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }()

    private lazy var mapRenderer: MapRenderer = {
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
            return try MapRenderer(configuration: configuration, tileset: tileset, map: self.map)
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }()

    private lazy var assetRenderer: AssetRenderer = {
        do {
            let colors = GraphicRecolorMap()
            let tilesets: [GraphicMulticolorTileset] = try ["GoldMine", "Peasant"].map { name in
                let tilesetURL = Bundle.main.url(forResource: name, withExtension: "dat")!
                let tilesetSource = try FileDataSource(url: tilesetURL)
                let tileset = GraphicMulticolorTileset()
                try tileset.loadTileset(from: tilesetSource)
                return tileset
            }
            let markerTileset = GraphicTileset()
            let corpseTileset = GraphicTileset()
            let fireTilesets = [GraphicTileset()]
            let buildingDeathTileset = GraphicTileset()
            let arrowTileset = GraphicTileset()
            let playerData: PlayerData? = nil
            let assetRenderer = AssetRenderer(
                colors: colors,
                tilesets: tilesets,
                markerTileset: markerTileset,
                corpseTileset: corpseTileset,
                fireTilesets: fireTilesets,
                buildingDeathTileset: buildingDeathTileset,
                arrowTileset: arrowTileset,
                player: playerData,
                map: self.map
            )
            return assetRenderer
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        midiPlayer.prepareToPlay()
        midiPlayer.play()

        let mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)), renderer: mapRenderer)
        let miniMapView = MiniMapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)), renderer: mapRenderer)
        view.addSubview(mapView)
        view.addSubview(miniMapView)

        let assetView = AssetView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)), renderer: assetRenderer)
        view.addSubview(assetView)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
