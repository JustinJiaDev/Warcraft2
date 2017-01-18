//
//  GameViewController.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/10/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet var mainGameView: UIView!
    @IBOutlet weak var resourceBar: UIView!
    @IBOutlet weak var statsActionsView: UIView!
    @IBOutlet weak var mapViewParent: UIView!
    @IBOutlet weak var mapView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = mainGameView
    }

    override func viewDidAppear(_: Bool) {
        mapView.frame = mapViewParent.bounds
        mapView.backgroundColor = UIColor.red
    }

    @IBAction func tapTest(_: Any) {
        print("Hello")
    }
}
