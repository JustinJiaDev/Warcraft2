import Foundation
import CoreGraphics
import UIKit
import SpriteKit

class GraphicFactory {
    static func createSurface(width: Int, height: Int, format: GraphicSurfaceFormat) -> GraphicSurface? {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let layer = CGLayer(context, size: size, auxiliaryInfo: nil)
        UIGraphicsEndImageContext()
        return layer
    }

    static func createSurface<T: SKScene>(width: Int, height: Int, type: T.Type) -> T {
        let scene = type.init(size: CGSize(width: width, height: height))
        scene.backgroundColor = UIColor.yellow
        return scene
    }

    static func loadSurface(from url: URL) -> GraphicSurface? {
        let image = UIImage(contentsOfFile: url.path)!
        UIGraphicsBeginImageContext(image.size)
        let layer = CGLayer(UIGraphicsGetCurrentContext()!, size: image.size, auxiliaryInfo: nil)!
        layer.context!.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        UIGraphicsEndImageContext()
        return layer
    }

    // For splitting a sprite sheet (input as UIImage) into numSprites different textures, returned as [SKTexture]
    static func splitVerticalSpriteSheet(from url: URL, numSprites: Int) -> [SKTexture] {
        let image = UIImage(contentsOfFile: url.path)!
        let segmentHeight: CGFloat = image.size.height / CGFloat(numSprites)
        var cropRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: segmentHeight)
        var imageSegments: [SKTexture] = []

        for i in 0 ..< numSprites {

            cropRect.origin.y = CGFloat(i) * segmentHeight

            let currentSegmentCGImage = image.cgImage!.cropping(to: cropRect)
            let currentSegmentUIImage = UIImage(cgImage: currentSegmentCGImage!)
            let currentSegmentSKTexture = SKTexture(image: currentSegmentUIImage)

            imageSegments.append(currentSegmentSKTexture)
        }

        return imageSegments
    }
}
