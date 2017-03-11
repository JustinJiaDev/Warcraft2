import Foundation
import UIKit

class ResourceRenderer {
    private(set) var player: PlayerData
    private(set) var foregroundColor: UIColor
    private(set) var backgroundColor: UIColor
    private(set) var insufficientColor: UIColor
    private(set) var lastGoldDisplay: Int
    private(set) var lastLumberDisplay: Int

    init(playerData: PlayerData) {
        player = playerData
        foregroundColor = UIColor.white
        backgroundColor = UIColor.black
        insufficientColor = UIColor.red
        lastGoldDisplay = 0
        lastLumberDisplay = 0
    }

    func draw(on view: ResourceBarView) {
        // animate gold update
        let deltaGold = (player.gold - lastGoldDisplay) / 5
        lastGoldDisplay = (-3 ... 3).contains(deltaGold) ? player.gold : lastGoldDisplay + deltaGold
        view.goldCount.text = String(lastGoldDisplay)

        // animate lumber update
        let deltaLumber = (player.lumber - lastLumberDisplay) / 5
        lastLumberDisplay = (-3 ... 3).contains(deltaLumber) ? player.lumber : lastLumberDisplay + deltaLumber
        view.lumberCount.text = String(lastLumberDisplay)

        // display food
        if player.foodConsumption > player.foodProduction {
            let foodInfo = NSMutableAttributedString(string: "\(player.foodConsumption) / \(player.foodProduction)")
            foodInfo.addAttribute(
                NSForegroundColorAttributeName,
                value: insufficientColor,
                range: NSRange(location: 0, length: String(player.foodConsumption).characters.count)
            )
            view.foodCount.attributedText = foodInfo
        } else {
            view.foodCount.text = "\(player.foodConsumption) / \(player.foodProduction)"
        }
    }
}
