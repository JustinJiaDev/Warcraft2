import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var subview: View!
    @IBOutlet weak var elementsLabel: UILabel!
    @IBOutlet weak var currentFPSLabel: UILabel!
    @IBOutlet weak var averageFPSLabel: UILabel!

    var date = Date()
    var averageFPS = 0.0
    var currentFPS = 0.0
    var refreshCount = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        let displayLink = CADisplayLink(target: self, selector: #selector(run))
        displayLink.preferredFramesPerSecond = 100
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        elementsLabel.text = "Number of Elements: \(subview.elements.count)"
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func run() {
        currentFPS = 1.0 / -date.timeIntervalSinceNow
        averageFPS = (refreshCount * averageFPS + currentFPS) / (refreshCount + 1.0)
        refreshCount += 1.0
        currentFPSLabel.text = "Current FPS: \(currentFPS)"
        averageFPSLabel.text = "Average FPS: \(averageFPS)"
        date = Date()
        subview.setNeedsDisplay()
    }

}

