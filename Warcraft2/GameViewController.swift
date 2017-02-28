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
    var unitActionRenderer: UnitActionRenderer!
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

    private var mapView: MapView!

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

    private func createUnitActionRenderer() -> UnitActionRenderer {
        do {
            let bevel = try Bevel(tileset: tileset("Icons"))
            let icons = try tileset("Icons")

            let unitActionRenderer = UnitActionRenderer(
                bevel: bevel,
                icons: icons,
                color: gameModel.player(with: .red).color,
                player: gameModel.player(with: .red)
            )
            return unitActionRenderer
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }

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

        mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)), viewportRenderer: viewportRenderer)
        let miniMapView = MiniMapView(frame: CGRect(origin: .zero, size: CGSize(width: mapRenderer.mapWidth, height: mapRenderer.mapHeight)), mapRenderer: mapRenderer)

        view.addSubview(mapView)
        view.addSubview(miniMapView)
        triggerAnimation()
        let myTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickHandler))
        self.mapView.addGestureRecognizer(myTapGestureRecognizer)
    }

    func clickHandler(sender: UITapGestureRecognizer) {
        let target = PlayerAsset(playerAssetType: PlayerAssetType())
        let touchLocation = sender.location(ofTouch: 0, in: self.mapView)
        let xLocation = (Int(touchLocation.x) - Int(touchLocation.x) % 32) + 16
        let yLocation = (Int(touchLocation.y) - Int(touchLocation.y) % 32) + 16
        target.position = Position(x: xLocation, y: yLocation)
        if selectedPeasant != nil {
            selectedPeasant!.pushCommand(AssetCommand(action: .walk, capability: .buildPeasant, assetTarget: target, activatedCapability: nil))
            selectedPeasant = nil
        } else {
            for asset in gameModel.actualMap.assets {
                if asset.assetType.name == "Peasant" && asset.position.distance(position: target.position) < 64 {
                    selectedPeasant = asset
                    showActionMenu()
                }
            }
        }
    }

    func triggerAnimation() {

        let displayLink = CADisplayLink(target: self, selector: #selector(test))
        displayLink.frameInterval = 1
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    }

    func showActionMenu() {
        //        unitActionRenderer = createUnitActionRenderer()
        //        unitActionRenderer.drawUnitAction(on: layer, selectionList: [PlayerAsset.init(playerAssetType: <#T##PlayerAssetType#>)], currentAction: .none)

        // Currently set to screensize's width & 1/5 height, but should set it to map container's
        let screenSize = UIScreen.main.bounds
        let actionMenuView = ActionMenuView(frame: CGRect(origin: CGPoint(x: 0, y: screenSize.height * 0.8), size: CGSize(width: screenSize.width, height: screenSize.height / 5)), unitActionRenderer: 1)
        actionMenuView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        actionMenuView.tag = 1

        let btn: UIButton = UIButton(frame: CGRect(x: actionMenuView.bounds.size.width - 30, y: 0, width: 30, height: 30))
        btn.setTitle("X", for: .normal)
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        btn.tag = 1

        let numActions = 9
        let iconSize = 60
        let scrollView = UIScrollView(frame: CGRect(x: actionMenuView.bounds.size.width / 10, y: 0, width: actionMenuView.bounds.size.width / 5 * 4, height: actionMenuView.bounds.size.height))
        var image: UIImage
        var imageView: UIImageView
        var xPosition = 10

        scrollView.contentSize = CGSize(width: actionMenuView.bounds.size.width * 1.5, height: actionMenuView.bounds.size.height)

        let actionIcons = splitVerticalSpriteSheetToUIImages(from: url("img", "Icons.png"), numSprites: 179)

        for _ in 1 ... numActions {
            //            image = UIImage(named: "./data/img/icon.png")!
            imageView = UIImageView(image: actionIcons[0])
            imageView.frame = CGRect(x: CGFloat(xPosition), y: (scrollView.bounds.size.height - CGFloat(iconSize)) / 2, width: CGFloat(iconSize), height: CGFloat(iconSize))
            xPosition += 10 + iconSize
            scrollView.addSubview(imageView)
        }

        actionMenuView.addSubview(scrollView)
        actionMenuView.addSubview(btn)
        view.addSubview(actionMenuView)
    }

    func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            if let viewWithTag = self.view.viewWithTag(1) {
                viewWithTag.removeFromSuperview()
            }
        }
    }

    // For splitting a sprite sheet (input as UIImage) into numSprites different textures, returned as [SKTexture]
    func splitVerticalSpriteSheetToUIImages(from url: URL, numSprites: Int) -> [UIImage] {
        let image = UIImage(contentsOfFile: url.path)!
        let segmentHeight: CGFloat = image.size.height / CGFloat(numSprites)
        var cropRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: segmentHeight)
        var imageSegments: [UIImage] = []
        for i in 0 ..< numSprites {
            cropRect.origin.y = CGFloat(i) * segmentHeight
            let currentSegmentCGImage = image.cgImage!.cropping(to: cropRect)
            let currentSegmentUIImage = UIImage(cgImage: currentSegmentCGImage!)
            imageSegments.append(currentSegmentUIImage)
        }
        return imageSegments
    }

    func test() {

        let start = Date()

        do {
            try gameModel.timestep()
        } catch {
            fatalError("Error Thrown By Timestep")
        }

        mapView.setNeedsDisplay()
        let finish = Date()

        let time = finish.timeIntervalSince(start)
        print(time)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
