import UIKit
import AVFoundation
import SpriteKit

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
    private var terrainTileset: GraphicTileset!
    private var mapConfiguration: FileDataSource!
    private var selectedPeasant: PlayerAsset?
    var gameModel: GameModel!
    var mapRenderer: MapRenderer!
    var assetRenderer: AssetRenderer!
    var map: AssetDecoratedMap!
    var fogRenderer: FogRenderer!
    var viewportRenderer: ViewportRenderer!
    var midiPlayer: AVMIDIPlayer!

    private func createMidiPlayer() -> AVMIDIPlayer {
        do {
            return try AVMIDIPlayer(contentsOf: url("snd", "music", "intro.mid"), soundBankURL: url("snd", "generalsoundfont.sf2"))
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }

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

    private func createMapRenderer() -> MapRenderer {
        do {
            return try MapRenderer(configuration: mapConfiguration, tileset: terrainTileset, map: self.map)
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

    let mapScale = CGFloat(0.25)
    let mainCamera = SKCameraNode()

    var scene: SKScene!

    override func viewDidLoad() {
        super.viewDidLoad()

        midiPlayer = createMidiPlayer()

        midiPlayer.prepareToPlay()
        midiPlayer.play()

        do {
            try PlayerAssetType.loadTypes(from: FileDataContainer(url: url("res")))
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }

        do {
            mapConfiguration = try FileDataSource(url: url("img", "MapRendering.dat"))
            terrainTileset = try tileset("Terrain")
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }

        Position.setTileDimensions(width: terrainTileset.tileWidth, height: terrainTileset.tileHeight)

        map = createAssetDecoratedMap()
        gameModel = GameModel(mapIndex: self.mapIndex, seed: 0x123_4567_89ab_cdef, newColors: PlayerColor.getAllValues())
        mapRenderer = createMapRenderer()
        assetRenderer = createAssetRenderer()
        fogRenderer = createFogRenderer()
        viewportRenderer = ViewportRenderer(mapRenderer: mapRenderer, assetRenderer: assetRenderer, fogRenderer: fogRenderer)

        do {
            let rectangle = Rectangle(xPosition: 0, yPosition: 0, width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight)
            let surface = GraphicFactory.createSurface(width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight, type: GameScene.self)
            let typeSurface = GraphicFactory.createSurface(width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight, type: SKScene.self)
            try viewportRenderer.drawViewport(on: surface, typeSurface: typeSurface, selectionMarkerList: [], selectRect: rectangle, currentCapability: .none)
            let mapView = SKView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)))
            mapView.isOpaque = true
            mapView.ignoresSiblingOrder = true
            self.view = mapView
            mapView.showsFPS = true
            mapView.presentScene(surface)
            surface.camera = mainCamera
            mainCamera.setScale(mapScale)
            surface.addChild(mainCamera)
            moveCameraTo(centerX: 0, centerY: CGFloat(mapRenderer.detailedMapHeight))
            scene = surface
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
        let miniMapView = MiniMapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)), mapRenderer: mapRenderer)

        view.addSubview(miniMapView)
        triggerAnimation()
        //        let myTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickHandler))
        //        view.addGestureRecognizer(myTapGestureRecognizer)
    }

    //    func clickHandler(sender: UITapGestureRecognizer) {
    //        let target = PlayerAsset(playerAssetType: PlayerAssetType())
    //        let touchLocation = sender.location(ofTouch: 0, in: view)
    //        let xLocation = (Int(touchLocation.x) - Int(touchLocation.x) % 32) + 16
    //        let yLocation = (Int(touchLocation.y) - Int(touchLocation.y) % 32) + 16
    //        target.position = Position(x: xLocation, y: yLocation)
    //        if selectedPeasant != nil {
    //            selectedPeasant!.pushCommand(AssetCommand(action: .walk, capability: .buildPeasant, assetTarget: target, activatedCapability: nil))
    //            selectedPeasant = nil
    //        } else {
    //            for asset in gameModel.actualMap.assets {
    //                if asset.assetType.name == "Peasant" && asset.position.distance(position: target.position) < 64 {
    //                    selectedPeasant = asset
    //                }
    //            }
    //        }
    //    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let target = PlayerAsset(playerAssetType: PlayerAssetType())
        let touchLocation = touches.first!.location(in: scene)
        let xLocation = (Int(touchLocation.x) - Int(touchLocation.x) % 32) + 16
        let yLocation = mapRenderer.detailedMapHeight - ((Int(touchLocation.y) - Int(touchLocation.y) % 32) + 16)
        target.position = Position(x: xLocation, y: yLocation)
        if selectedPeasant != nil {
            selectedPeasant!.pushCommand(AssetCommand(action: .walk, capability: .buildPeasant, assetTarget: target, activatedCapability: nil))
            selectedPeasant = nil
        } else {
            for asset in gameModel.actualMap.assets {
                if asset.assetType.name == "Peasant" && asset.position.distance(position: target.position) < 64 {
                    selectedPeasant = asset
                }
            }
        }
    }

    func triggerAnimation() {

        let displayLink = CADisplayLink(target: self, selector: #selector(test))
        displayLink.frameInterval = 1
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    }

    func moveCameraBy(_ deltaX: CGFloat, _ deltaY: CGFloat) {
        moveCameraTo(centerX: mainCamera.position.x - deltaX, centerY: mainCamera.position.y - deltaY)
    }

    func moveCameraTo(centerX: CGFloat, centerY: CGFloat) {
        let mapWidth = CGFloat(mapRenderer.detailedMapWidth)
        let mapHeight = CGFloat(mapRenderer.detailedMapHeight)

        // The game bounds will be applied to these variables
        var constrainedCenterX = centerX
        var constrainedCenterY = centerY
        // Apply x bounds
        let minX = centerX - mapWidth / 2 * mainCamera.xScale
        let maxX = centerX + mapWidth / 2 * mainCamera.xScale
        if minX < 0 { constrainedCenterX -= minX /* minX is negative */ }
        if maxX > mapWidth { constrainedCenterX -= maxX - mapWidth }
        // Apply y bounds
        let minY = centerY - mapHeight / 2 * mainCamera.yScale
        let maxY = centerY + mapHeight / 2 * mainCamera.yScale
        if minY < 0 { constrainedCenterY -= minY /* minY is negative */ }
        if maxY > mapHeight { constrainedCenterY -= maxY - mapHeight }
        // Scroll to the as close to the desired position as possible
        // within the bounds of the game board
        mainCamera.position.x = constrainedCenterX
        mainCamera.position.y = constrainedCenterY
    }

    //    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
    //        if touches.count == 1 {
    //            let touch = touches.first!
    //            let location = touch.location(in: scene)
    //            let previousLocation = touch.previousLocation(in: scene)
    //            let deltaY = location.y - previousLocation.y
    //            let deltaX = location.x - previousLocation.x
    //            moveCameraBy(deltaX, deltaY)
    //        }
    //    }

    func test() {

        //        let start = Date()

        do {
            try gameModel.timestep()
            let rectangle = Rectangle(xPosition: 0, yPosition: 0, width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight)
            try viewportRenderer.drawViewport(on: scene, typeSurface: scene, selectionMarkerList: [], selectRect: rectangle, currentCapability: .none)
        } catch {
            fatalError("Error Thrown By Timestep")
        }

        //        let finish = Date()
        //
        //        let time = finish.timeIntervalSince(start)
        //        print(time)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
