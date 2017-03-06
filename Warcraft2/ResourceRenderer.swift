import Foundation
import UIKit

enum MiniIconTypes: Int {
    case mitGold
    case mitLumber
    case mitFood
    case mitMax
}

func mitValue(mit: MiniIconTypes) -> Int {
    switch mit {
    case .mitGold:
        return 0
    case .mitLumber:
        return 1
    case .mitFood:
        return 2
    case .mitMax:
        return 3
    default:
        return -1
    }
}

class ResourceRenderer {
    private(set) var player: PlayerData
    private(set) var foregroundColor: UIColor
    private(set) var backgroundColor: UIColor
    private(set) var insufficientColor: UIColor
    private(set) var lastGoldDisplay: Int
    private(set) var lastLumberDisplay: Int
    private(set) var resourceBar: ResourceBarView

    init(loadedPlayer: PlayerData, resourceBarView: ResourceBarView) {
        player = loadedPlayer
        foregroundColor = UIColor.white
        backgroundColor = UIColor.black
        insufficientColor = UIColor.red
        lastGoldDisplay = 0
        lastLumberDisplay = 0
        resourceBar = resourceBarView
    }

    func drawResources() {
        // animate gold update
        var deltaGold = player.gold - lastGoldDisplay
        deltaGold /= 5
        if -3 < deltaGold && 3 > deltaGold {
            lastGoldDisplay = player.gold
        } else {
            lastGoldDisplay += deltaGold
        }
        resourceBar.goldCount.text = String(lastGoldDisplay)

        // update lumber
        var deltaLumber = player.lumber - lastLumberDisplay
        deltaLumber /= 5
        if -3 < deltaLumber && 3 > deltaLumber {
            lastLumberDisplay = player.lumber
        } else {
            lastLumberDisplay += deltaLumber
        }
        resourceBar.lumberCount.text = String(lastLumberDisplay)

        // update food
        if player.foodConsumption > player.foodProduction {
            let foodInfo = NSMutableAttributedString(string: String(player.foodConsumption) + " / " + String(player.foodProduction))
            let foodConsumptionStringLength = String(player.foodConsumption).characters.count
            foodInfo.addAttribute(NSForegroundColorAttributeName, value: insufficientColor, range: NSRange(location: 0, length: foodConsumptionStringLength))
            resourceBar.foodCount.attributedText = foodInfo
        } else {
            resourceBar.foodCount.text = String(player.foodConsumption) + " / " + String(player.foodProduction)
        }
    }
}
