import Foundation

class GraphicResourceContext {

    enum LineCap {
        case butt, round, square
    }

    enum LineJoin {
        case miter, round, bevel
    }

    func setSourceRGB(_: UInt32) {
        fatalError("You need to override this method.")
    }

    func setSourceRGB(r _: Double, g _: Double, b _: Double) {
        fatalError("You need to override this method.")
    }

    func setSourceRGBA(_: UInt32) {
        fatalError("You need to override this method.")
    }

    func setSourceRGBA(r _: Double, g _: Double, b _: Double) {
        fatalError("You need to override this method.")
    }

    func setSourceSurface(_ surface: GraphicSurface, xPosition _: Int, yPosition _: Int) {
        fatalError("You need to override this method.")
    }

    func setLineWidth(_: Double) {
        fatalError("You need to override this method.")
    }

    func setLineCap(_: LineCap) {
        fatalError("You need to override this method.")
    }

    func setLineJoin(_: LineJoin) {
        fatalError("You need to override this method.")
    }

    func scale(x _: Double, y _: Double) {
        fatalError("You need to override this method.")
    }

    func paint() {
        fatalError("You need to override this method.")
    }

    func paint(with _: Double) {
        fatalError("You need to override this method.")
    }

    func fill() {
        fatalError("You need to override this method.")
    }

    func stroke() {
        fatalError("You need to override this method.")
    }

    func rectangle(xPosition _: Int, yPosition _: Int, width _: Int, height _: Int) {
        fatalError("You need to override this method.")
    }

    func moveTo(xPosition _: Int, yPosition _: Int) {
        fatalError("You need to override this method.")
    }

    func lineTo(xPosition _: Int, yPosition _: Int) {
        fatalError("You need to override this method.")
    }

    func clip() {
        fatalError("You need to override this method.")
    }

    func maskSurface(surface _: GraphicSurface, xPosition _: Int, yPosition _: Int) {
        fatalError("You need to override this method.")
    }

    func getTarget() -> GraphicSurface {
        fatalError("You need to override this method.")
    }

    func save() {
        fatalError("You need to override this method.")
    }

    func restore() {
        fatalError("You need to override this method.")
    }

    func drawSurface(surface _: GraphicSurface, dxPosition _: Int, dyPosition _: Int, width _: Int, height _: Int, sxPosition _: Int, syPosition _: Int) {
        fatalError("You need to override this method.")
    }

    func copySurface(surface _: GraphicSurface, dxPosition _: Int, dyPosition _: Int, width _: Int, height _: Int, sxPosition _: Int, syPosition _: Int) {
        fatalError("You need to override this method.")
    }
}
