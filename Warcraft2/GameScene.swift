//
//  GameScene.swift
//  Warcraft2
//
//  Created by Bryce Korte on 1/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation //
//  GameScene.swift
//  iOS1
//
//  Created by Bryce Korte on 1/10/17.
//  Copyright (c) 2017 Bryce Korte. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let stickMan = SKSpriteNode(imageNamed: "SplashWithColor")
    let STICK_MAN_SPEED: CGFloat = 1 / 100

    override func didMove(to _: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        let texture: SKTexture = SKTexture(imageNamed: "Terrain.png")
        let textureRect = CGRect(x: 0, y: 0.5, width: 1, height: 0.01)
        let splitTexture = SKTexture(rect: textureRect, in: texture)
        // let spriteNode = SKSpriteNode(texture: texture)
        let spriteNode = SKSpriteNode(imageNamed: "TownHall.png")

        self.addChild(myLabel)

        // setup stick man
        spriteNode.xScale = 1
        spriteNode.yScale = 1
        spriteNode.position = CGPoint(x: 5, y: 5)
        self.addChild(spriteNode)
    }

    func hypot(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }

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

    override func update(_: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
