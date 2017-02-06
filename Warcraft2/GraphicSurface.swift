import Foundation
import CoreGraphics
import UIKit

typealias GraphicSurfaceTransformCallback = (_ callData: UnsafeMutablePointer<UInt8>, _ source: UInt32) -> UInt32

enum GraphicSurfaceError: Error {
    case cannotCreateLayer
    case missingContext
    case missingSourceContext
}

enum GraphicSurfaceFormat {
    case argb32, rgb24, a8, a1
}

protocol GraphicSurface {

    var width: Int { get }
    var height: Int { get }
    var format: GraphicSurfaceFormat { get }
    var resourceContext: GraphicResourceContext { get }

    func duplicate() -> GraphicSurface

    func pixelColorAt(x: Int, y: Int) -> UInt32

    func clear(x: Int, y: Int, width: Int, height: Int) throws
    func draw(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) throws
    func copy(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) throws
    func copy(from surface: GraphicSurface, dx: Int, dy: Int, maskSurface: GraphicSurface, sx: Int, sy: Int) throws
    func transform(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int, callData: UnsafeMutablePointer<Any>, callback: GraphicSurfaceTransformCallback) throws
}

extension CGLayer: GraphicSurface {

    var width: Int {
        return Int(size.width)
    }

    var height: Int {
        return Int(size.height)
    }

    var format: GraphicSurfaceFormat {
        fatalError("This method is not yet implemented.")
    }

    var resourceContext: GraphicResourceContext {
        return context!
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
        let surface = surface as! CGLayer
        if sx == 0 && sy == 0 {
            context.draw(surface, in: CGRect(x: dx, y: dy, width: width, height: height))
        } else {
            let size = CGSize(width: width, height: height)
            UIGraphicsBeginImageContext(size)
            guard let newContext = UIGraphicsGetCurrentContext(), let layer = CGLayer(newContext, size: size, auxiliaryInfo: nil) else {
                throw GraphicSurfaceError.cannotCreateLayer
            }
            layer.context!.saveGState()
            layer.context!.translateBy(x: 0, y: size.height)
            layer.context!.scaleBy(x: 1, y: -1)
            layer.context!.draw(surface, at: CGPoint(x: -sx, y: -surface.height + 32 + sy))
            layer.context!.restoreGState()
            UIGraphicsEndImageContext()
            try draw(from: layer, dx: dx, dy: dy, width: width, height: height, sx: 0, sy: 0)
        }
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
