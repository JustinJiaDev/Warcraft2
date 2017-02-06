import UIKit

class AssetView: UIView {

    weak var renderer: AssetRenderer?

    convenience init(frame: CGRect, renderer: AssetRenderer) {
        self.init(frame: frame)
        self.renderer = renderer
    }

    override func draw(_ rect: CGRect) {
        guard let renderer = renderer else {
            return
        }
        let context = UIGraphicsGetCurrentContext()!
        let layer = CGLayer(context, size: bounds.size, auxiliaryInfo: nil)!
        renderer.drawMiniAssets(on: layer)
        // try renderer.drawAssets(on: layer, typeSurface: layer, in: Rectangle(xPosition: 0, yPosition: 0, width: Int(rect.width), height: Int(rect.height)))
        context.draw(layer, in: rect)
    }
}
