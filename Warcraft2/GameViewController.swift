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

    lazy var mainCamera = createCamera(scale: 0.25)
    lazy var scene: SKScene = createScene(camera: self.mainCamera, width: self.mapRenderer.detailedMapWidth, height: self.mapRenderer.detailedMapHeight)
    lazy var typeScene: SKScene = createTypeScene(width: self.mapRenderer.detailedMapWidth, height: self.mapRenderer.detailedMapHeight)

    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = createMapView(mapRenderer: mapRenderer)
        let miniMapView = createMiniMapView(mapRenderer: mapRenderer)
        self.view = mapView
        view.addSubview(miniMapView)

        midiPlayer.prepareToPlay()
        midiPlayer.play()

        mapView.presentScene(scene)
        moveCameraTo(centerX: 0, centerY: CGFloat(mapRenderer.detailedMapHeight))

        CADisplayLink(target: self, selector: #selector(timestep)).add(to: .current, forMode: .defaultRunLoopMode)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard touches.count == 1 else {
            return
        }
        let touch = touches.first!
        let location = touch.location(in: scene)
        let previousLocation = touch.previousLocation(in: scene)
        let deltaY = location.y - previousLocation.y
        let deltaX = location.x - previousLocation.x
        moveCameraBy(deltaX, deltaY)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else {
            return
        }
        let location = touches.first!.location(in: scene)
        let x = (Int(location.x) - Int(location.x) % Position.tileWidth) + Position.halfTileWidth
        let y = mapRenderer.detailedMapHeight - ((Int(location.y) - Int(location.y) % Position.tileHeight) + Position.halfTileHeight)
        let target = PlayerAsset(playerAssetType: PlayerAssetType())
        target.position = Position(x: x, y: y)
        if let selected = selectedPeasant {
            selected.pushCommand(AssetCommand(action: .walk, capability: .buildPeasant, assetTarget: target, activatedCapability: nil))
            selectedPeasant = nil
        } else {
            selectedPeasant = gameModel.actualMap.assets.first { asset in
                return asset.assetType.name == "Peasant" && distanceBetween(asset.position, target.position) < asset.size
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController {

    func moveCameraBy(_ deltaX: CGFloat, _ deltaY: CGFloat) {
        moveCameraTo(centerX: mainCamera.position.x - deltaX, centerY: mainCamera.position.y - deltaY)
    }

    func moveCameraTo(centerX: CGFloat, centerY: CGFloat) {
        let mapWidth = CGFloat(mapRenderer.detailedMapWidth)
        let mapHeight = CGFloat(mapRenderer.detailedMapHeight)
        var constrainedCenterX = centerX
        var constrainedCenterY = centerY

        let minX = centerX - mapWidth / 2 * mainCamera.xScale
        let maxX = centerX + mapWidth / 2 * mainCamera.xScale
        if minX < 0 { constrainedCenterX -= minX }
        if maxX > mapWidth { constrainedCenterX -= maxX - mapWidth }

        let minY = centerY - mapHeight / 2 * mainCamera.yScale
        let maxY = centerY + mapHeight / 2 * mainCamera.yScale
        if minY < 0 { constrainedCenterY -= minY }
        if maxY > mapHeight { constrainedCenterY -= maxY - mapHeight }

        mainCamera.position.x = constrainedCenterX
        mainCamera.position.y = constrainedCenterY
    }
}

extension GameViewController {
    func timestep() {
        gameModel.timestep()
        let rectangle = Rectangle(x: 0, y: 0, width: mapRenderer.detailedMapWidth, height: mapRenderer.detailedMapHeight)
        scene.removeAllChildren()
        viewportRenderer.drawViewport(on: scene, typeSurface: typeScene, selectionMarkerList: [], selectRect: rectangle, currentCapability: .none)
    }
}
