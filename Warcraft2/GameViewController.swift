import UIKit
import SpriteKit
import SceneKit
import AVFoundation

class GameViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var mainGameView: UIView!
    @IBOutlet weak var resourceBar: UIView!
    @IBOutlet weak var statsActionsView: UIView!
    @IBOutlet weak var gameSceneView: SKView!

    var midiplayer: AVMIDIPlayer?
    var soundfont: URL?
    var midifile: URL?

    let menuSoundURL = URL(fileURLWithPath: (Bundle.main.path(forResource: "data/snd/music/menu", ofType: "mid"))!)
    let menuSoundBankURL = Bundle.main.url(forResource: "data/snd/generalsoundfont", withExtension: "sf2")
    var menuSound = AVMIDIPlayer()

    // var soundbank: URL!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view.
            let skView: SKView = gameSceneView
            skView.showsFPS = true
            skView.showsNodeCount = true

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .fill

            skView.presentScene(scene)
        }
        self.view = mainGameView

        playMIDIFile()
    }

    func playMIDIFile() {

        do {
            try menuSound = AVMIDIPlayer(contentsOf: menuSoundURL, soundBankURL: menuSoundBankURL)
        } catch {
            NSLog("Error: Can't play sound file menu.mid")
        }

        menuSound.prepareToPlay()
        menuSound.play()
    }
}
