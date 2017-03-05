import UIKit
import AVFoundation
import SpriteKit

class GameViewController: UIViewController {

    private let mapIndex = 2

    fileprivate var selectedPeasant: PlayerAsset?
    fileprivate var unitActionRenderer: UnitActionRenderer?
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

    private func createUnitActionRenderer() -> UnitActionRenderer {
        do {
            let bevel = try Bevel(tileset: tileset("Icons"))
            let icons = try tileset("Icons")

            let unitActionRenderer = UnitActionRenderer(
                bevel: bevel,
                icons: icons,
                color: gameModel.player(.blue).color,
                player: gameModel.player(.blue)
            )
            return unitActionRenderer
        } catch {
            fatalError(error.localizedDescription) // TODO: Handle Error
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewportRenderer.initViewportDimensions(width: self.view.bounds.width, height: self.view.bounds.height)

        let mapView = createMapView(mapRenderer: mapRenderer)
        let miniMapView = createMiniMapView(mapRenderer: mapRenderer)
        self.view = mapView
        view.addSubview(miniMapView)

        midiPlayer.prepareToPlay()
        midiPlayer.play()

        // load capabilities
        BasicCapabilities.register()

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
                showActionMenu(playerAsset: selectedPeasant)
            }
        }
    }

    func showActionMenu(playerAsset: PlayerAsset) {
        unitActionRenderer = createUnitActionRenderer()
        let actionIndices = unitActionRenderer!.getUnitActionIndex(selectionList: [playerAsset], currentAction: .none)
        guard actionIndices.count != 0 else {
            return
        }

        let screenSize = UIScreen.main.bounds
        let actionMenuView = ActionMenuView(frame: CGRect(origin: CGPoint(x: 0, y: CGFloat(screenSize.height) * 0.8), size: CGSize(width: screenSize.width, height: screenSize.height / 5)), unitActionRenderer: 1)
        actionMenuView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        actionMenuView.tag = 1
        let scrollView = UIScrollView(frame: CGRect(x: actionMenuView.bounds.size.width / 10, y: 0, width: actionMenuView.bounds.size.width / 5 * 4, height: actionMenuView.bounds.size.height))

        let iconSize = 60
        var xPosition = 10

        scrollView.contentSize = CGSize(width: actionMenuView.bounds.size.width * 1.5, height: actionMenuView.bounds.size.height)

        let actionIcons = splitVerticalSpriteSheetToUIImages(from: url("img", "Icons.png"), numSprites: 179)

        for i in 0 ..< actionIndices.count {
            let actionIndex = actionIndices[i]
            let actionButton = UIButton(frame: CGRect(x: CGFloat(xPosition), y: (scrollView.bounds.size.height - CGFloat(iconSize)) / 2, width: CGFloat(iconSize), height: CGFloat(iconSize)))
            let actionImage = resizeImage(image: actionIcons[actionIndex], targetSize: CGSize(width: iconSize, height: iconSize))

            actionButton.setImage(actionImage, for: .normal)
            actionButton.addTarget(self, action: #selector(actionButtonHandler), for: .touchUpInside)
            xPosition += (10 + iconSize)
            scrollView.addSubview(actionButton)
        }

        let btn = UIButton(frame: CGRect(x: actionMenuView.bounds.size.width - 30, y: 0, width: 30, height: 30))
        btn.setTitle("X", for: .normal)
        btn.addTarget(self, action: #selector(exitButtonAction), for: .touchUpInside)
        btn.tag = 1

        actionMenuView.addSubview(scrollView)
        actionMenuView.addSubview(btn)
        view.addSubview(actionMenuView)
    }

    func actionButtonHandler(sender: UIButton!) {
        if let selectedPeasant = selectedPeasant {
            print("click")
            let hardCodedGoldMine = gameModel.actualMap.assets[1]
            let command = AssetCommand(action: .mineGold, capability: .mine, assetTarget: hardCodedGoldMine, activatedCapability: nil)
            selectedPeasant.pushCommand(command)
        }
    }

    func exitButtonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            if let viewWithTag = self.view.viewWithTag(1) {
                viewWithTag.removeFromSuperview()
            }
        }
    }

    // For splitting a sprite sheet (input as UIImage) into numSprites different UIImage, returned as [UIImage]
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

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
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
