import Foundation
import CoreGraphics
import UIKit
import SpriteKit

protocol GraphicSurface {
    var width: Int { get }
    var height: Int { get }
    func clear()
    func draw(from texture: SKTexture, x: Int, y: Int, width: Int, height: Int)
}

extension SKScene: GraphicSurface {
    var width: Int {
        return Int(size.width)
    }

    var height: Int {
        return Int(size.height)
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
}
