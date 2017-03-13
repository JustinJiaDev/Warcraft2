import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController {

    private let mapIndex = 1

    fileprivate var selectedAction: AssetCapabilityType?
    fileprivate var selectedActor: PlayerAsset?

    fileprivate var lastTranslation: CGPoint = .zero

    var midiPlayer: AVMIDIPlayer!
    var gameModel: GameModel!
    var ai: AIPlayer!
    var playerData: PlayerData!

    var mapRenderer: MapRenderer!
    var assetRenderer: AssetRenderer!
    var fogRenderer: FogRenderer!
    var viewportRenderer: ViewportRenderer!

    var unitActionRenderer: UnitActionRenderer!

    var scene: GraphicSurface!

    var actionMenuView: UICollectionView!
    var miniMapView: MiniMapView!
    var statsView: StatsView!
    var sideView: UIView!
    var resourceView: ResourceView!
    var mapView: SKView!

    var displayLink: CADisplayLink!

    private func loadGame() throws {
        super.viewDidLoad()

        let terrainTileset = try tileset("Terrain")
        Position.setTileDimensions(width: terrainTileset.tileWidth, height: terrainTileset.tileHeight)

        PlayerAsset.updateFrequency = 40
        AssetRenderer.updateFrequency = 40

        AssetDecoratedMap.loadMaps(from: try FileDataContainer(url: url("map")))
        PlayerAssetType.loadTypes(from: try FileDataContainer(url: url("res")))
        PlayerUpgrade.loadUpgrades(from: try FileDataContainer(url: url("upg")))

        BasicCapabilities.registrant.register()
        BuildCapabilities.registrant.register()
        BuildingUpgradeCapabilities.registrant.register()
        TrainCapabilities.registrant.register()
        UnitUpgradeCapabilities.registrant.register()

        midiPlayer = try createMIDIPlayer()

        gameModel = try createGameModel(mapIndex: mapIndex)
        ai = createAI(playerData: gameModel.player(.red))
        playerData = gameModel.player(.blue)

        mapRenderer = try createMapRenderer(playerData: playerData)
        assetRenderer = try createAssetRenderer(playerData: playerData)
        fogRenderer = try createFogRenderer(playerData: playerData)
        viewportRenderer = ViewportRenderer(mapRenderer: mapRenderer, assetRenderer: assetRenderer, fogRenderer: fogRenderer)

        unitActionRenderer = try createUnitActionRenderer(playerData: playerData, delegate: self)

        actionMenuView = createActionMenuView()
        miniMapView = MiniMapView(mapRenderer: mapRenderer, assetRenderer: assetRenderer, fogRenderer: fogRenderer, viewportRenderer: viewportRenderer)
        statsView = try createStatsView(size: CGSize(width: 150, height: 230))
        sideView = createSideView(size: CGSize(width: 150, height: view.bounds.height), miniMapView: miniMapView, statsView: statsView)
        resourceView = try createResourceView(size: CGSize(width: view.bounds.width - sideView.bounds.width, height: 32), playerData: playerData)
        mapView = createMapView(viewportRenderer: viewportRenderer, width: view.bounds.width - sideView.bounds.width, height: view.bounds.height - resourceView.bounds.height)

        viewportRenderer.initViewportDimensions(width: view.bounds.width - sideView.bounds.width, height: view.bounds.height - resourceView.bounds.height)

        sideView.frame.origin = .zero
        resourceView.frame.origin = CGPoint(x: sideView.bounds.size.width, y: 0)
        mapView.frame.origin = CGPoint(x: sideView.bounds.width, y: resourceView.bounds.height)

        view.addSubview(mapView)
        view.addSubview(resourceView)
        view.addSubview(sideView)
        view.addSubview(actionMenuView)

        scene = createScene(width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight)
    }

    override func viewDidLoad() {
        do {
            try loadGame()
            mapView.presentScene(scene as? SKScene)

            mapView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
            mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))

            midiPlayer.prepareToPlay()
            midiPlayer.play()

            displayLink = CADisplayLink(target: self, selector: #selector(timestep))
            displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        } catch {
            printError(error.localizedDescription)
            dismiss(animated: true)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController {
    func timestep() {
        // ai.calculateCommand()
        gameModel.timestep()
        scene.clear()
        viewportRenderer.drawViewport(on: scene)
        resourceView.updateResourceInfo()
        statsView.displayAssetInfo(selectedActor)
        miniMapView.setNeedsDisplay()
        checkVictoryCondition()
    }

    private func checkVictoryCondition() {
        if ai.playerData.assets.isEmpty {
            let alertController = UIAlertController(title: "Victory!", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in alertController.dismiss(animated: true) })
            present(alertController, animated: true)
            displayLink.remove(from: .current, forMode: .defaultRunLoopMode)
        }
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
        } else if let selectedAsset = selectedActor, let selectionAction = selectedAction {
            var selectedTarget = playerData.findNearestAsset(at: selectedPosition, within: Position.tileWidth) ?? playerData.createMarker(at: selectedPosition, addToMap: false)
            if selectedAction == .mine && selectedTarget.type != .goldMine {
                selectedTarget = playerData.createMarker(at: selectedPosition, addToMap: false)
            }
            apply(actor: selectedAsset, target: selectedTarget, action: selectionAction, playerData: playerData)
        } else if let newSelection = playerData.findNearestOwnedAsset(at: selectedPosition, within: Position.tileWidth) {
            selectedActor = newSelection
            actionMenuView.isHidden = false
            unitActionRenderer.drawUnitAction(on: actionMenuView, selectedAsset: selectedActor, currentAction: selectedActor?.activeCapability ?? .none)
        }
    }
}

extension GameViewController: UnitActionRendererDelegate {
    func selectedAction(_ action: AssetCapabilityType, in collectionView: UICollectionView) {
        selectedAction = action
        if [.buildSimple, .buildAdvanced].contains(action) {
            unitActionRenderer.drawUnitAction(on: actionMenuView, selectedAsset: selectedActor, currentAction: action)
        } else {
            collectionView.isHidden = true
            if let selectedActor = selectedActor, !action.needsTarget {
                apply(actor: selectedActor, target: selectedActor, action: action, playerData: playerData)
            }
        }
    }

    func apply(actor: PlayerAsset, target: PlayerAsset, action: AssetCapabilityType, playerData: PlayerData) {
        let capability = PlayerCapability.findCapability(action)
        if capability.canApply(actor: actor, playerData: playerData, target: target) {
            capability.applyCapability(actor: actor, playerData: playerData, target: target)
        } else {
            let alertController = UIAlertController(title: nil, message: "Action can't be completed.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in alertController.dismiss(animated: true) })
            present(alertController, animated: true)
        }
        selectedActor = nil
        selectedAction = nil
    }
}
