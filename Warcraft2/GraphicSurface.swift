import Foundation
import CoreGraphics
import UIKit
import SpriteKit

typealias GraphicSurfaceTransformCallback = () -> UInt32

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

    func clear(x: Int, y: Int, width: Int, height: Int)
    func draw(from texture: SKTexture, x: Int, y: Int, width: Int, height: Int)
    func draw(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int)
    func copy(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int)
    func copy(from surface: GraphicSurface, dx: Int, dy: Int, maskSurface: GraphicSurface, sx: Int, sy: Int)
    func transform(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int, callData: Any, callback: GraphicSurfaceTransformCallback) throws
}

extension SKScene: GraphicSurface {

    var width: Int {
        return Int(size.width)
    }

    var height: Int {
        return Int(size.height)
    }

    var format: GraphicSurfaceFormat {
        return .a1
    }

    var resourceContext: GraphicResourceContext {
        fatalError("This method is not yet implemented.")
    }

    func duplicate() -> GraphicSurface {
        fatalError("This method is not yet implemented.")
    }

    func pixelColorAt(x: Int, y: Int) -> UInt32 {
        fatalError("This method is not yet implemented.")
    }

    // FIXME: MAKE CLEAR GREAT AGAIN
    func clear(x: Int, y: Int, width: Int, height: Int) {
        removeAllChildren()
    }

    func draw(from texture: SKTexture, x: Int, y: Int, width: Int, height: Int) {
        let node = SKSpriteNode(texture: texture, size: CGSize(width: width, height: height))
        node.position = CGPoint(x: x, y: self.height - y)
        node.anchorPoint = CGPoint(x: 0, y: 1)
        self.addChild(node)
    }

    func draw(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) {
        fatalError("This method is not yet implemented.")
    }

    func copy(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) {
        fatalError("This method is not yet implemented.")
    }

    func copy(from surface: GraphicSurface, dx: Int, dy: Int, maskSurface: GraphicSurface, sx: Int, sy: Int) {
        fatalError("This method is not yet implemented.")
    }

    func transform(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int, callData: Any, callback: GraphicSurfaceTransformCallback) throws {
        fatalError("This method is not yet implemented.")
    }
}

extension CGLayer: GraphicSurface {

    var width: Int {
        return Int(size.width)
    }

    var height: Int {
        return Int(size.height)
    }

    // FIXME: MAKE FORMAT GREAT AGAIN
    var format: GraphicSurfaceFormat {
        return .a1
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

    func clear(x: Int, y: Int, width: Int, height: Int) {
        context!.clear(CGRect(x: x, y: y, width: width, height: height))
    }

    func draw(from texture: SKTexture, x: Int, y: Int, width: Int, height: Int) {
        fatalError("This method is not yet implemented.")
    }

    func draw(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) {
        let surface = surface as! CGLayer
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        let newContext = UIGraphicsGetCurrentContext()!
        let layer = CGLayer(newContext, size: size, auxiliaryInfo: nil)!
        layer.context!.saveGState()
        layer.context!.translateBy(x: 0, y: size.height)
        layer.context!.scaleBy(x: 1, y: -1)
        layer.context!.draw(surface, at: CGPoint(x: -sx, y: -surface.height + height + sy))
        layer.context!.restoreGState()
        UIGraphicsEndImageContext()
        drawWithoutScale(from: layer, dx: dx, dy: dy, width: width, height: height, sx: 0, sy: 0)
    }

    // FIXME: MAKE COPY GREAT AGAIN
    func copy(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) {
        return
    }

    // FIXME: MAKE COPY GREAT AGAIN
    func copy(from surface: GraphicSurface, dx: Int, dy: Int, maskSurface: GraphicSurface, sx: Int, sy: Int) {
        return
    }

    func transform(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int, callData: Any, callback: GraphicSurfaceTransformCallback) throws {
        fatalError("This method is not yet implemented.")
    }

    private func drawWithoutScale(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) {
        context!.draw(surface as! CGLayer, in: CGRect(x: dx, y: dy, width: width, height: height))
    }
}
