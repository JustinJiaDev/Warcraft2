import UIKit
import AudioToolbox

fileprivate func url(_ pathComponents: String...) -> URL {
    return pathComponents.reduce(Bundle.main.url(forResource: "data", withExtension: nil)!, { result, pathComponent in
        return result.appendingPathComponent(pathComponent)
    })
}

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
