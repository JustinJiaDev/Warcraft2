import UIKit

class MiniMapView: UIView {

    weak var mapRender: MapRenderer?

    override func draw(_ rect: CGRect) {
        guard let mapRender = mapRender else {
            return
        }
        let context = UIGraphicsGetCurrentContext()!
        let layer = CGLayer(context, size: bounds.size, auxiliaryInfo: nil)!
        mapRender.drawMiniMap(on: layer)
        context.draw(layer, in: rect)
    }
}
