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
            fatalError()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
