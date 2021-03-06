import CoreGraphics

typealias GraphicResourceContextLineCap = CGLineCap
typealias GraphicResourceContextLineJoin = CGLineJoin

protocol GraphicResourceContext {
    func setSourceRGB(_ rgb: UInt32)
    func setSourceRGB(r: Double, g: Double, b: Double)
    func setSourceRGBA(_ rgba: UInt32)
    func setSourceRGBA(r: Double, g: Double, b: Double, a: Double)
    func setLineWidth(_ width: Double)
    func setLineCap(_ cap: GraphicResourceContextLineCap)
    func setLineJoin(_ join: GraphicResourceContextLineJoin)
    func scale(x: Double, y: Double)
    func fill()
    func stroke()
    func rectangle(x: Int, y: Int, width: Int, height: Int)
    func moveTo(x: Int, y: Int)
    func lineTo(x: Int, y: Int)
    func clip()
    func save()
    func restore()
}

extension CGContext: GraphicResourceContext {

    func setSourceRGB(_ rgb: UInt32) {
        setSourceRGBA(0xff00_0000 | rgb)
    }

    func setSourceRGB(r: Double, g: Double, b: Double) {
        setSourceRGBA(r: r, g: g, b: b, a: 1)
    }

    func setSourceRGBA(_ rgba: UInt32) {
        let r = Double(rgba >> 16 & 0xff) / 255.0
        let g = Double(rgba >> 8 & 0xff) / 255.0
        let b = Double(rgba & 0xff) / 255.0
        let a = Double(rgba >> 24 & 0xff) / 255.0
        setSourceRGBA(r: r, g: g, b: b, a: a)
    }

    func setSourceRGBA(r: Double, g: Double, b: Double, a: Double) {
        setStrokeColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
        setFillColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }

    func setLineWidth(_ width: Double) {
        setLineWidth(CGFloat(width))
    }

    func scale(x: Double, y: Double) {
        scaleBy(x: CGFloat(x), y: CGFloat(y))
    }

    func fill() {
        fillPath()
    }

    func stroke() {
        strokePath()
    }

    func rectangle(x: Int, y: Int, width: Int, height: Int) {
        addRect(CGRect(x: x, y: y, width: width, height: height))
    }

    func moveTo(x: Int, y: Int) {
        move(to: CGPoint(x: x, y: y))
    }

    func lineTo(x: Int, y: Int) {
        addLine(to: CGPoint(x: x, y: y))
    }

    func clip() {
        clip(using: .winding)
    }

    func save() {
        saveGState()
    }

    func restore() {
        restoreGState()
    }
}
