//
//  LaunchViewController.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/10/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import UIKit
import AudioToolbox

class LaunchViewController: UIViewController {

    let blacksmithSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "blacksmith", ofType: "wav")!)
    var blacksmithSoundID: SystemSoundID = 0

    override func viewDidLoad() {

        if let blacksmithSoundCFURL: CFURL = blacksmithSoundURL as CFURL? {
            AudioServicesCreateSystemSoundID(blacksmithSoundCFURL, &blacksmithSoundID)
            AudioServicesPlaySystemSound(blacksmithSoundID)
        } else {
            assert(false)
        }
    }
}
