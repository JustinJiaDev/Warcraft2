import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController {

    private let mapIndex = 0

    fileprivate var selectedPeasant: PlayerAsset?
    fileprivate var originalCameraPosition: CGPoint = .zero
    fileprivate var originalTranslation: CGPoint = .zero

    lazy var midiPlayer: AVMIDIPlayer = try! createMIDIPlayer()

    lazy var gameModel: GameModel = try! createGameModel(mapIndex: self.mapIndex)
    lazy var map: AssetDecoratedMap = try! createAssetDecoratedMap(mapIndex: self.mapIndex)
    lazy var mapRenderer: MapRenderer = try! createMapRenderer(map: self.map)
    lazy var assetRenderer: AssetRenderer = try! createAssetRenderer(gameModel: self.gameModel)
    lazy var fogRenderer: FogRenderer = try! createFogRenderer(map: self.map)
    lazy var viewportRenderer: ViewportRenderer = ViewportRenderer(mapRenderer: self.mapRenderer, assetRenderer: self.assetRenderer, fogRenderer: self.fogRenderer)

    lazy var scene: SKScene = createScene(width: self.viewportRenderer.lastViewportWidth, height: self.viewportRenderer.lastViewportHeight)
    lazy var typeScene: SKScene = createTypeScene(width: self.viewportRenderer.lastViewportWidth, height: self.viewportRenderer.lastViewportHeight)

    override func viewDidLoad() {
        super.viewDidLoad()
        viewportRenderer.initViewportDimensions(width: self.view.bounds.width, height: self.view.bounds.height)

        let mapView = createMapView(mapRenderer: mapRenderer)
        let miniMapView = createMiniMapView(mapRenderer: mapRenderer)
        self.view = mapView
        view.addSubview(miniMapView)

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
        target.position = viewportRenderer.detailedPosition(of: Position(x: Int(screenLocation.x), y: Int(screenLocation.y)))
        if let selected = selectedPeasant {
            selected.pushCommand(AssetCommand(action: .walk, capability: .buildPeasant, assetTarget: target, activatedCapability: nil))
            selectedPeasant = nil
        } else {
            selectedPeasant = gameModel.actualMap.assets.first { asset in
                return asset.assetType.name == "Peasant" && distanceBetween(asset.position, target.position) < Position.tileWidth
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
