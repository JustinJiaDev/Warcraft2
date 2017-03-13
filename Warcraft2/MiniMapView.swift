import UIKit

class MiniMapView: UIView {

    weak var mapRenderer: MapRenderer?

    convenience init(frame: CGRect, mapRenderer: MapRenderer) {
        self.init(frame: frame)
        self.mapRenderer = mapRenderer
    }

    override func draw(_ rect: CGRect) {
        guard let mapRenderer = mapRenderer else {
            return
        }
        let context = UIGraphicsGetCurrentContext()!
        mapRenderer.drawMiniMap(on: context)
    }
}
