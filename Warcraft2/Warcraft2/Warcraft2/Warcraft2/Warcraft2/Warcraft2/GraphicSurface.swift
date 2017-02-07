import Foundation
import CoreGraphics

typealias GraphicSurfaceTransformCallback = (_ callData: UnsafeMutablePointer<UInt8>, _ source: UInt32) -> UInt32

enum GraphicSurfaceError: Error {

    case missingContext
    case missingSourceContext
}

enum GraphicSurfaceFormat {
    case argb32, rgb24, a8, a1
}

protocol GraphicSurface {

    var layer: CGLayer { get }
    var width: Int { get }
    var height: Int { get }
    var format: GraphicSurfaceFormat { get }

    func duplicate() -> GraphicSurface
    func createResourceContext() -> GraphicResourceContext

    func pixelColorAt(x: Int, y: Int) -> UInt32

    func clear(x: Int, y: Int, width: Int, height: Int) throws
    func draw(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) throws
    func copy(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) throws
    func copy(from surface: GraphicSurface, dx: Int, dy: Int, maskSurface: GraphicSurface, sx: Int, sy: Int) throws
    func transform(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int, callData: UnsafeMutablePointer<Any>, callback: GraphicSurfaceTransformCallback) throws
}

extension CGLayer: GraphicSurface {

    var layer: CGLayer {
        return self
    }

    var width: Int {
        return Int(size.width)
    }

    var height: Int {
        return Int(size.height)
    }

    var format: GraphicSurfaceFormat {
        fatalError("This method is not yet implemented.")
    }

    func createResourceContext() -> GraphicResourceContext {
        fatalError("This method is not yet implemented.")
    }

    func duplicate() -> GraphicSurface {
        fatalError("This method is not yet implemented.")
    }

    func pixelColorAt(x: Int, y: Int) -> UInt32 {
        fatalError("This method is not yet implemented.")
    }

    func clear(x: Int, y: Int, width: Int, height: Int) throws {
        guard let context = context else {
            throw GraphicSurfaceError.missingContext
        }
        context.clear(CGRect(x: x, y: y, width: width, height: height))
    }

    func draw(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) throws {
        guard let context = context else {
            throw GraphicSurfaceError.missingContext
        }
        guard let sourceContext = surface.layer.context else {
            throw GraphicSurfaceError.missingSourceContext
        }
        sourceContext.clip(to: CGRect(x: sx, y: sy, width: width, height: height))
        context.draw(surface.layer, in: CGRect(x: dx, y: dy, width: width, height: height))
    }

    func copy(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) throws {
        fatalError("This method is not yet implemented.")
    }

    func copy(from surface: GraphicSurface, dx: Int, dy: Int, maskSurface: GraphicSurface, sx: Int, sy: Int) throws {
        fatalError("This method is not yet implemented.")
    }

    func transform(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int, callData: UnsafeMutablePointer<Any>, callback: GraphicSurfaceTransformCallback) throws {
        fatalError("This method is not yet implemented.")
    }
}
