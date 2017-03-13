import UIKit
import AudioToolbox

var mapIndex = 0
var aiLevel = 0

class LaunchViewController: UIViewController {

    @IBOutlet weak var aiButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!

    override func viewDidLoad() {
        GameSound.current.play(.blacksmith)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func buttonTapped(aiButton: UIButton) {
        if aiLevel == 0 {
            aiLevel = 1
            aiButton.setTitle("Simple AI", for: .normal)
        } else {
            aiLevel = 0
            aiButton.setTitle("No AI", for: .normal)
        }
    }

    @IBAction func buttonTapped(mapButton: UIButton) {
        if mapIndex == 0 {
            mapIndex = 1
            mapButton.setTitle("2 Player Divide Map", for: .normal)
        } else if mapIndex == 1 {
            mapIndex = 2
            mapButton.setTitle("Maze Map", for: .normal)
        } else if mapIndex == 2 {
            mapIndex = 0
            mapButton.setTitle("2 Player Map", for: .normal)
        }
    }
}
