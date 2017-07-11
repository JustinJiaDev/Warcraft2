import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController {
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

        let mapConfiguration = try FileDataSource(url: url("img", "MapRendering.dat"))
        let colors = try colorMap("Colors")
        let assetColor = try colorMap("AssetColor")
        var tilesets: [GraphicMulticolorTileset] = Array(repeating: GraphicMulticolorTileset(), count: AssetType.allValues.count)
        tilesets[AssetType.peasant.rawValue] = try multicolorTileset("Peasant", colors)
        tilesets[AssetType.footman.rawValue] = try multicolorTileset("Footman", colors)
        tilesets[AssetType.archer.rawValue] = try multicolorTileset("Archer", colors)
        tilesets[AssetType.ranger.rawValue] = try multicolorTileset("Ranger", colors)
        tilesets[AssetType.goldMine.rawValue] = try multicolorTileset("GoldMine", colors)
        tilesets[AssetType.townHall.rawValue] = try multicolorTileset("TownHall", colors)
        tilesets[AssetType.keep.rawValue] = try multicolorTileset("Keep", colors)
        tilesets[AssetType.castle.rawValue] = try multicolorTileset("Castle", colors)
        tilesets[AssetType.farm.rawValue] = try multicolorTileset("Farm", colors)
        tilesets[AssetType.barracks.rawValue] = try multicolorTileset("Barracks", colors)
        tilesets[AssetType.lumberMill.rawValue] = try multicolorTileset("LumberMill", colors)
        tilesets[AssetType.blacksmith.rawValue] = try multicolorTileset("Blacksmith", colors)
        tilesets[AssetType.scoutTower.rawValue] = try multicolorTileset("ScoutTower", colors)
        tilesets[AssetType.guardTower.rawValue] = try multicolorTileset("GuardTower", colors)
        tilesets[AssetType.cannonTower.rawValue] = try multicolorTileset("CannonTower", colors)
        let terrain = try tileset("Terrain")
        let fog = try tileset("Fog")
        let marker = try tileset("Marker")
        let corpse = try tileset("Corpse")
        let fire = [try tileset("FireSmall"), try tileset("FireLarge")]
        let buildingDeath = try tileset("BuildingDeath")
        let arrow = try tileset("Arrow")
        let icons = try tileset("Icons")
        let miniIcons = try tileset("MiniIcons")

        Position.setTileDimensions(width: terrain.tileWidth, height: terrain.tileHeight)

        midiPlayer = try AVMIDIPlayer(contentsOf: url("snd", "music", "intro.mid"), soundBankURL: url("snd", "generalsoundfont.sf2"))

        gameModel = GameModel(mapIndex: AssetDecoratedMap.currentMapIndex, seed: 0x123_4567_89ab_cdef, newColors: PlayerColor.allValues)
        ai = AIPlayer(playerData: gameModel.player(.red), downSample: PlayerAsset.updateFrequency, aiLevel: AIPlayer.level)
        playerData = gameModel.player(.blue)

        mapRenderer = try MapRenderer(configuration: mapConfiguration, tileset: terrain, map: playerData.actualMap)
        assetRenderer = AssetRenderer(
            colors: assetColor,
            tilesets: tilesets,
            markerTileset: marker,
            corpseTileset: corpse,
            fireTilesets: fire,
            buildingDeathTileset: buildingDeath,
            arrowTileset: arrow,
            player: playerData,
            map: playerData.playerMap
        )
        fogRenderer = try FogRenderer(tileset: fog, map: playerData.visibilityMap)
        viewportRenderer = ViewportRenderer(mapRenderer: mapRenderer, assetRenderer: assetRenderer, fogRenderer: fogRenderer)

        unitActionRenderer = UnitActionRenderer(icons: icons, color: playerData.color, player: playerData, delegate: self)

        actionMenuView = createActionMenuView()
        miniMapView = MiniMapView(mapRenderer: mapRenderer, assetRenderer: assetRenderer, fogRenderer: fogRenderer, viewportRenderer: viewportRenderer)
        statsView = StatsView(size: CGSize(width: 150, height: 230), icons: icons)
        sideView = createSideView(size: CGSize(width: 150, height: view.bounds.height), miniMapView: miniMapView, statsView: statsView)
        resourceView = ResourceView(size: CGSize(width: view.bounds.width - sideView.bounds.width + 1, height: 32), icons: miniIcons, playerData: playerData)
        mapView = SKView(frame: CGRect(origin: .zero, size: CGSize(width: view.bounds.width - sideView.bounds.width, height: view.bounds.height - resourceView.bounds.height)))

        mapView.isOpaque = true
        resourceView.isOpaque = true
        sideView.isOpaque = true

        viewportRenderer.initViewportDimensions(width: view.bounds.width - sideView.bounds.width, height: view.bounds.height - resourceView.bounds.height)

        sideView.frame.origin = .zero
        resourceView.frame.origin = CGPoint(x: sideView.bounds.size.width - 1, y: 0)
        mapView.frame.origin = CGPoint(x: sideView.bounds.width, y: resourceView.bounds.height)

        view.addSubview(mapView)
        view.addSubview(resourceView)
        view.addSubview(sideView)
        view.addSubview(actionMenuView)

        scene = GraphicFactory.createSurface(width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight)
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

    private func createActionMenuView() -> UICollectionView {
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

    private func createSideView(size: CGSize, miniMapView: MiniMapView, statsView: StatsView) -> UIView {
        let sideView = UIView(frame: CGRect(origin: .zero, size: size))
        sideView.backgroundColor = .black
        sideView.layer.borderColor = UIColor.white.cgColor
        sideView.layer.borderWidth = 1
        sideView.addSubview(statsView)
        sideView.addSubview(miniMapView)
        let scale = size.width / miniMapView.bounds.size.width
        miniMapView.transform = CGAffineTransform(scaleX: scale, y: scale)
        miniMapView.frame.origin = .zero
        statsView.frame.origin = CGPoint(x: 0, y: miniMapView.bounds.height + 40)
        return sideView
    }
}

extension GameViewController {
    @objc func timestep() {
        ai.calculateCommand()
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
            present(UIAlertController(title: "Victory!", message: nil, preferredStyle: .alert), animated: true)
            displayLink.remove(from: .current, forMode: .defaultRunLoopMode)
        }
    }
}

extension GameViewController {
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
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

    @objc func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
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
