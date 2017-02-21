import UIKit
import AVFoundation

fileprivate func url(_ pathComponents: String...) -> URL {
    return pathComponents.reduce(Bundle.main.url(forResource: "data", withExtension: nil)!, { result, pathComponent in
        return result.appendingPathComponent(pathComponent)
    })
}

fileprivate func tileset(_ name: String) throws -> GraphicTileset {
    let tilesetSource = try FileDataSource(url: url("img", name.appending(".dat")))
    let tileset = GraphicTileset()
    try tileset.loadTileset(from: tilesetSource)
    return tileset
}

fileprivate func multicolorTileset(_ name: String) throws -> GraphicMulticolorTileset {
    let tilesetSource = try FileDataSource(url: url("img", name.appending(".dat")))
    let tileset = GraphicMulticolorTileset()
    try tileset.loadTileset(from: tilesetSource)
    return tileset
}

class GameViewController: UIViewController {

    private let mapIndex = 0
    var gameModel: GameModel!
    var mapRenderer: MapRenderer!
    var assetRenderer: AssetRenderer!
    var map: AssetDecoratedMap!
    var fogRenderer: FogRenderer!
    var viewportRenderer: ViewportRenderer!

    private lazy var midiPlayer: AVMIDIPlayer = {
        do {
            return try AVMIDIPlayer(contentsOf: url("snd", "music", "intro.mid"), soundBankURL: url("snd", "generalsoundfont.sf2"))
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }()

    private func createAssetDecoratedMap() -> AssetDecoratedMap {
        do {
            let mapsContainer = try FileDataContainer(url: url("map"))
            AssetDecoratedMap.loadMaps(from: mapsContainer)
            return AssetDecoratedMap.map(at: self.mapIndex)
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }

    private func createFogRenderer() -> FogRenderer {
        do {
            let fogTileset = try tileset("Fog")
            return try FogRenderer(tileset: fogTileset, map: self.map.createVisibilityMap())
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }

    private var mapView: MapView!

    private func createMapRenderer() -> MapRenderer {
        do {
            let configuration = try FileDataSource(url: url("img", "MapRendering.dat"))
            let terrainTileset = try tileset("Terrain")
            Position.setTileDimensions(width: terrainTileset.tileWidth, height: terrainTileset.tileHeight)
            return try MapRenderer(configuration: configuration, tileset: terrainTileset, map: self.map)
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }

    private func createAssetRenderer() -> AssetRenderer {
        do {
            let colors = GraphicRecolorMap()
            var tilesets: [GraphicMulticolorTileset] = Array(repeating: GraphicMulticolorTileset(), count: AssetType.max.rawValue)
            tilesets[AssetType.peasant.rawValue] = try multicolorTileset("Peasant")
            tilesets[AssetType.footman.rawValue] = try multicolorTileset("Footman")
            tilesets[AssetType.archer.rawValue] = try multicolorTileset("Archer")
            tilesets[AssetType.ranger.rawValue] = try multicolorTileset("Ranger")
            tilesets[AssetType.goldMine.rawValue] = try multicolorTileset("GoldMine")
            tilesets[AssetType.townHall.rawValue] = try multicolorTileset("TownHall")
            tilesets[AssetType.keep.rawValue] = try multicolorTileset("Keep")
            tilesets[AssetType.castle.rawValue] = try multicolorTileset("Castle")
            tilesets[AssetType.farm.rawValue] = try multicolorTileset("Farm")
            tilesets[AssetType.barracks.rawValue] = try multicolorTileset("Barracks")
            tilesets[AssetType.lumberMill.rawValue] = try multicolorTileset("LumberMill")
            tilesets[AssetType.blacksmith.rawValue] = try multicolorTileset("Blacksmith")
            tilesets[AssetType.scoutTower.rawValue] = try multicolorTileset("ScoutTower")
            tilesets[AssetType.guardTower.rawValue] = try multicolorTileset("GuardTower")
            tilesets[AssetType.cannonTower.rawValue] = try multicolorTileset("CannonTower")
            let markerTileset = try tileset("Marker")
            let corpseTileset = try tileset("Corpse")
            let fireTilesets = [try tileset("FireSmall"), try tileset("FireLarge")]
            let buildingDeathTileset = try tileset("BuildingDeath")
            let arrowTileset = try tileset("Arrow")
            //            _ = PlayerData(map: self.map, color: .blue)
            //            _ = PlayerData(map: self.map, color: .none)
            //            _ = PlayerData(map: self.map, color: .red)
            let assetRenderer = AssetRenderer(
                colors: colors,
                tilesets: tilesets,
                markerTileset: markerTileset,
                corpseTileset: corpseTileset,
                fireTilesets: fireTilesets,
                buildingDeathTileset: buildingDeathTileset,
                arrowTileset: arrowTileset,
                player: gameModel.player(with: .red),
                map: gameModel.player(with: .red).playerMap
            )
            return assetRenderer
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        midiPlayer.prepareToPlay()
        midiPlayer.play()

        do {
            try PlayerAssetType.loadTypes(from: FileDataContainer(url: url("res")))
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
        map = createAssetDecoratedMap()
        gameModel = GameModel(mapIndex: self.mapIndex, seed: 0x123_4567_89ab_cdef, newColors: PlayerColor.getAllValues())
        mapRenderer = createMapRenderer()
        assetRenderer = createAssetRenderer()
        fogRenderer = createFogRenderer()
        viewportRenderer = ViewportRenderer(mapRenderer: mapRenderer, assetRenderer: assetRenderer, fogRenderer: fogRenderer)

        mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)), viewportRenderer: viewportRenderer)
        let miniMapView = MiniMapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)), mapRenderer: mapRenderer)
        view.addSubview(mapView)
        view.addSubview(miniMapView)

        let myTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(triggerAnimation))
        self.view.addGestureRecognizer(myTapGestureRecognizer)
    }

    func triggerAnimation() {

        let displayLink = CADisplayLink(target: self, selector: #selector(test))
        displayLink.frameInterval = 4
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    }

    func test() {

        let start = Date()

        do {

            try gameModel?.timestep()
            // print("loop")

        } catch {
            fatalError("Error Thrown By Timestep")
        }

        mapView.setNeedsDisplay()

        let finish = Date()

        let time = finish.timeIntervalSince(start)
        print(time)

        // print("hi")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
