import Foundation

typealias GraphicSurfaceTransformCallback = (_ callData: UnsafeMutablePointer<UInt8>, _ source: UInt32) -> UInt32

class GraphicSurface {

    enum SurfaceFormat {
        case argb32, rgb24, a8, a1
    }

    func width() -> Int {
        fatalError("You need to override this method.")
    }

    func height() -> Int {
        fatalError("You need to override this method.")
    }

    func format() -> SurfaceFormat {
        fatalError("You need to override this method.")
    }

    func pixelAt(xPosition: Int, yPosition: Int) -> UInt32 {
        fatalError("You need to override this method.")
    }

    func clear(xPosition _: Int = 0, yPosition _: Int = 0, width _: Int = -1, height _: Int = -1) {
        fatalError("You need to override this method.")
    }

    func duplicate() -> GraphicSurface {
        fatalError("You need to override this method.")
    }

    func createResourceContext() -> GraphicResourceContext {
        fatalError("You need to override this method.")
    }

    func draw(surface _: GraphicSurface, dxPosition _: Int, dyPosition _: Int, width _: Int, height _: Int, sxPosition _: Int, syPosition _: Int) {
        fatalError("You need to override this method.")
    }

    func copy(surface _: GraphicSurface, dxPosition _: Int, dyPosition _: Int, width _: Int, height _: Int, sxPosition _: Int, syPosition _: Int) {
        fatalError("You need to override this method.")
    }

    func copyMaskSurface(surface _: GraphicSurface, dxPosition _: Int, dyPosition _: Int, maskSurface _: GraphicSurface, sxPosition _: Int, syPosition _: Int) {
        fatalError("You need to override this method.")
    }

    func transform(surface _: GraphicSurface, dxPosition _: Int, dyPosition _: Int, width _: Int, height _: Int, sxPosition _: Int, syPosition _: Int, callData _: UnsafeMutablePointer<Any>, callback _: GraphicSurfaceTransformCallback) {
        fatalError("You need to override this method.")
    }
}
