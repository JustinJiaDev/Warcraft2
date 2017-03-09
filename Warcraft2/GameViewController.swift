import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController {

    private let mapIndex = 1

    fileprivate var selectedAsset: PlayerAsset?
    fileprivate var selectedTarget: PlayerAsset?

    private var lastTranslation: CGPoint = .zero

    lazy var midiPlayer: AVMIDIPlayer = try! createMIDIPlayer()

    lazy var gameModel: GameModel = try! createGameModel(mapIndex: self.mapIndex)
    lazy var map: AssetDecoratedMap = try! createAssetDecoratedMap(mapIndex: self.mapIndex)
    lazy var mapRenderer: MapRenderer = try! createMapRenderer(map: self.map)
    lazy var assetRenderer: AssetRenderer = try! createAssetRenderer(gameModel: self.gameModel)
    lazy var fogRenderer: FogRenderer = try! createFogRenderer(map: self.map)
    lazy var viewportRenderer: ViewportRenderer = ViewportRenderer(mapRenderer: self.mapRenderer, assetRenderer: self.assetRenderer, fogRenderer: self.fogRenderer)
    lazy var unitActionRenderer: UnitActionRenderer = try! createUnitActionRenderer(gameModel: self.gameModel)
    lazy var resourceRenderer: ResourceRenderer = ResourceRenderer(loadedPlayer: self.gameModel.player(.blue), resourceBarView: self.resourceBarView)

    lazy var scene: SKScene = createScene(width: self.viewportRenderer.lastViewportWidth, height: self.viewportRenderer.lastViewportHeight)
    lazy var typeScene: SKScene = createTypeScene(width: self.viewportRenderer.lastViewportWidth, height: self.viewportRenderer.lastViewportHeight)

    lazy var mapView: SKView = createMapView(viewportRenderer: self.viewportRenderer, width: self.view.bounds.width - self.sideView.bounds.width, height: self.view.bounds.height - self.resourceBarView.bounds.height)
    lazy var miniMapView: MiniMapView = createMiniMapView(mapRenderer: self.mapRenderer)
    lazy var statsView: UIView = createStatsView()
    lazy var sideView: UIView = createSideView(size: CGSize(width: 150, height: self.view.bounds.height), miniMapView: self.miniMapView, statsView: self.statsView)
    lazy var actionMenuView: UICollectionView = createActionMenuView()
    lazy var resourceBarView: ResourceBarView = createResourceBarView(size: CGSize(width: self.view.bounds.width - self.sideView.bounds.width, height: 35))

    override func viewDidLoad() {
        super.viewDidLoad()

        BasicCapabilities.registrant.register()
        BuildCapabilities.registrant.register()
        BuildingUpgradeCapabilities.registrant.register()
        TrainCapabilities.registrant.register()
        UnitUpgradeCapabilities.registrant.register()

        sideView.frame.origin = .zero
        resourceBarView.frame.origin = CGPoint(x: sideView.bounds.size.width, y: 0)
        mapView.frame.origin = CGPoint(x: sideView.bounds.width, y: resourceBarView.bounds.height)

        view.addSubview(mapView)
        view.addSubview(actionMenuView)
        view.addSubview(sideView)
        view.addSubview(resourceBarView)

        midiPlayer.prepareToPlay()
        midiPlayer.play()

        mapView.presentScene(scene)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        mapView.addGestureRecognizer(panGestureRecognizer)

        CADisplayLink(target: self, selector: #selector(timestep)).add(to: .current, forMode: .defaultRunLoopMode)
    }

    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            lastTranslation = .zero
        case .changed:
            let currentTranslation = gestureRecognizer.translation(in: mapView)
            let deltaX = currentTranslation.x - lastTranslation.x
            let deltaY = currentTranslation.y - lastTranslation.y
            viewportRenderer.panWest(Int(deltaX))
            viewportRenderer.panNorth(Int(deltaY))
            lastTranslation = currentTranslation
        default:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else {
            return
        }
        let screenLocation = touches.first!.location(in: scene)
        var selectedPosition = viewportRenderer.detailedPosition(of: Position(x: Int(screenLocation.x), y: Int(screenLocation.y)))
        selectedPosition.normalizeToTileCenter()

        let playerData = gameModel.player(.blue)
        if selectedAsset == nil {
            selectedAsset = playerData.findNearestAsset(at: selectedPosition, within: Position.tileWidth * 2)
            if let selectedAsset = selectedAsset {
                actionMenuView.isHidden = false
                unitActionRenderer.drawUnitAction(on: actionMenuView, selectionList: [selectedAsset])
            }
        } else {
            if unitActionRenderer.unhandledAction.needsMarker {
                selectedTarget = playerData.findNearestAsset(at: selectedPosition, within: Position.tileWidth * 2)
                if unitActionRenderer.unhandledAction != .mine || selectedTarget == nil || selectedTarget!.type != .goldMine {
                    selectedTarget = playerData.createMarker(at: selectedPosition, addToMap: true)
                }
            } else {
                selectedTarget = playerData.findNearestAsset(at: selectedPosition, within: Position.tileWidth * 2)
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
        // determine if action from action menu should be applied to selected asset
        let playerData = gameModel.player(.blue)
        let unhandledAction = unitActionRenderer.unhandledAction
        if unhandledAction != .none {
            if !unhandledAction.needsTarget {
                apply(actor: selectedAsset!, target: selectedAsset!, action: unhandledAction, playerData: playerData)
            } else if selectedTarget != nil {
                apply(actor: selectedAsset!, target: selectedTarget!, action: unhandledAction, playerData: playerData)
            }
        }

        let rectangle = Rectangle(x: 0, y: 0, width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)
        scene.removeAllChildren()
        viewportRenderer.drawViewport(
            on: scene,
            typeSurface: typeScene,
            selectionMarkerList: [],
            selectRect: rectangle,
            currentCapability: .none
        )
        resourceRenderer.drawResources()
    }

    func apply(actor: PlayerAsset, target: PlayerAsset, action: AssetCapabilityType, playerData: PlayerData) {
        let capability = PlayerCapability.findCapability(action)
        if capability.canApply(actor: actor, playerData: playerData, target: target) {
            capability.applyCapability(actor: actor, playerData: playerData, target: target)
        } else {
            PlayerCapability.findCapability(.cancel).applyCapability(actor: actor, playerData: playerData, target: target)
        }
        unitActionRenderer.finishAction()
        selectedAsset = nil
        selectedTarget = nil
    }
}
