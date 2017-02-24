import UIKit
import AudioToolbox

class LaunchViewController: UIViewController {

    var blacksmithSoundID: SystemSoundID = 0

    override func viewDidLoad() {
        let blacksmithSoundCFURL = url("snd", "buildings", "blacksmith.wav") as CFURL
        AudioServicesCreateSystemSoundID(blacksmithSoundCFURL, &blacksmithSoundID)
        AudioServicesPlaySystemSound(blacksmithSoundID)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
