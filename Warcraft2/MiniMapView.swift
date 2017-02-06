import UIKit

protocol MiniMapViewDelegate {
    func drawMiniMap(on surface: GraphicSurface)
}

class MiniMapView: UIView {

    weak var render: MapRenderer?

    convenience init(frame: CGRect, render: MapRenderer) {
        self.init(frame: frame)
        self.render = render
    }

    override func draw(_ rect: CGRect) {
        guard let render = render else {
            return
        }
        let context = UIGraphicsGetCurrentContext()!
        let layer = CGLayer(context, size: bounds.size, auxiliaryInfo: nil)!
        render.drawMiniMap(on: layer)
        context.draw(layer, in: rect)
    }
}
