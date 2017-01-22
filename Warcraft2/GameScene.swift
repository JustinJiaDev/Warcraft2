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

    var mapScale = CGFloat(0.25)
    var mapWidth: CGFloat = 0
    var mapHeight: CGFloat = 0
    var parentViewController: GameViewController?
    let mainCamera = SKCameraNode()

    override func didMove(to _: SKView) {

        /* Setup your scene here */

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

        self.camera = mainCamera
        self.mainCamera.setScale(mapScale)
        self.scaleMode = .aspectFill
        self.addChild(mainCamera)
        self.mainCamera.position = CGPoint(x: mapWidth / 2, y: mapHeight / 2)
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
                spriteNode.xScale = 1
                spriteNode.yScale = 1
                spriteNode.position = CGPoint(
                    x: CGFloat(j * terrainTileSize),
                    y: CGFloat(i * terrainTileSize)
                )
                self.addChild(spriteNode)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            let deltaY = location.y - previousLocation.y
            let deltaX = location.x - previousLocation.x

            mainCamera.position.x -= deltaX
            mainCamera.position.y -= deltaY
        }
    }
    
    
    // Code below was an old attempt at limiting camera movement to map.  NOT WORKING
    
    //    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
    //        for touch in touches {
    //            let location = touch.location(in: self)
    //            let previousLocation = touch.previousLocation(in: self)
    //            let deltaY = location.y - previousLocation.y
    //            let deltaX = location.x - previousLocation.x
    //
    //            if (mainCamera.position.x - deltaX) < mapWidth * mapScale * 0.5 {
    //                mainCamera.position.x = mapWidth * mapScale * 0.5
    //            } else if mainCamera.position.x - deltaX > mapWidth - mapWidth * mapScale * 0.5 {
    //                mainCamera.position.x = mapWidth - mapWidth * mapScale * 0.5
    //            } else {
    //                mainCamera.position.x -= deltaX
    //            }
    //
    //
    //            // Percentage of the height covered by the camera / 2, at both ends
    //            if (mainCamera.position.y - deltaY) < mapHeight * mapScale * 0.5 {
    //                mainCamera.position.y = mapHeight * mapScale * 0.5
    //            } else if mainCamera.position.y - deltaY > mapHeight - mapHeight * mapScale * 0.5 {
    //                mainCamera.position.y = mapHeight - mapHeight * mapScale * 0.5
    //            } else {
    //                mainCamera.position.y -= deltaY
    //            }
    //        }
    //    }

    //    override func update(_: TimeInterval) {
    //        /* Called before each frame is rendered */
    //    }
}
