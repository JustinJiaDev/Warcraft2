enum PlayerColor {
    case none
    case blue
    case red
    case green
    case purple
    case orange
    case yellow
    case black
    case white

    var pixelColor: UInt32 {
        switch self {
        case .none: return 0x808080
        case .blue: return 0x0000ff
        case .red: return 0xff0000
        case .green: return 0x008000
        case .purple: return 0x800080
        case .orange: return 0x808000
        case .yellow: return 0xffff00
        case .black: return 0x000000
        case .white: return 0xffffff
        }
    }

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
        }
    }

    init(pixelColor: UInt32) {
        switch pixelColor {
        case 0x0000ff: self = .blue
        case 0xff0000: self = .red
        case 0x008000: self = .green
        case 0x800080: self = .purple
        case 0x808000: self = .orange
        case 0xffff00: self = .yellow
        case 0x000000: self = .black
        case 0xffffff: self = .white
        default: self = .none
        }
    }

    init?(index: Int) {
        switch index {
        case 0: self = .none
        case 1: self = .blue
        case 2: self = .red
        case 3: self = .green
        case 4: self = .purple
        case 5: self = .orange
        case 6: self = .yellow
        case 7: self = .black
        case 8: self = .white
        default: return nil
        }
    }

    static var allValues: [PlayerColor] = [.none, .blue, .red, .green, .purple, .orange, .yellow, .white]
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

    static var allValues: [AssetCapabilityType] = [
        .none,
        .buildPeasant,
        .buildFootman,
        .buildArcher,
        .buildRanger,
        .buildFarm,
        .buildTownHall,
        .buildBarracks,
        .buildLumberMill,
        .buildBlacksmith,
        .buildKeep,
        .buildCastle,
        .buildScoutTower,
        .buildGuardTower,
        .buildCannonTower,
        .move,
        .repair,
        .mine,
        .buildSimple,
        .buildAdvanced,
        .convey,
        .cancel,
        .buildWall,
        .attack,
        .standGround,
        .patrol,
        .weaponUpgrade1,
        .weaponUpgrade2,
        .weaponUpgrade3,
        .arrowUpgrade1,
        .arrowUpgrade2,
        .arrowUpgrade3,
        .armorUpgrade1,
        .armorUpgrade2,
        .armorUpgrade3,
        .longbow,
        .rangerScouting,
        .marksmanship
    ]

    var needsTarget: Bool {
        switch self {
        case .buildPeasant,
             .buildFootman,
             .buildArcher,
             .buildRanger,
             .standGround,
             .weaponUpgrade1,
             .weaponUpgrade2,
             .weaponUpgrade3,
             .arrowUpgrade1,
             .arrowUpgrade2,
             .arrowUpgrade3,
             .armorUpgrade1,
             .armorUpgrade2,
             .armorUpgrade3,
             .cancel: return false
        default: return true
        }
    }

    var needsMarker: Bool {
        switch self {
        case .move, .mine: return true
        default: return false
        }
    }
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

enum Direction {
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest
    case max

    static var numberOfDirections: Int {
        return 8
    }

    var opposite: Direction {
        return Direction(angle: angle + 180)!
    }

    var angle: Int {
        switch self {
        case .north: return 0
        case .northEast: return 45
        case .east: return 90
        case .southEast: return 135
        case .south: return 180
        case .southWest: return 225
        case .west: return 270
        case .northWest: return 315
        case .max: return 360
        }
    }

    var index: Int {
        switch self {
        case .north: return 0
        case .northEast: return 1
        case .east: return 2
        case .southEast: return 3
        case .south: return 4
        case .southWest: return 5
        case .west: return 6
        case .northWest: return 7
        case .max: return 8
        }
    }

    init?(angle: Int) {
        let angle = angle % 360
        switch angle {
        case 0: self = .north
        case 45: self = .northEast
        case 90: self = .east
        case 135: self = .southEast
        case 180: self = .south
        case 225: self = .southWest
        case 270: self = .west
        case 315: self = .northWest
        default: return nil
        }
    }

    init?(index: Int) {
        switch index {
        case 0: self = .north
        case 1: self = .northEast
        case 2: self = .east
        case 3: self = .southEast
        case 4: self = .south
        case 5: self = .southWest
        case 6: self = .west
        case 7: self = .northWest
        case 8: self = .max
        default: return nil
        }
    }
}
