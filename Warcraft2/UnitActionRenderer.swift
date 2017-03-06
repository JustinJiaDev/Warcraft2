import Foundation
import UIKit

class UnitActionRenderer: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    private let iconTileset: GraphicTileset
    private let playerData: PlayerData
    private let playerColor: PlayerColor
    private let bevel: Bevel
    private let fullIconWidth: Int
    private let fullIconHeight: Int
    private let commandIndices: [AssetCapabilityType: Int]
    private let disabledIndex: Int
    private var displayedCommands: [AssetCapabilityType]
    private var currentAction: AssetCapabilityType

    private static let capabilities: [AssetCapabilityType] = [
        .buildFarm,
        .buildTownHall,
        .buildBarracks,
        .buildLumberMill,
        .buildBlacksmith,
        .buildKeep,
        .buildCastle,
        .buildScoutTower,
        .buildGuardTower,
        .buildCannonTower
    ]

    init(bevel: Bevel, icons: GraphicTileset, color: PlayerColor, player: PlayerData) {
        self.iconTileset = icons
        self.playerData = player
        self.playerColor = color
        self.bevel = bevel
        self.fullIconWidth = iconTileset.tileWidth + bevel.width * 2
        self.fullIconHeight = iconTileset.tileHeight + bevel.width * 2
        self.commandIndices = [
            .none: -1,
            .buildPeasant: iconTileset.findTile("peasant"),
            .buildFootman: iconTileset.findTile("footman"),
            .buildArcher: iconTileset.findTile("archer"),
            .buildRanger: iconTileset.findTile("ranger"),
            .buildFarm: iconTileset.findTile("chicken-farm"),
            .buildTownHall: iconTileset.findTile("town-hall"),
            .buildBarracks: iconTileset.findTile("human-barracks"),
            .buildLumberMill: iconTileset.findTile("human-lumber-mill"),
            .buildBlacksmith: iconTileset.findTile("human-blacksmith"),
            .buildKeep: iconTileset.findTile("keep"),
            .buildCastle: iconTileset.findTile("castle"),
            .buildScoutTower: iconTileset.findTile("scout-tower"),
            .buildGuardTower: iconTileset.findTile("human-guard-tower"),
            .buildCannonTower: iconTileset.findTile("human-cannon-tower"),
            .move: iconTileset.findTile("human-move"),
            .repair: iconTileset.findTile("repair"),
            .mine: iconTileset.findTile("mine"),
            .buildSimple: iconTileset.findTile("build-simple"),
            .buildAdvanced: iconTileset.findTile("build-advanced"),
            .convey: iconTileset.findTile("human-convey"),
            .cancel: iconTileset.findTile("cancel"),
            .buildWall: iconTileset.findTile("human-wall"),
            .attack: iconTileset.findTile("human-weapon-1"),
            .standGround: iconTileset.findTile("human-armor-1"),
            .patrol: iconTileset.findTile("human-patrol"),
            .weaponUpgrade1: iconTileset.findTile("human-weapon-1"),
            .weaponUpgrade2: iconTileset.findTile("human-weapon-2"),
            .weaponUpgrade3: iconTileset.findTile("human-weapon-3"),
            .arrowUpgrade1: iconTileset.findTile("human-arrow-1"),
            .arrowUpgrade2: iconTileset.findTile("human-arrow-2"),
            .arrowUpgrade3: iconTileset.findTile("human-arrow-3"),
            .armorUpgrade1: iconTileset.findTile("human-armor-1"),
            .armorUpgrade2: iconTileset.findTile("human-armor-2"),
            .armorUpgrade3: iconTileset.findTile("human-armor-3"),
            .longbow: iconTileset.findTile("longbow"),
            .rangerScouting: iconTileset.findTile("ranger-scouting"),
            .marksmanship: iconTileset.findTile("marksmanship")
        ]
        self.disabledIndex = iconTileset.findTile("disabled")
        self.displayedCommands = []
        self.currentAction = .none
    }

    var minimumWidth: Int {
        return fullIconWidth * 3 + bevel.width * 2
    }

    var minimumHeight: Int {
        return fullIconHeight * 3 + bevel.width * 2
    }

    func drawUnitAction(on view: UICollectionView, selectionList: [PlayerAsset]) {
        guard !selectionList.isEmpty else {
            return
        }
        guard selectionList.first(where: { $0.color != playerColor }) == nil else {
            return
        }

        let firstAsset = selectionList[0]
        let isMoveable = firstAsset.speed > 0
        let hasCargo = selectionList.last!.lumber > 0 || selectionList.last!.gold > 0

        displayedCommands.removeAll()
        if [.none, .cancel].contains(currentAction) {
            if isMoveable {
                displayedCommands.append(hasCargo ? .convey : .move)
                displayedCommands.append(.standGround)
                displayedCommands.append(.attack)
                if firstAsset.hasCapability(.repair) {
                    displayedCommands.append(.repair)
                }
                if firstAsset.hasCapability(.patrol) {
                    displayedCommands.append(.patrol)
                }
                if firstAsset.hasCapability(.mine) {
                    displayedCommands.append(.mine)
                }
                if firstAsset.hasCapability(.buildSimple) && selectionList.count == 1 {
                    displayedCommands.append(.buildSimple)
                }
            } else if firstAsset.action == .construct || firstAsset.action == .capability {
                displayedCommands.append(.cancel)
            } else {
                displayedCommands = firstAsset.capabilities
            }
        } else if currentAction == .buildSimple {
            displayedCommands = UnitActionRenderer.capabilities.filter { capability in
                return firstAsset.hasCapability(capability)
            }
            displayedCommands.append(.cancel)
        } else {
            displayedCommands.append(.cancel)
        }

        view.dataSource = self
        view.delegate = self
        view.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionMenuViewCell", for: indexPath) as! ImageCell
        let capability = displayedCommands[indexPath.row]
        // bevel.drawBevel(on: surface, x: xOffset, y: yOffset, width: iconTileset.tileWidth, height: iconTileset.tileHeight)
        iconTileset.drawTile(on: cell.imageView, index: commandIndices[capability]!)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedCommands.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentAction = displayedCommands[indexPath.row]
        switch displayedCommands[indexPath.row] {
        case .mine:
            let capability = PlayerCapability.findCapability(.mine)
            let actor = playerData.playerMap.assets[1]
            let target = playerData.playerMap.assets[0]
            if capability.canApply(actor: actor, playerData: playerData, target: target) {
                capability.applyCapability(actor: actor, playerData: playerData, target: target)
            }
            collectionView.isHidden = true
        case .repair:
            let capability = PlayerCapability.findCapability(.mine)
            let actor = playerData.playerMap.assets[1]
            let target = playerData.createMarker(at: Position(x: 1 * 32, y: 3 * 32), addToMap: false)
            if capability.canApply(actor: actor, playerData: playerData, target: target) {
                capability.applyCapability(actor: actor, playerData: playerData, target: target)
            }
            collectionView.isHidden = true
        case .cancel:
            let capability = PlayerCapability.findCapability(.cancel)
            let actor = playerData.playerMap.assets[1]
            if capability.canApply(actor: actor, playerData: playerData, target: actor) {
                capability.applyCapability(actor: actor, playerData: playerData, target: actor)
            }
            collectionView.isHidden = true
        default:
            break
        }
    }
}
