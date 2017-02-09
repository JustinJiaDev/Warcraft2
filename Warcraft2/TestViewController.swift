import UIKit
import AVFoundation

fileprivate func tileset(_ name: String) throws -> GraphicMulticolorTileset {
    guard let tilesetURL = Bundle.main.url(forResource: name, withExtension: "dat") else {
        throw GraphicTileset.GameError.failedToGetPath
    }
    let tilesetSource = try! FileDataSource(url: tilesetURL)
    let tileset = GraphicMulticolorTileset()
    try tileset.loadTileset(from: tilesetSource)
    return tileset
}

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
            let mapURL = Bundle.main.url(forResource: "maze", withExtension: "map")!
            let mapSource = try FileDataSource(url: mapURL)
            let map = AssetDecoratedMap()
            try map.loadMap(from: mapSource)
            return map
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }()

    private lazy var mapRenderer: MapRenderer = {
        do {
            let configurationURL = Bundle.main.url(forResource: "MapRendering", withExtension: "dat")!
            let configuration = try FileDataSource(url: configurationURL)
            let terrainTileset = try tileset("Terrain")
            return try MapRenderer(configuration: configuration, tileset: terrainTileset, map: self.map)
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }()

    private lazy var assetRenderer: AssetRenderer = {
        do {
            let colors = GraphicRecolorMap()
            var tilesets: [GraphicMulticolorTileset] = Array(repeating: GraphicMulticolorTileset(), count: AssetType.max.rawValue)
            tilesets[AssetType.peasant.rawValue] = try tileset("Peasant")
            tilesets[AssetType.footman.rawValue] = try tileset("Footman")
            tilesets[AssetType.archer.rawValue] = try tileset("Archer")
            tilesets[AssetType.ranger.rawValue] = try tileset("Ranger")
            tilesets[AssetType.goldMine.rawValue] = try tileset("GoldMine")
            tilesets[AssetType.townHall.rawValue] = try tileset("TownHall")
            tilesets[AssetType.keep.rawValue] = try tileset("Keep")
            tilesets[AssetType.castle.rawValue] = try tileset("Castle")
            tilesets[AssetType.farm.rawValue] = try tileset("Farm")
            tilesets[AssetType.barracks.rawValue] = try tileset("Barracks")
            tilesets[AssetType.lumberMill.rawValue] = try tileset("LumberMill")
            tilesets[AssetType.blacksmith.rawValue] = try tileset("Blacksmith")
            tilesets[AssetType.scoutTower.rawValue] = try tileset("ScoutTower")
            tilesets[AssetType.guardTower.rawValue] = try tileset("GuardTower")
            tilesets[AssetType.cannonTower.rawValue] = try tileset("CannonTower")
            let markerTileset = try tileset("Marker")
            let corpseTileset = try tileset("Corpse")
            let fireTilesets = [try tileset("FireSmall"), try tileset("FireLarge")]
            let buildingDeathTileset = try tileset("BuildingDeath")
            let arrowTileset = try tileset("Arrow")
            let playerData = PlayerData(map: self.map, color: .blue)
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

        let mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)), mapRenderer: mapRenderer, assetRenderer: assetRenderer)
        let miniMapView = MiniMapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)), mapRenderer: mapRenderer)
        view.addSubview(mapView)
        view.addSubview(miniMapView)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
