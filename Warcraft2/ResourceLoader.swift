import Foundation
import UIKit
import SpriteKit
import AVFoundation

func url(_ pathComponents: String...) -> URL {
    return pathComponents.reduce(Bundle.main.url(forResource: "data", withExtension: nil)!, { result, pathComponent in
        return result.appendingPathComponent(pathComponent)
    })
}

func tileset(_ name: String) throws -> GraphicTileset {
    let tilesetSource = try FileDataSource(url: url("img", name.appending(".dat")))
    let tileset = GraphicTileset()
    try tileset.loadTileset(from: tilesetSource)
    return tileset
}

func multicolorTileset(_ name: String) throws -> GraphicMulticolorTileset {
    let tilesetSource = try FileDataSource(url: url("img", name.appending(".dat")))
    let tileset = GraphicMulticolorTileset()
    try tileset.loadTileset(from: tilesetSource)
    return tileset
}

func createMIDIPlayer() throws -> AVMIDIPlayer {
    return try AVMIDIPlayer(contentsOf: url("snd", "music", "intro.mid"), soundBankURL: url("snd", "generalsoundfont.sf2"))
}

func createGameModel(mapIndex: Int) throws -> GameModel {
    return GameModel(mapIndex: mapIndex, seed: 0x123_4567_89ab_cdef, newColors: PlayerColor.allValues)
}

func createAI(playerData: PlayerData) -> AIPlayer {
    return AIPlayer(playerData: playerData, downSample: PlayerAsset.updateFrequency)
}

func createMapRenderer(playerData: PlayerData) throws -> MapRenderer {
    let mapConfiguration = try FileDataSource(url: url("img", "MapRendering.dat"))
    let terrainTileset = try tileset("Terrain")
    return try MapRenderer(configuration: mapConfiguration, tileset: terrainTileset, map: playerData.actualMap)
}

func createAssetRenderer(playerData: PlayerData) throws -> AssetRenderer {
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
    let assetRenderer = AssetRenderer(
        colors: colors,
        tilesets: tilesets,
        markerTileset: markerTileset,
        corpseTileset: corpseTileset,
        fireTilesets: fireTilesets,
        buildingDeathTileset: buildingDeathTileset,
        arrowTileset: arrowTileset,
        player: playerData,
        map: playerData.playerMap
    )
    return assetRenderer
}

func createUnitActionRenderer(playerData: PlayerData, delegate: UnitActionRendererDelegate) throws -> UnitActionRenderer {
    let bevel = try Bevel(tileset: tileset("Icons"))
    let icons = try tileset("Icons")
    let unitActionRenderer = UnitActionRenderer(
        bevel: bevel,
        icons: icons,
        color: playerData.color,
        player: playerData,
        delegate: delegate
    )
    return unitActionRenderer
}

// FIXME: REMOVE HARDCODED VALUES
func createActionMenuView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset.top = 10
    layout.sectionInset.left = 10
    layout.sectionInset.bottom = 10
    layout.minimumInteritemSpacing = 10
    layout.itemSize = CGSize(width: 46, height: 46)
    var frame = UIScreen.main.bounds
    frame.origin.x = 150
    frame.origin.y = CGFloat(UIScreen.main.bounds.height - 66)
    frame.size.height = 66
    let actionMenuView = UICollectionView(frame: frame, collectionViewLayout: layout)
    actionMenuView.backgroundColor = UIColor(white: 0.9, alpha: 0.6)
    actionMenuView.register(ImageCell.self, forCellWithReuseIdentifier: "ActionMenuViewCell")
    actionMenuView.isHidden = true
    return actionMenuView
}

func createFogRenderer(playerData: PlayerData) throws -> FogRenderer {
    let fogTileset = try tileset("Fog")
    return try FogRenderer(tileset: fogTileset, map: playerData.visibilityMap)
}

func createMapView(viewportRenderer: ViewportRenderer, width: Int, height: Int) -> SKView {
    let mapView = SKView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
    mapView.isOpaque = true
    mapView.showsFPS = true
    return mapView
}

func createMiniMapView(mapRenderer: MapRenderer) -> MiniMapView {
    return MiniMapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)), mapRenderer: mapRenderer)
}

// FIXME: REMOVE HARDCODED VALUES
func createSideView(size: CGSize, miniMapView: MiniMapView, statsView: StatsView) -> UIView {
    let sideView = UIView(frame: CGRect(origin: .zero, size: size))
    sideView.backgroundColor = UIColor.black
    sideView.addSubview(statsView)
    sideView.addSubview(miniMapView)
    miniMapView.frame.origin = CGPoint(x: 30, y: 8)
    statsView.frame.origin = CGPoint(x: 0, y: miniMapView.bounds.height + 8)
    return sideView
}

func createResourceView(size: CGSize, playerData: PlayerData) throws -> ResourceView {
    let resourceView = ResourceView(icons: try tileset("MiniIcons"), playerData: playerData)
    resourceView.bounds.size = size
    return resourceView
}

func createStatsView(size: CGSize) throws -> StatsView {
    let statsView = StatsView(icons: try tileset("Icons"))
    statsView.bounds.size = size
    return statsView
}

func createScene(width: Int, height: Int) -> SKScene {
    let scene = GraphicFactory.createSurface(width: width, height: height, type: SKScene.self)
    return scene
}

func createTypeScene(width: Int, height: Int) -> SKScene {
    let scene = GraphicFactory.createSurface(width: width, height: height, type: SKScene.self)
    return scene
}
