class PixelType {

    enum AssetTerrainType: Int {
        case none = 0
        case grass
        case dirt
        case rock
        case tree
        case stump
        case water
        case wall
        case wallDamaged
        case rubble
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

    private(set) var type: AssetTerrainType
    private(set) var color: PlayerColor

    // FIXME: https://github.com/UCDClassNitta/ECS160Linux/issues/94
    var pixelColor: UInt32 {
        var colorCode = UInt32(color.index)
        colorCode <<= 16
        colorCode |= UInt32(type.rawValue) << 8
        return colorCode
    }

    var assetType: AssetType {
        switch type {
        case .peasant: return .peasant
        case .footman: return .footman
        case .archer: return .archer
        case .ranger: return .ranger
        case .goldMine: return .goldMine
        case .townHall: return .townHall
        case .keep: return .keep
        case .castle: return .castle
        case .farm: return .farm
        case .barracks: return .barracks
        case .lumberMill: return .lumberMill
        case .blacksmith: return .blacksmith
        case .scoutTower: return .scoutTower
        case .guardTower: return .guardTower
        case .cannonTower: return .cannonTower
        default: return .none
        }
    }

    // FIXME: https://github.com/UCDClassNitta/ECS160Linux/issues/94
    init(red: UInt32, green: UInt32, blue: UInt32) {
        color = PlayerColor(index: Int(red))!
        type = AssetTerrainType(rawValue: Int(green))!
    }

    init(tileType: TerrainMap.TileType) {
        color = .none
        switch tileType {
        case .grass: type = .grass
        case .dirt: type = .dirt
        case .rock: type = .rock
        case .tree: type = .tree
        case .stump: type = .stump
        case .water: type = .water
        case .wall: type = .wall
        case .wallDamaged: type = .wallDamaged
        case .rubble: type = .rubble
        case .none, .max: type = .none
        }
    }

    init(playerAsset: PlayerAsset) {
        color = playerAsset.color
        switch playerAsset.type {
        case .peasant: type = .peasant
        case .footman: type = .footman
        case .archer: type = .archer
        case .ranger: type = .ranger
        case .goldMine: type = .goldMine
        case .townHall: type = .townHall
        case .keep: type = .keep
        case .castle: type = .castle
        case .farm: type = .farm
        case .barracks: type = .barracks
        case .lumberMill: type = .lumberMill
        case .blacksmith: type = .blacksmith
        case .scoutTower: type = .scoutTower
        case .guardTower: type = .guardTower
        case .cannonTower: type = .cannonTower
        case .none, .max: type = .none
        }
    }

    init(pixelType: PixelType) {
        color = pixelType.color
        type = pixelType.type
    }

    static func of(surface: GraphicSurface, position: Position) -> PixelType {
        return of(surface: surface, x: position.x, y: position.y)
    }

    static func of(surface: GraphicSurface, x: Int, y: Int) -> PixelType {
        let pixelColor = surface.pixelColorAt(x: x, y: y)
        return PixelType(red: (pixelColor >> 16) & 0xff, green: (pixelColor >> 8) & 0xff, blue: (pixelColor & 0xff))
    }
}
