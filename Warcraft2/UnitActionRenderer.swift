import Foundation

class UnitActionRenderer {
    private var iconTileset: GraphicTileset
    private var playerData: PlayerData
    private var playerColor: PlayerColor
    private var bevel: Bevel
    private var fullIconWidth: Int
    private var fullIconHeight: Int
    private var displayedCommands: [AssetCapabilityType]
    private var commandIndices: [AssetCapabilityType: Int]
    private var disabledIndex: Int

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

        fullIconWidth = iconTileset.tileWidth + bevel.width * 2
        fullIconHeight = iconTileset.tileHeight + bevel.width * 2
        displayedCommands = Array(repeating: .none, count: 9)

        commandIndices = [:]
        commandIndices[.none] = -1
        commandIndices[.buildPeasant] = iconTileset.findTile(with: "peasant")
        commandIndices[.buildFootman] = iconTileset.findTile(with: "footman")
        commandIndices[.buildArcher] = iconTileset.findTile(with: "archer")
        commandIndices[.buildRanger] = iconTileset.findTile(with: "ranger")
        commandIndices[.buildFarm] = iconTileset.findTile(with: "chicken-farm")
        commandIndices[.buildTownHall] = iconTileset.findTile(with: "town-hall")
        commandIndices[.buildBarracks] = iconTileset.findTile(with: "human-barracks")
        commandIndices[.buildLumberMill] = iconTileset.findTile(with: "human-lumber-mill")
        commandIndices[.buildBlacksmith] = iconTileset.findTile(with: "human-blacksmith")
        commandIndices[.buildKeep] = iconTileset.findTile(with: "keep")
        commandIndices[.buildCastle] = iconTileset.findTile(with: "castle")
        commandIndices[.buildScoutTower] = iconTileset.findTile(with: "scout-tower")
        commandIndices[.buildGuardTower] = iconTileset.findTile(with: "human-guard-tower")
        commandIndices[.buildCannonTower] = iconTileset.findTile(with: "human-cannon-tower")
        commandIndices[.move] = iconTileset.findTile(with: "human-move")
        commandIndices[.repair] = iconTileset.findTile(with: "repair")
        commandIndices[.mine] = iconTileset.findTile(with: "mine")
        commandIndices[.buildSimple] = iconTileset.findTile(with: "build-simple")
        commandIndices[.buildAdvanced] = iconTileset.findTile(with: "build-advanced")
        commandIndices[.convey] = iconTileset.findTile(with: "human-convey")
        commandIndices[.cancel] = iconTileset.findTile(with: "cancel")
        commandIndices[.buildWall] = iconTileset.findTile(with: "human-wall")
        commandIndices[.attack] = iconTileset.findTile(with: "human-weapon-1")
        commandIndices[.standGround] = iconTileset.findTile(with: "human-armor-1")
        commandIndices[.patrol] = iconTileset.findTile(with: "human-patrol")
        commandIndices[.weaponUpgrade1] = iconTileset.findTile(with: "human-weapon-1")
        commandIndices[.weaponUpgrade2] = iconTileset.findTile(with: "human-weapon-2")
        commandIndices[.weaponUpgrade3] = iconTileset.findTile(with: "human-weapon-3")
        commandIndices[.arrowUpgrade1] = iconTileset.findTile(with: "human-arrow-1")
        commandIndices[.arrowUpgrade2] = iconTileset.findTile(with: "human-arrow-2")
        commandIndices[.arrowUpgrade3] = iconTileset.findTile(with: "human-arrow-3")
        commandIndices[.armorUpgrade1] = iconTileset.findTile(with: "human-armor-1")
        commandIndices[.armorUpgrade2] = iconTileset.findTile(with: "human-armor-2")
        commandIndices[.armorUpgrade3] = iconTileset.findTile(with: "human-armor-3")
        commandIndices[.longbow] = iconTileset.findTile(with: "longbow")
        commandIndices[.rangerScouting] = iconTileset.findTile(with: "ranger-scouting")
        commandIndices[.marksmanship] = iconTileset.findTile(with: "marksmanship")

        disabledIndex = iconTileset.findTile(with: "disabled")
    }

    var minimumWidth: Int {
        return fullIconWidth * 3 + bevel.width * 2
    }

    var minimumHeight: Int {
        return fullIconHeight * 3 + bevel.width * 2
    }

    func selection(at position: Position) -> AssetCapabilityType {
        if (position.x % (fullIconWidth + bevel.width)) < fullIconWidth && (position.y % (fullIconWidth + bevel.width)) < fullIconHeight {
            let index = position.x / (fullIconWidth + bevel.width) + position.y / (fullIconHeight + bevel.width) * 3
            return displayedCommands[index]
        }
        return .none
    }

    // FIXME: GitHub Issue https://github.com/UCDClassNitta/ECS160Linux/issues/105
    func drawUnitAction(on surface: GraphicSurface, selectionList: [PlayerAsset], currentAction: AssetCapabilityType) throws {
        guard !selectionList.isEmpty else {
            return
        }
        guard selectionList.first(where: { $0.color != playerColor }) == nil else {
            return
        }

        let firstAsset = selectionList[0]
        let isMoveable = firstAsset.speed > 0
        let hasCargo = selectionList.last!.lumber > 0 || selectionList.last!.gold > 0

        displayedCommands = Array(repeating: .none, count: 9)
        if currentAction == .none {
            if isMoveable {
                displayedCommands[0] = hasCargo ? .convey : .move
                displayedCommands[1] = .standGround
                displayedCommands[2] = .attack
                displayedCommands[3] = firstAsset.hasCapability(.repair) ? .repair : .none
                displayedCommands[3] = firstAsset.hasCapability(.patrol) ? .patrol : .none
                displayedCommands[4] = firstAsset.hasCapability(.mine) ? .mine : .none
                displayedCommands[6] = firstAsset.hasCapability(.buildSimple) && selectionList.count == 1 ? .buildSimple : .none
            } else {
                if firstAsset.action == .construct || firstAsset.action == .capability {
                    displayedCommands[displayedCommands.count - 1] = .cancel
                } else {
                    for i in 0 ..< min(firstAsset.capabilities.count, displayedCommands.count) {
                        displayedCommands[i] = firstAsset.capabilities[i]
                    }
                }
            }
        } else if currentAction == .buildSimple {
            for i in 0 ..< min(UnitActionRenderer.capabilities.count, displayedCommands.count) where firstAsset.hasCapability(UnitActionRenderer.capabilities[i]) {
                displayedCommands[i] = UnitActionRenderer.capabilities[i]
            }
            displayedCommands[displayedCommands.count - 1] = .cancel
        } else {
            displayedCommands[displayedCommands.count - 1] = .cancel
        }

        var xOffset = bevel.width
        var yOffset = bevel.width

        for i in 0 ..< displayedCommands.count {
            let capabilityType = displayedCommands[i]
            if capabilityType != .none {
                let playerCapability = PlayerCapability.findCapability(with: capabilityType)
                try bevel.drawBevel(on: surface, x: xOffset, y: yOffset, width: iconTileset.tileWidth, height: iconTileset.tileHeight)
                try iconTileset.drawTile(on: surface, x: xOffset, y: yOffset, index: commandIndices[capabilityType]!)

                if playerCapability.targetType != .none {
                    if !playerCapability.canInitiate(actor: firstAsset, playerData: playerData) {
                        try iconTileset.drawTile(on: surface, x: xOffset, y: yOffset, index: disabledIndex)
                    }
                }
            }
            xOffset += fullIconWidth + bevel.width
            if i % 3 == 0 {
                xOffset = bevel.width
                yOffset += fullIconHeight + bevel.width
            }
        }
    }
}
