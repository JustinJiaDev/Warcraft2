import UIKit
import AudioToolbox

class LaunchViewController: UIViewController {
    override func viewDidLoad() {
        GameSound.current.play(.blacksmith)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
