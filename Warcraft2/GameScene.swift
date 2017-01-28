import Foundation
import SpriteKit
import AudioToolbox

class GameScene: SKScene {

    let mapScale = CGFloat(0.25)
    var mapWidth: CGFloat = 0
    var mapHeight: CGFloat = 0
    let mainCamera = SKCameraNode()

    let helloSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "selected4", ofType: "wav")!)
    var helloSoundID: SystemSoundID = 1

    // Called when transitioning to the view
    override func didMove(to _: SKView) {

        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playSound))
        self.view?.addGestureRecognizer(tapGestureRecognizer)

        drawMap()
        initSound()
    }

    func playSound() {
        AudioServicesPlaySystemSound(helloSoundID)
    }

    func initSound() {

        let helloSoundCFURL: CFURL = helloSoundURL as CFURL
        AudioServicesCreateSystemSoundID(helloSoundCFURL, &helloSoundID)
    }

    // Draws all map tiles contained in MapManager to the scene, in a grid format
    func drawMap() {
        do {
            let terrainManager = TerrainManager()
            terrainManager.loadTerrainTextures()

            guard let mapURL = Bundle.main.url(forResource: "maze", withExtension: "map") else {
                throw TerrainMapError.unknownMapFile
            }
            let mapSource = try FileDataSource(url: mapURL)
            let terrainMap = TerrainMap()
            try terrainMap.loadMap(source: mapSource)

            let terrainTileSize = 32

            mapWidth = CGFloat((terrainMap.width + 2) * terrainTileSize)
            mapHeight = CGFloat((terrainMap.height + 2) * terrainTileSize)

            self.size = CGSize(width: mapWidth, height: mapHeight)
            self.scaleMode = .fill

            self.camera = mainCamera
            mainCamera.setScale(mapScale)
            self.addChild(mainCamera)
            moveCameraTo(centerX: mapWidth / 2, centerY: mapHeight / 2)

            // Draw map tiles
            var nodes: [[SKSpriteNode]] = terrainMap.map.map { line in
                return line.map { tileType in
                    let tileTexture = terrainManager.terrainTiles[terrainManager.terrainTypes.index(of: tileType)!]
                    let node = SKSpriteNode(texture: tileTexture)
                    node.size = CGSize(width: 32, height: 32)
                    node.anchorPoint = CGPoint.zero
                    return node
                }
            }.reversed()

            for i in 0 ..< nodes.count {
                for j in 0 ..< nodes[0].count {
                    nodes[i][j].position = CGPoint(x: j * terrainTileSize, y: i * terrainTileSize)
                    self.addChild(nodes[i][j])
                }
            }
        } catch {
            print(error.localizedDescription) // TODO: Handle Error
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first!
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            let deltaY = location.y - previousLocation.y
            let deltaX = location.x - previousLocation.x
            moveCameraBy(deltaX, deltaY)
        }
    }

    func moveCameraBy(_ deltaX: CGFloat, _ deltaY: CGFloat) {
        moveCameraTo(centerX: mainCamera.position.x - deltaX, centerY: mainCamera.position.y - deltaY)
    }

    func moveCameraTo(centerX: CGFloat, centerY: CGFloat) {
        // The game bounds will be applied to these variables
        var constrainedCenterX = centerX
        var constrainedCenterY = centerY
        // Apply x bounds
        let minX = centerX - mapWidth / 2 * mainCamera.xScale
        let maxX = centerX + mapWidth / 2 * mainCamera.xScale
        if minX < 0 { constrainedCenterX -= minX /* minX is negative */ }
        if maxX > mapWidth { constrainedCenterX -= maxX - mapWidth }
        // Apply y bounds
        let minY = centerY - mapHeight / 2 * mainCamera.yScale
        let maxY = centerY + mapHeight / 2 * mainCamera.yScale
        if minY < 0 { constrainedCenterY -= minY /* minY is negative */ }
        if maxY > mapHeight { constrainedCenterY -= maxY - mapHeight }
        // Scroll to the as close to the desired position as possible
        // within the bounds of the game board
        mainCamera.position.x = constrainedCenterX
        mainCamera.position.y = constrainedCenterY
    }

    //    override func update(_: TimeInterval) {
    //        /* Called before each frame is rendered */
    //    }
}
