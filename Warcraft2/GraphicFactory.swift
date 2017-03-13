import SpriteKit
import UIKit

class GraphicFactory {

    static func createSurface(width: Int, height: Int) -> GraphicSurface {
        return SKScene(size: CGSize(width: width, height: height))
    }

    static func loadImage(from url: URL) -> UIImage? {
        return UIImage(contentsOfFile: url.path)
    }

    static func loadImages(from url: URL, count: Int) -> [UIImage]? {
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        let imageHeight = image.size.height / CGFloat(count)
        var currentRect = CGRect(x: 0, y: 0, width: image.size.width, height: imageHeight)
        var images: [UIImage] = []
        for i in 0 ..< count {
            currentRect.origin.y = CGFloat(i) * imageHeight
            let currentCGImage = image.cgImage!.cropping(to: currentRect)!
            images.append(UIImage(cgImage: currentCGImage))
        }
        return images
    }

    static func loadTextures(from url: URL, count: Int) -> [SKTexture]? {
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        return loadTextures(from: image, count: count)
    }

    static func loadTextures(from image: UIImage, count: Int) -> [SKTexture] {
        let textureHeight = image.size.height / CGFloat(count)
        var currentRect = CGRect(x: 0, y: 0, width: image.size.width, height: textureHeight)
        var textures: [SKTexture] = []
        for i in 0 ..< count {
            currentRect.origin.y = CGFloat(i) * textureHeight
            let currentCGImage = image.cgImage!.cropping(to: currentRect)!
            textures.append(SKTexture(cgImage: currentCGImage))
        }
        return textures
    }
}
