//
//  GameScene.swift
//  Warcraft2
//
//  Created by Bryce Korte on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {

    let mapScale = CGFloat(0.25)
    var mapWidth: CGFloat = 0
    var mapHeight: CGFloat = 0
    var parentViewController: GameViewController?
    let mainCamera = SKCameraNode()

    // Called when transitioning to the view
    override func didMove(to _: SKView) {
        drawMap()
    }

    // Draws all map tiles contained in MapManager to the scene, in a grid format
    func drawMap() {
        let terrainManager = TerrainManager()
        terrainManager.loadTerrainTextures()

        let mapManager = MapManager()
        mapManager.loadMap()

        let terrainTileSize = 32

        mapWidth = CGFloat(mapManager.mapXCount() * terrainTileSize)
        mapHeight = CGFloat(mapManager.mapYCount() * terrainTileSize)
        self.size = CGSize(width: mapWidth, height: mapHeight)

        self.scaleMode = .aspectFill

        self.camera = mainCamera
        mainCamera.setScale(mapScale)
        self.addChild(mainCamera)
        moveCameraTo(centerX: mapWidth / 2, centerY: mapHeight / 2)
        // Draw map tiles
        for i in (0 ..< mapManager.mapYCount()).reversed() {
            for j in 0 ..< mapManager.mapXCount() {
                let currentTerrainType = mapManager.mapTileTypes[i][j]
                let index = terrainManager.terrainTypes.index(of: currentTerrainType)
                let spriteNode = SKSpriteNode(texture: terrainManager.terrainTiles[index!])
                spriteNode.size.width = 32
                spriteNode.size.height = 32
                spriteNode.anchorPoint.x = 0
                spriteNode.anchorPoint.y = 0
                spriteNode.position = CGPoint(
                    x: CGFloat(j * terrainTileSize),
                    y: CGFloat(i * terrainTileSize)
                )
                self.addChild(spriteNode)
            }
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
