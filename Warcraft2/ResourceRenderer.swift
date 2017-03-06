import Foundation

enum MiniIconTypes: Int {
    case gold
    case lumber
    case food
}

func mitValue(mit: MiniIconTypes) -> Int {
    switch mit {
    case .gold: return 0
    case .lumber: return 1
    case .food: return 2
    }
}

class ResourceRenderer {
    private(set) var player: PlayerData
    private(set) var lastGoldDisplay: Int
    private(set) var lastLumberDisplay: Int

    init(loadedPlayer: PlayerData) {
        player = loadedPlayer
        lastGoldDisplay = 0
        lastLumberDisplay = 0
    }

    func updateGold() -> Int {
        var deltaGold = player.gold - lastGoldDisplay

        deltaGold /= 5
        if -3 < deltaGold && 3 > deltaGold {
            lastGoldDisplay = player.gold
        } else {
            lastGoldDisplay += deltaGold
        }
        return lastGoldDisplay
    }

    func updateLumber() -> Int {
        var deltaLumber = player.lumber - lastLumberDisplay

        deltaLumber /= 5
        if -3 < deltaLumber && 3 > deltaLumber {
            lastLumberDisplay = player.lumber
        } else {
            lastLumberDisplay += deltaLumber
        }
        return lastLumberDisplay
    }

    func updateFood() {
        if player.foodConsumption > player.foodProduction {
            // consumption/production
        } else {
            // print food consumption
        }
    }

    func drawResources() {
        fatalError("This is not yet implemented")
    }
}
