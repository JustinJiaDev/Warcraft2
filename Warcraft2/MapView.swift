import UIKit

class MapView: UIView {

    weak var mapRender: MapRenderer?

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self), let previousLocation = touches.first?.previousLocation(in: self) else {
            return
        }
        frame.origin.x += location.x - previousLocation.x
        frame.origin.y += location.y - previousLocation.y
        frame.origin.x = max(min(frame.origin.x, 0), -frame.size.width + UIScreen.main.bounds.width)
        frame.origin.y = max(min(frame.origin.y, 0), -frame.size.height + UIScreen.main.bounds.height)
    }

    override func draw(_ rect: CGRect) {
        do {
            guard let mapRender = mapRender else {
                return
            }
            let context = UIGraphicsGetCurrentContext()!
            let layer = CGLayer(context, size: bounds.size, auxiliaryInfo: nil)!
            try mapRender.drawMap(on: layer, typeSurface: layer, in: Rectangle(xPosition: 0, yPosition: 0, width: mapRender.detailedMapWidth, height: mapRender.detailedMapHeight), level: 0)
            context.draw(layer, in: rect)
        } catch {
            print(error.localizedDescription) // TODO: Handle Error
        }
    }
}
