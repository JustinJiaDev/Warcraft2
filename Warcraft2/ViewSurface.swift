import Foundation
import UIKit

protocol ViewSurface {
    func draw(from image: UIImage)
}

extension UIButton: ViewSurface {
    func draw(from image: UIImage) {
        setBackgroundImage(image, for: .normal)
    }
}

extension UIImageView: ViewSurface {
    func draw(from image: UIImage) {
        self.image = image
    }
}
