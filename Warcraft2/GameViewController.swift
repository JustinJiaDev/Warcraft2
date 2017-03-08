import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController {

    private let mapIndex = 1

    fileprivate var selectedPeasant: PlayerAsset?

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

    lazy var mapView: SKView = createMapView(mapRenderer: self.mapRenderer)
    lazy var miniMapView: MiniMapView = createMiniMapView(mapRenderer: self.mapRenderer)
    lazy var actionMenuView = createActionMenuView()
    lazy var resourceBarView = createResourceBarView()
    lazy var assetStatsView = createAssetStatsView()

    override func viewDidLoad() {
        super.viewDidLoad()

        BasicCapabilities.registrant.register()
        BuildCapabilities.registrant.register()
        BuildingUpgradeCapabilities.registrant.register()
        UnitUpgradeCapabilities.registrant.register()

        viewportRenderer.initViewportDimensions(width: self.view.bounds.width, height: self.view.bounds.height)

        let sidebarContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: self.view.bounds.size.height))
        sidebarContainerView.backgroundColor = UIColor.black

        miniMapView.frame.origin = CGPoint(x: 30, y: 30)
        assetStatsView.setFrame(frame: CGRect(x: 0, y: miniMapView.bounds.maxY + 20, width: sidebarContainerView.bounds.size.width, height: sidebarContainerView.bounds.size.height - miniMapView.bounds.maxY + 20))

        sidebarContainerView.addSubview(miniMapView)
        sidebarContainerView.addSubview(assetStatsView)

        resourceBarView.frame = CGRect(x: sidebarContainerView.bounds.size.width, y: 0, width: self.view.bounds.size.width - sidebarContainerView.bounds.size.width, height: 35)
        resourceBarView.setNeedsLayout()

        mapView.frame.origin = CGPoint(x: sidebarContainerView.bounds.width, y: resourceBarView.bounds.height)
        mapView.frame.size = CGSize(width: view.bounds.width - sidebarContainerView.bounds.width, height: view.bounds.height - resourceBarView.bounds.height)

        view.addSubview(mapView)
        view.addSubview(actionMenuView)
        view.addSubview(sidebarContainerView)
        view.addSubview(resourceBarView)

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
        if let selected = selectedPeasant, selected.commands.isEmpty {
            selected.pushCommand(AssetCommand(action: .walk, capability: .buildPeasant, assetTarget: target, activatedCapability: nil))
            selectedPeasant = nil
        } else {
            selectedPeasant = gameModel.actualMap.assets.first { asset in
                return asset.assetType.name == "Peasant" && distanceBetween(asset.position, target.position) < Position.tileWidth
            }
            if let selectedPeasant = selectedPeasant {
                actionMenuView.isHidden = false
                unitActionRenderer.drawUnitAction(on: actionMenuView, selectionList: [selectedPeasant])
                assetStatsView.asset = selectedPeasant
                assetStatsView.setNeedsLayout()
            } else {
                actionMenuView.isHidden = true
                assetStatsView.asset = nil
                assetStatsView.setNeedsLayout()
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
        resourceRenderer.drawResources()
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
