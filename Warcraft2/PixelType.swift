import Foundation
import UIKit.UIColor

class PixelType {

    enum AssetTerrainType {
        case none
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

    var pixelColor: UInt32 {
        fatalError("This method is not yet implemented.")
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

    init(pixelColor: UIColor) {
        switch pixelColor {
        case pixelColor where pixelColor == UIColor.blue: color = .blue
        case pixelColor where pixelColor == UIColor.red: color = .red
        case pixelColor where pixelColor == UIColor.green: color = .green
        case pixelColor where pixelColor == UIColor.purple: color = .purple
        case pixelColor where pixelColor == UIColor.orange: color = .orange
        case pixelColor where pixelColor == UIColor.yellow: color = .yellow
        case pixelColor where pixelColor == UIColor.black: color = .black
        case pixelColor where pixelColor == UIColor.white: color = .white
        default: color = .none
        }
        type = .none
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
        fatalError("This method is not yet implemented.")
    }
}
