import UIKit

protocol UnitActionRendererDelegate {
    func selectedAction(_ action: AssetCapabilityType, in collectionView: UICollectionView)
}

class UnitActionRenderer: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    private(set) var iconTileset: GraphicTileset
    private let playerData: PlayerData
    private let playerColor: PlayerColor
    private let commandIndices: [AssetCapabilityType: Int]
    private let disabledIndex: Int
    private let delegate: UnitActionRendererDelegate
    private var displayedCommands: [AssetCapabilityType]

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

    init(icons: GraphicTileset, color: PlayerColor, player: PlayerData, delegate: UnitActionRendererDelegate) {
        self.iconTileset = icons
        self.playerColor = color
        self.playerData = player
        self.delegate = delegate
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
    }

    func drawUnitAction(on view: UICollectionView, selectedAsset: PlayerAsset?, currentAction: AssetCapabilityType) {
        guard let selectedAsset = selectedAsset else {
            return
        }
        guard selectedAsset.color == playerColor else {
            return
        }

        let isMoveable = selectedAsset.speed > 0
        let hasCargo = selectedAsset.lumber > 0 || selectedAsset.gold > 0

        displayedCommands.removeAll()
        if [.none, .cancel].contains(currentAction) {
            if isMoveable {
                displayedCommands.append(hasCargo ? .convey : .move)
                displayedCommands.append(.standGround)
                displayedCommands.append(.attack)
                if selectedAsset.hasCapability(.repair) {
                    displayedCommands.append(.repair)
                }
                if selectedAsset.hasCapability(.patrol) {
                    displayedCommands.append(.patrol)
                }
                if selectedAsset.hasCapability(.mine) {
                    displayedCommands.append(.mine)
                }
                if selectedAsset.hasCapability(.buildSimple) {
                    displayedCommands.append(.buildSimple)
                }
            } else if [.construct, .capability].contains(selectedAsset.action) {
                displayedCommands.append(.cancel)
            } else {
                displayedCommands = selectedAsset.capabilities
            }
        } else if currentAction == .buildSimple {
            displayedCommands = UnitActionRenderer.capabilities.filter { capability in
                return selectedAsset.hasCapability(capability)
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
        delegate.selectedAction(displayedCommands[indexPath.row], in: collectionView)
    }
}
