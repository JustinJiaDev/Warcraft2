import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController {

    private let mapIndex = 2

    fileprivate var selectedPeasant: PlayerAsset?

    lazy var midiPlayer: AVMIDIPlayer = try! createMIDIPlayer()

    lazy var gameModel: GameModel = try! createGameModel(mapIndex: self.mapIndex)
    lazy var map: AssetDecoratedMap = try! createAssetDecoratedMap(mapIndex: self.mapIndex)
    lazy var mapRenderer: MapRenderer = try! createMapRenderer(map: self.map)
    lazy var assetRenderer: AssetRenderer = try! createAssetRenderer(gameModel: self.gameModel)
    lazy var fogRenderer: FogRenderer = try! createFogRenderer(map: self.map)
    lazy var viewportRenderer: ViewportRenderer = ViewportRenderer(mapRenderer: self.mapRenderer, assetRenderer: self.assetRenderer, fogRenderer: self.fogRenderer)
    lazy var unitActionRenderer: UnitActionRenderer = try! createUnitActionRenderer(gameModel: self.gameModel)

    lazy var scene: SKScene = createScene(width: self.viewportRenderer.lastViewportWidth, height: self.viewportRenderer.lastViewportHeight)
    lazy var typeScene: SKScene = createTypeScene(width: self.viewportRenderer.lastViewportWidth, height: self.viewportRenderer.lastViewportHeight)

    lazy var mapView: SKView = createMapView(mapRenderer: self.mapRenderer)
    lazy var miniMapView: MiniMapView = createMiniMapView(mapRenderer: self.mapRenderer)
    lazy var actionMenuView = createActionMenuView()

    override func viewDidLoad() {
        super.viewDidLoad()

        BasicCapabilities.registrant.register()
        BuildingUpgradeCapabilities.registrant.register()
        UnitUpgradeCapabilities.registrant.register()

        viewportRenderer.initViewportDimensions(width: self.view.bounds.width, height: self.view.bounds.height)

        self.view = mapView
        view.addSubview(miniMapView)
        view.addSubview(actionMenuView)

        midiPlayer.prepareToPlay()
        midiPlayer.play()

        mapView.presentScene(scene)

        CADisplayLink(target: self, selector: #selector(timestep)).add(to: .current, forMode: .defaultRunLoopMode)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard touches.count == 1 else {
            return
        }
        let touch = touches.first!
        let location = touch.location(in: scene)
        let previousLocation = touch.previousLocation(in: scene)
        let deltaY = Int(location.y - previousLocation.y)
        let deltaX = Int(location.x - previousLocation.x)
        viewportRenderer.panWest(deltaX)
        viewportRenderer.panSouth(deltaY)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else {
            return
        }
        let screenLocation = touches.first!.location(in: scene)
        let target = PlayerAsset(playerAssetType: PlayerAssetType())
        var detailedPosition = viewportRenderer.detailedPosition(of: Position(x: Int(screenLocation.x), y: Int(screenLocation.y)))
        detailedPosition.normalizeToTileCenter()
        target.position = detailedPosition
        if let selected = selectedPeasant {
            selected.pushCommand(AssetCommand(action: .walk, capability: .buildPeasant, assetTarget: target, activatedCapability: nil))
            selectedPeasant = nil
        } else {
            selectedPeasant = gameModel.actualMap.assets.first { asset in
                return asset.assetType.name == "Peasant" && distanceBetween(asset.position, target.position) < Position.tileWidth
            }
            if let selectedPeasant = selectedPeasant {
                actionMenuView.isHidden = false
                unitActionRenderer.drawUnitAction(on: actionMenuView, selectionList: [selectedPeasant], currentAction: .none)
            } else {
                actionMenuView.isHidden = true
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController {
    func timestep() {
        gameModel.timestep()
        let rectangle = Rectangle(x: 0, y: 0, width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)
        scene.removeAllChildren()
        viewportRenderer.drawViewport(
            on: scene,
            typeSurface: typeScene,
            selectionMarkerList: [],
            selectRect: rectangle,
            currentCapability: .none
        )
    }
}
