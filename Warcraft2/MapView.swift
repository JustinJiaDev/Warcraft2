import UIKit

class MapView: UIView {

    weak var viewportRenderer: ViewportRenderer?

    convenience init(frame: CGRect, viewportRenderer: ViewportRenderer) {
        self.init(frame: frame)
        self.viewportRenderer = viewportRenderer
    }

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
        guard let viewportRenderer = viewportRenderer else {
            return
        }
        do {
            let rectangle = Rectangle(xPosition: 0, yPosition: 0, width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight)
            let surface = GraphicFactory.createSurface(width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight, format: .a1)!
            let typeSurface = GraphicFactory.createSurface(width: viewportRenderer.lastViewportWidth, height: viewportRenderer.lastViewportHeight, format: .a1)!
            try viewportRenderer.drawViewport(on: surface, typeSurface: typeSurface, selectionMarkerList: [], selectRect: rectangle, currentCapability: .none)
            let context = UIGraphicsGetCurrentContext()!
            context.draw(surface as! CGLayer, in: rect)
            context.draw(typeSurface as! CGLayer, in: rect)
        } catch {
            print(error.localizedDescription) // TODO: Handle Error
        }
    }
}
