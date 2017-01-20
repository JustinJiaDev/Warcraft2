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

    var spriteNode = SKSpriteNode()
    var parentViewController: GameViewController?

    override func didMove(to _: SKView) {

        /* Setup your scene here */

        drawMap()
    }

    // Draws all map tiles contained in MapManager to the scene, in a grid format
    func drawMap() {

        let terrainManager = TerrainManager()
        terrainManager.loadTerrainTextures()

        let mapManager = MapManager()

        let mapWidth = mapManager.mapWidth
        let mapHeight = mapManager.mapHeight

        let terrainTileSize = 32

        // Resize content view and SKView of GameViewController to match the size of the map contained in MapManager
        parentViewController!.resizeMap(width: mapWidth * terrainTileSize, height: mapHeight * terrainTileSize)

        let camera = SKCameraNode()
        self.camera = camera
        self.addChild(camera)
        if let cam = self.camera {
            //            cam.xScale = 10
            //            cam.yScale = 2
            cam.position = CGPoint(x: -mapWidth * terrainTileSize / 2, y: 0)
            print("cam exists")
        } else {
            print("cam doesn't exist")
        }

        //        self.anchorPoint.x = 0
        //        self.anchorPoint.y = 0.25

        // Draw map tiles
        for i in 0 ..< mapWidth {
            for j in 0 ..< mapHeight {
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
                    x: 0.5, // CGFloat(i * terrainTileSize), // - (self.frame.width / 2),
                    y: 0.5 // CGFloat(j * terrainTileSize) // - (self.frame.height / 2)
                )
                self.addChild(spriteNode)
            }
        }
    }

    //    func hypot(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
    //        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    //    }

    //    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
    //        /* Called when a touch begins */
    //
    //        let touch = touches.first!
    //        let location = touch.location(in: self)
    //        // self.stickMan.position = location
    //        let dist = hypot(stickMan.position, location)
    //        let duration = TimeInterval(dist * self.STICK_MAN_SPEED)
    //        print(duration)
    //        print(location)
    //        let moveAction = SKAction.move(to: location, duration: duration)
    //        moveAction.timingMode = .easeOut
    //        stickMan.run(moveAction)
    //
    //        //        for touch in touches {
    //        //            let location = touch.locationInNode(self)
    //        //
    //        //            let sprite = SKSpriteNode(imageNamed:"WalkingStickMan")
    //        //
    //        //            sprite.xScale = 0.1
    //        //            sprite.yScale = 0.1
    //        //            sprite.position = location
    //        //
    //        //            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
    //        //
    //        //            sprite.runAction(SKAction.repeatActionForever(action))
    //        //
    //        //            self.addChild(sprite)
    //        //        }
    //    }

    //    override func update(_: TimeInterval) {
    //        /* Called before each frame is rendered */
    //    }
}
