import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController {

    private let mapIndex = 1

    fileprivate var selectedAsset: PlayerAsset?
    fileprivate var selectedTarget: PlayerAsset?
    fileprivate var selectedAction: AssetCapabilityType?

    fileprivate var lastTranslation: CGPoint = .zero

    lazy var midiPlayer: AVMIDIPlayer = try! createMIDIPlayer()

    lazy var gameModel: GameModel = try! createGameModel(mapIndex: self.mapIndex)
    lazy var playerData: PlayerData = self.gameModel.player(.blue)
    lazy var map: AssetDecoratedMap = try! createAssetDecoratedMap(mapIndex: self.mapIndex)
    lazy var mapRenderer: MapRenderer = try! createMapRenderer(map: self.playerData.actualMap)
    lazy var assetRenderer: AssetRenderer = try! createAssetRenderer(playerData: self.playerData)
    lazy var fogRenderer: FogRenderer = try! createFogRenderer(map: self.map)
    lazy var viewportRenderer: ViewportRenderer = ViewportRenderer(mapRenderer: self.mapRenderer, assetRenderer: self.assetRenderer, fogRenderer: self.fogRenderer)
    lazy var unitActionRenderer: UnitActionRenderer = try! createUnitActionRenderer(playerData: self.playerData, delegate: self)
    lazy var resourceRenderer: ResourceRenderer = ResourceRenderer(loadedPlayer: self.playerData, resourceBarView: self.resourceBarView)

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

        do {
            gameModel = try createGameModel(mapIndex: self.mapIndex)
            playerData = self.gameModel.player(.blue)
            map = try createAssetDecoratedMap(mapIndex: self.mapIndex)
            mapRenderer = try createMapRenderer(map: self.playerData.actualMap)
            assetRenderer = try createAssetRenderer(playerData: self.playerData)
            fogRenderer = try createFogRenderer(map: self.map)
            viewportRenderer = ViewportRenderer(mapRenderer: mapRenderer, assetRenderer: assetRenderer, fogRenderer: fogRenderer)
            unitActionRenderer = try createUnitActionRenderer(playerData: self.playerData, delegate: self)
            resourceRenderer = ResourceRenderer(loadedPlayer: self.playerData, resourceBarView: self.resourceBarView)
        } catch {
            
        }
        
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

        mapView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))

        CADisplayLink(target: self, selector: #selector(timestep)).add(to: .current, forMode: .defaultRunLoopMode)
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
        resourceRenderer.drawResources()
    }
}

extension GameViewController {
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

    func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }

        let screenLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        var selectedPosition = viewportRenderer.detailedPosition(of: Position(x: Int(screenLocation.x), y: Int(screenLocation.y)))
        selectedPosition.normalizeToTileCenter()

        if !actionMenuView.isHidden {
            actionMenuView.isHidden = true
        } else if let selectedAsset = selectedAsset, let selectionAction = selectedAction {
            selectedTarget = playerData.findNearestAsset(at: selectedPosition, within: Position.tileWidth * 2)
            if selectedAction != .mine || selectedTarget == nil || selectedTarget!.type != .goldMine {
                selectedTarget = playerData.createMarker(at: selectedPosition, addToMap: true)
            }
            apply(actor: selectedAsset, target: selectedTarget!, action: selectionAction, playerData: playerData)
        } else if let newSelection = playerData.findNearestAsset(at: selectedPosition, within: Position.tileWidth) {
            selectedAsset = newSelection
            actionMenuView.isHidden = false
            unitActionRenderer.drawUnitAction(on: actionMenuView, selectedAsset: selectedAsset, currentAction: selectedAsset?.activeCapability ?? .none)
        }
    }
}

extension GameViewController: UnitActionRendererDelegate {
    func selectedAction(_ action: AssetCapabilityType, in collectionView: UICollectionView) {
        selectedAction = action
        if [.buildSimple, .buildAdvanced].contains(action) {
            unitActionRenderer.drawUnitAction(on: actionMenuView, selectedAsset: selectedAsset, currentAction: action)
        } else {
            collectionView.isHidden = true
            if !action.needsTarget {
                apply(actor: selectedAsset!, target: selectedAsset!, action: action, playerData: playerData)
            }
        }
    }

    func apply(actor: PlayerAsset, target: PlayerAsset, action: AssetCapabilityType, playerData: PlayerData) {
        let capability = PlayerCapability.findCapability(action)
        if capability.canApply(actor: actor, playerData: playerData, target: target) {
            capability.applyCapability(actor: actor, playerData: playerData, target: target)
        } else {
            PlayerCapability.findCapability(.cancel).applyCapability(actor: actor, playerData: playerData, target: target)
        }
        selectedAsset = nil
        selectedTarget = nil
        selectedAction = nil
    }
}
