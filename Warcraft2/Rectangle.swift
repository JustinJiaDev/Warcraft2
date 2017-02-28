import CoreGraphics

typealias Rectangle = CGRect

extension CGRect {

    var x: Int {
        get {
            return Int(self.origin.x)
        }
        set {
            origin.x = CGFloat(newValue)
        }
    }

    var y: Int {
        get {
            return Int(self.origin.y)
        }
        set {
            origin.y = CGFloat(newValue)
        }
    }

    var width: Int {
        get {
            return Int(self.size.width)
        }
        set {
            size.width = CGFloat(newValue)
        }
    }

    var height: Int {
        get {
            return Int(self.size.height)
        }
        set {
            size.height = CGFloat(newValue)
        }
    }

    func contains(x: Int, y: Int) -> Bool {
        return contains(CGPoint(x: x, y: y))
    }

}
