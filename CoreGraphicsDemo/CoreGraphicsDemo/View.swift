import UIKit

class View: UIView {

    var elements: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 1),
        (100, 0, 1),
        (200, 0, 1),
        (0, 100, 1),
        (100, 100, 1),
        (200, 100, 1),
        (0, 200, 1),
        (100, 200, 1),
        (200, 200, 1),
        (0, 300, 1),
        (100, 300, 1),
        (200, 300, 1),
        (0, 400, 1),
        (100, 400, 1),
        (200, 400, 1),
        (50, 50, 1),
        (150, 0, 1),
        (250, 0, 1),
        (50, 100, 1),
        (150, 100, 1),
        (250, 100, 1),
        (50, 200, 1),
        (150, 200, 1),
        (250, 200, 1),
        (50, 300, 1),
        (150, 300, 1),
        (250, 300, 1),
        (50, 400, 1),
        (150, 400, 1),
        (250, 400, 1),
    ]

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.clear(rect)
        context!.setFillColor(UIColor.white.cgColor)
        context!.fill(rect)

        for i in 0..<elements.count {
            let layer = createLayer()
            var (x, y, direction) = elements[i]
            if x > bounds.size.width - layer.size.width || y > bounds.size.height - layer.size.height { direction = -1 }
            if x < 0 || y < 0 { direction = 1 }
            x += direction * (CGFloat(i).truncatingRemainder(dividingBy: 5) + 1)
            y += direction * (CGFloat(i).truncatingRemainder(dividingBy: 5) + 1)
            context!.draw(layer, at: CGPoint(x: x, y: y))
            elements[i] = (x, y, direction)
        }
    }

}

func createLayer() -> CGLayer {
    let image = #imageLiteral(resourceName: "Circle")
    let size = image.size
    UIGraphicsBeginImageContext(size)
    let context = UIGraphicsGetCurrentContext()!
    let layer = CGLayer(context, size: size, auxiliaryInfo: nil)!
    layer.context!.draw(image.cgImage!, in: CGRect(origin: .zero, size: size))
    UIGraphicsEndImageContext()
    return layer
}
