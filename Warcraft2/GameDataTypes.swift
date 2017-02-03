import Foundation

enum PlayerColor: Int {
    case none = 0
    case blue
    case red
    case green
    case purple
    case orange
    case yellow
    case black
    case white
    case max

    var index: Int {
        switch self {
        case .none: return 0
        case .blue: return 1
        case .red: return 2
        case .green: return 3
        case .purple: return 4
        case .orange: return 5
        case .yellow: return 6
        case .black: return 7
        case .white: return 8
        case .max: return 9
        }
    }
}

enum AssetAction: Int {
    case none = 0
    case construct
    case build
    case repair
    case walk
    case standGround
    case attack
    case harvestLumber
    case mineGold
    case conveyLumber
    case conveyGold
    case death
    case decay
    case capability
}

enum AssetCapabilityType: Int {
    case none = 0
    case buildPeasant
    case buildFootman
    case buildArcher
    case buildRanger
    case buildFarm
    case buildTownHall
    case buildBarracks
    case buildLumberMill
    case buildBlacksmith
    case buildKeep
    case buildCastle
    case buildScoutTower
    case buildGuardTower
    case buildCannonTower
    case move
    case repair
    case mine
    case buildSimple
    case buildAdvanced
    case convey
    case cancel
    case buildWall
    case attack
    case standGround
    case patrol
    case weaponUpgrade1
    case weaponUpgrade2
    case weaponUpgrade3
    case arrowUpgrade1
    case arrowUpgrade2
    case arrowUpgrade3
    case armorUpgrade1
    case armorUpgrade2
    case armorUpgrade3
    case longbow
    case rangerScouting
    case marksmanship
    case max
}

enum AssetType: Int {
    case none = 0
    case peasant
    case footman
    case archer
    case ranger
    case goldMine
    case townHall
    case keep
    case castle
    case farm
    case barracks
    case lumberMill
    case blacksmith
    case scoutTower
    case guardTower
    case cannonTower
    case max
}

enum Direction: Int {
    case north = 0
    case northEast = 45
    case east = 90
    case southEast = 135
    case south = 180
    case southWest = 225
    case west = 270
    case northWest = 315
    case max = 360

    var opposite: Direction {
        return Direction(rawValue: (rawValue + 180) % 360)!
    }

    static var numberOfDirections: Int {
        return 8
    }
}
