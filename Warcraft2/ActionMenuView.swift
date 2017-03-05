import UIKit

class ActionMenuView: UIView {
    //    weak var unitActionRenderer: UnitActionRenderer?
    //    var playerAsset: [PlayerAsset]
    //    var currentAction: AssetCapabilityType

    convenience init(frame: CGRect, unitActionRenderer: Int) {
        self.init(frame: frame)
        //        self.unitActionRenderer = unitActionRenderer
    }

    //    override func draw(_ rect: CGRect) {
    //        guard let unitActionRenderer = unitActionRenderer else {
    //            return
    //        }
    //        let context = UIGraphicsGetCurrentContext()!
    //        let layer = CGLayer(context, size: bounds.size, auxiliaryInfo: nil)!
    //        try unitActionRenderer.drawUnitAction(on: layer, selectionList: playerAsset, currentAction: currentAction)
    //        context.draw(layer, in: rect)
    //    }
}
