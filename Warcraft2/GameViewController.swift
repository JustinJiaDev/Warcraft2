import UIKit
import SpriteKit
import SceneKit
import AVFoundation

class GameViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var mainGameView: UIView!
    @IBOutlet weak var resourceBar: UIView!
    @IBOutlet weak var statsActionsView: UIView!
    @IBOutlet weak var gameSceneView: SKView!

    var soundbank: URL!
    var mp: AVMIDIPlayer!

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

        // Load a SoundFont or DLS file.
        self.soundbank = Bundle.main.url(forResource: "generalsoundfont", withExtension: "sf2")

        // a standard MIDI file.
        let contents: URL = Bundle.main.url(forResource: "intro", withExtension: "mid")!

        do {
            try self.mp = AVMIDIPlayer(contentsOf: contents, soundBankURL: soundbank)
        } catch {
        }

        if self.mp == nil {
            print("nil midi player")
        }

        self.mp.prepareToPlay()

        self.mp.play(nil)

        // there is a crash when you use a completion
        // self.mp.play({
        //    println("midi done")
        // })

        // or
        //        var completion:AVMIDIPlayerCompletionHandler = {println("done")}
        //        mp.play(completion)
    }
}
