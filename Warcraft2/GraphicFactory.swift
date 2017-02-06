import Foundation
import CoreGraphics

// FIXME: MAKE IMAGE GREAT AGAIN
// HACK - START
import UIKit
// HACK - END

class GraphicFactory {
    static func createSurface(width: Int, height: Int, format: GraphicSurfaceFormat) -> GraphicSurface? {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let layer = CGLayer(context, size: size, auxiliaryInfo: nil)
        UIGraphicsEndImageContext()
        return layer
    }

    static func loadSurface(dataSource: DataSource) -> GraphicSurface? {
        fatalError("This method is not yet implemented.")
    }

    // FIXME: MAKE TILESET GREAT AGAIN
    // HACK - START
    static func loadPNGTilesetSurface(name: String) -> GraphicSurface {
        let name = String(name.characters.dropFirst(2))
        let image = UIImage(named: name)!
        UIGraphicsBeginImageContext(image.size)
        let layer = CGLayer(UIGraphicsGetCurrentContext()!, size: image.size, auxiliaryInfo: nil)!
        layer.context!.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        UIGraphicsEndImageContext()
        return layer
    }
    // HACK - END
}
