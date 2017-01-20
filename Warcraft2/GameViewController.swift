//
//  GameViewController.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/10/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit

class GameViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var mainGameView: UIView!
    @IBOutlet weak var resourceBar: UIView!
    @IBOutlet weak var statsActionsView: UIView!
    @IBOutlet weak var gameSceneView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view.
            let skView: SKView = gameSceneView
            skView.showsFPS = true
            skView.showsNodeCount = true

            scene.parentViewController = self

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .fill

            skView.presentScene(scene)
        }

        self.view = mainGameView
    }

    func resizeMap(width: Int, height: Int) {
        print("resizeMap")
        print(width)
        print(height)
        gameSceneView.frame = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    }
}
