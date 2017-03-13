import Foundation
import CoreGraphics
import UIKit
import SpriteKit

protocol GraphicSurface {
    var width: Int { get }
    var height: Int { get }
    var resourceContext: GraphicResourceContext { get }

    func clear()
    func draw(from texture: SKTexture, x: Int, y: Int, width: Int, height: Int)
    func draw(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int)
}

extension SKScene: GraphicSurface {

    var width: Int {
        return Int(size.width)
    }

    var height: Int {
        return Int(size.height)
    }

    var resourceContext: GraphicResourceContext {
        fatalError("This method is not yet implemented.")
    }

    func clear() {
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
}

extension CGLayer: GraphicSurface {

    var width: Int {
        return Int(size.width)
    }

    var height: Int {
        return Int(size.height)
    }

    var resourceContext: GraphicResourceContext {
        return context!
    }

    func clear(x: Int, y: Int, width: Int, height: Int) {
        context!.clear(CGRect(x: x, y: y, width: width, height: height))
    }

    func clear() {
        fatalError("This method is not yet implemented.")
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

    private func drawWithoutScale(from surface: GraphicSurface, dx: Int, dy: Int, width: Int, height: Int, sx: Int, sy: Int) {
        context!.draw(surface as! CGLayer, in: CGRect(x: dx, y: dy, width: width, height: height))
    }
}
