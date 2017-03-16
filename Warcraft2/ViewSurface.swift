import UIKit

protocol ViewSurface {
    func draw(from image: UIImage)
}

extension UIImageView: ViewSurface {
    func draw(from image: UIImage) {
        self.image = image
    }
}
