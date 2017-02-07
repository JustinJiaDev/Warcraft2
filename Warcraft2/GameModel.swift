enum EventType {
    case none
    case workComplete
    case selection
    case acknowledge
    case ready
    case death
    case attacked
    case missleFire
    case missleHit
    case harvest
    case meleeHist
    case placeAction
    case buttonTick
    case max
}

struct GameEvent {
    var type: EventType
    var asset: PlayerAsset
}

func RangeToDistanceSquared(range: Int) -> Int {
    var newRange: Int = range
    newRange *= Position.tileWidth
    newRange *= range
    newRange += Position.tileWidth * Position.tileWidth

    return newRange
}

class PlayerData {
    var isAi: Bool
    private(set) var color: PlayerColor
    private var actualMap: AssetDecoratedMap
    private(set) var visibilityMap: VisibilityMap
    private(set) var playerMap: AssetDecoratedMap
    private(set) var assetTypes: [String: PlayerAssetType]
    private(set) var assets: [PlayerAsset]
    private var upgrades: [Bool]
    private(set) var gameEvents: [GameEvent]
    private(set) var gold: Int
    private(set) var lumber: Int
    private(set) var gameCycle: Int

    init(map: AssetDecoratedMap, color: PlayerColor) {
        self.isAi = true
        self.color = color
        self.actualMap = map
        self.visibilityMap = actualMap.createVisibilityMap()
        self.playerMap = self.actualMap.createInitializeMap()
        self.assetTypes = PlayerAssetType.duplicateRegistry(color: self.color)
        self.assets = []
        self.upgrades = []
        self.gameEvents = []
        self.gold = 0
        self.lumber = 0
        self.gameCycle = 0

        upgrades = Array(repeating: false, count: AssetCapabilityType.max.rawValue)

        for resouceInit in actualMap.resourceInitializationList {
            if resouceInit.color == self.color {
                gold = resouceInit.gold
                lumber = resouceInit.lumber
            }
        }

        for assetInit in actualMap.assetInitializationList {
            if assetInit.color == self.color {
                printDebug("Asset Init Error")
                let initAsset: PlayerAsset = createAsset(assetTypeName: assetInit.type)
                initAsset.tilePosition = assetInit.tilePosition
                if AssetType.goldMine == PlayerAssetType.type(from: assetInit.type) {
                    initAsset.gold = self.gold
                }
            }
        }
    }

    func incrementCycle() {
        gameCycle += 1
    }

    func isAlive() -> Bool {
        return assets.count != 0
    }

    func incrementGold(by gold: Int) -> Int {
        self.gold += gold
        return self.gold
    }

    func decrementGold(by gold: Int) -> Int {
        self.gold -= gold
        return self.gold
    }

    func incrementLumber(by lumber: Int) -> Int {
        self.lumber += lumber
        return self.lumber
    }

    func foodConsumption() -> Int {
        var totalConsumption: Int = 0

        for asset in assets {
            let assetConsumption = asset.foodConsumption
            if assetConsumption > 0 {
                totalConsumption += assetConsumption
            }
        }

        return totalConsumption
    }

    func foodProduction() -> Int {
        var totalProduction: Int = 0
        for asset in assets {
            let assetConsumption: Int = foodConsumption()
            if (assetConsumption < 0) && ((AssetAction.construct != asset.action) || (asset.currentCommand().assetTarget == nil)) {
                totalProduction += -assetConsumption
            }
        }

        return totalProduction
    }

    func createMarker(pos: Position, addToMap: Bool) -> PlayerAsset {
        let newMarker: PlayerAsset = assetTypes["None"]!.construct()
        let tilePosition = Position()
        tilePosition.setToTile(pos)
        newMarker.tilePosition = tilePosition
        if addToMap {
            playerMap.addAsset(newMarker)
        }

        return newMarker
    }

    func createAsset(assetTypeName: String) -> PlayerAsset {
        let createdAsset: PlayerAsset = assetTypes[assetTypeName]!.construct()

        createdAsset.creationCycle = gameCycle
        assets.append(createdAsset)
        actualMap.addAsset(createdAsset)
        return createdAsset
    }

    func deleteAsset(asset: PlayerAsset) {
        if let index = assets.index(where: { $0 === asset }) {
            assets.remove(at: index)
            actualMap.removeAsset(asset)
        }
    }

    func assetRequirementsMet(assetTypeName: String) -> Bool {
        var assetCount: [Int] = Array(repeating: 0, count: AssetType.max.rawValue)

        for asset in assets {
            if AssetAction.construct != asset.action {
                assetCount[asset.type.rawValue] += 1
            }
        }

        guard let reqList = assetTypes[assetTypeName]?.assetRequirements else { assert(false) }

        for requirement in reqList {
            if assetCount[requirement.rawValue] == 0 {
                if (AssetType.keep == requirement) && (assetCount[AssetType.castle.rawValue] != 0) {
                    continue
                }
                if (AssetType.townHall == requirement) && ((assetCount[AssetType.castle.rawValue] != 0) || (assetCount[AssetType.keep.rawValue] != 0)) {
                    continue
                }
                return false
            }
        }
        return true
    }

    func updateVisibility() {
        var removeList: [PlayerAsset] = []

        visibilityMap.update(assets: assets)
        playerMap.updateMap(visibilityMap: visibilityMap, assetDecoratedMap: actualMap)
        for asset in playerMap.assets {
            if asset.type == .none && asset.action == .none {
                asset.incrementStep()
                if PlayerAsset.updateFrequency < asset.step * 2 {
                    removeList.append(asset)
                }
            }
        }
        for asset in removeList {
            playerMap.removeAsset(asset)
        }
    }

    func selectAssets(selectArea: Rectangle, assetType: AssetType, selectIdentical: Bool = false) -> [PlayerAsset] {
        var returnList: [PlayerAsset] = []
        if selectArea.width == 0 || selectArea.height == 0 {
            let bestAsset = selectAsset(pos: Position(x: selectArea.xPosition, y: selectArea.yPosition), assetType: assetType)
            returnList.append(bestAsset)
            if selectIdentical && bestAsset.speed != 0 {
                for asset in assets where bestAsset !== asset && asset.type == assetType {
                    returnList.append(asset)
                }
            }
        } else {
            var anyMovable = false
            for asset in assets {
                if selectArea.xPosition <= asset.positionX
                    && asset.positionX < selectArea.xPosition + selectArea.width
                    && selectArea.yPosition <= asset.positionY
                    && asset.positionY < selectArea.yPosition + selectArea.height {
                    if anyMovable {
                        if asset.speed != 0 {
                            returnList.append(asset)
                        }
                    } else {
                        if asset.speed != 0 {
                            returnList.removeAll()
                            returnList.append(asset)
                            anyMovable = true
                        } else if returnList.isEmpty {
                            returnList.append(asset)
                        }
                    }
                }
            }
        }
        return returnList
    }

    func selectAsset(pos: Position, assetType: AssetType) -> PlayerAsset {
        var bestAsset: PlayerAsset!
        var bestDistanceSquared = -1

        if .none != assetType {
            for asset in assets {
                if asset.type == assetType {
                    let currentDistanceSquared = asset.position.distanceSquared(pos)
                    if -1 == bestDistanceSquared || currentDistanceSquared < bestDistanceSquared {
                        bestDistanceSquared = currentDistanceSquared
                        bestAsset = asset
                    }
                }
            }
        }
        return bestAsset
    }

    func findNearestOwnedAsset(pos: Position, assetTypes: [AssetType]) -> PlayerAsset {
        var bestAsset: PlayerAsset!
        var bestDistanceSquared: Int = -1

        for asset in assets {
            for assetType in assetTypes {
                if (asset.type == assetType) && ((AssetAction.construct != asset.action) || (AssetType.keep == assetType) || (AssetType.castle == assetType)) {
                    let currentDistanceSquared = asset.position.distanceSquared(pos)

                    if (bestDistanceSquared == -1) || (bestDistanceSquared > currentDistanceSquared) {
                        bestDistanceSquared = currentDistanceSquared
                        bestAsset = asset
                    }
                    break
                }
            }
        }
        return bestAsset
    }

    func findNearestAsset(pos: Position, assetType: AssetType) -> PlayerAsset {
        var bestAsset: PlayerAsset!
        var bestDistanceSquared: Int = -1

        for asset in playerMap.assets {
            if asset.type == assetType {
                let currentDistanceSquared = asset.position.distanceSquared(pos)

                if (bestDistanceSquared == -1) || (bestDistanceSquared > currentDistanceSquared) {
                    bestDistanceSquared = currentDistanceSquared
                    bestAsset = asset
                }
            }
        }
        return bestAsset
    }

    func findNearestEnemy(pos: Position, inputRange: Int) -> PlayerAsset {
        var bestAsset: PlayerAsset!
        var bestDistanceSquared: Int = -1
        var range: Int = inputRange

        if range > 0 {
            range = RangeToDistanceSquared(range: range)
        }

        for asset in playerMap.assets {
            if (asset.color != self.color) && (asset.color != PlayerColor.none) && (asset.isAlive == true) {
                let command: AssetCommand = asset.currentCommand()
                if AssetAction.capability == command.action {
                    if let tempTarget = command.assetTarget {
                        if AssetAction.construct == tempTarget.action {
                            continue
                        }
                    }
                }
                if (AssetAction.conveyGold != command.action) && (AssetAction.conveyLumber != command.action) && (AssetAction.mineGold != command.action) {
                    let currentDistanceSquared: Int = asset.closestPosition(pos).distanceSquared(pos)

                    if (range < 0) || (range >= currentDistanceSquared) {
                        if (bestDistanceSquared == -1) || (bestDistanceSquared > currentDistanceSquared) {
                            bestDistanceSquared = currentDistanceSquared
                            bestAsset = asset
                        }
                    }
                }
            }
        }
        return bestAsset
    }

    func findBestAssetPlacement(pos: Position, builder: PlayerAsset, assetTypeInput: AssetType, buffer: Int) -> Position {

        guard let assetType: PlayerAssetType = assetTypes[PlayerAssetType.name(from: assetTypeInput)] else { assert(false) }
        let placementSize: Int = assetType.size + 2 * buffer
        let maxDistance: Int = max(playerMap.width, playerMap.height)

        for distance in 0 ..< maxDistance {

            var bestPosition: Position!
            var bestDistance: Int = -1
            var leftX: Int = pos.x - distance
            var topY: Int = pos.y - distance
            var rightX: Int = pos.x + distance
            var bottomY: Int = pos.y + distance
            var leftValid: Bool = true
            var rightValid: Bool = true
            var topValid: Bool = true
            var bottomValid: Bool = true

            if leftX < 0 {
                leftValid = false
                leftX = 0
            }
            if topY < 0 {
                topValid = false
                topY = 0
            }
            if rightX >= playerMap.width {
                rightValid = false
                rightX = playerMap.width - 1
            }
            if bottomY >= playerMap.height {
                bottomValid = false
                bottomY = playerMap.height - 1
            }

            if topValid {
                for index in leftX ... rightX {
                    let tempPosition: Position = Position(x: index, y: topY)
                    if playerMap.canPlaceAsset(at: tempPosition, size: placementSize, ignoreAsset: builder) {
                        let currentDistance: Int = builder.tilePosition.distanceSquared(tempPosition)
                        if (bestDistance == -1) || (bestDistance > currentDistance) {
                            bestDistance = currentDistance
                            bestPosition = tempPosition
                        }
                    }
                }
            }
            if rightValid {
                for index in topY ... bottomY {
                    let tempPosition: Position = Position(x: rightX, y: index)
                    if playerMap.canPlaceAsset(at: tempPosition, size: placementSize, ignoreAsset: builder) {
                        let currentDistance: Int = builder.tilePosition.distanceSquared(tempPosition)
                        if bestDistance == -1 || bestDistance > currentDistance {
                            bestDistance = currentDistance
                            bestPosition = tempPosition
                        }
                    }
                }
            }
            if bottomValid {
                for index in topY ... bottomY {
                    let tempPosition: Position = Position(x: index, y: bottomY)
                    if playerMap.canPlaceAsset(at: tempPosition, size: placementSize, ignoreAsset: builder) {
                        let currentDistance: Int = builder.tilePosition.distanceSquared(tempPosition)
                        if bestDistance == -1 || bestDistance > currentDistance {
                            bestDistance = currentDistance
                            bestPosition = tempPosition
                        }
                    }
                }
            }
            if leftValid {
                for index in topY ... bottomY {
                    let tempPosition: Position = Position(x: leftX, y: index)
                    if playerMap.canPlaceAsset(at: tempPosition, size: placementSize, ignoreAsset: builder) {
                        let currentDistance: Int = builder.tilePosition.distanceSquared(tempPosition)
                        if bestDistance == -1 || bestDistance > currentDistance {
                            bestDistance = currentDistance
                            bestPosition = tempPosition
                        }
                    }
                }
            }

            if bestDistance != -1 {
                return Position(x: bestPosition.x + buffer, y: bestPosition.y + buffer)
            }
        }

        return Position(x: -1, y: -1)
    }

    func playerAssetCount(type: AssetType) -> Int {
        var count: Int = 0

        for asset in playerMap.assets {
            if (asset.color == self.color) && (asset.type == type) {
                count = count + 1
            }
        }

        return count
    }

    func foundAssetCount(type: AssetType) -> Int {
        var count: Int = 0

        for asset in playerMap.assets {
            if asset.type == type {
                count = count + 1
            }
        }

        return count
    }

    func idleAssets() -> [PlayerAsset] {

        var assetList: [PlayerAsset] = []

        for asset in assets {
            if (AssetAction.none == asset.action) && (AssetType.none != asset.type) {
                assetList.append(asset)
            }
        }

        return assetList
    }

    func addUpgrade(upgradeName: String) {

        let upgrade: PlayerUpgrade = PlayerUpgrade.findUpgrade(name: upgradeName)
        for assetType in upgrade.affectedAssets {
            let assetName = PlayerAssetType.name(from: assetType)
            if assetTypes[assetName] != nil {
                assetTypes[assetName]?.addUpgrade(upgrade: upgrade)
            }
        }

        upgrades[(PlayerCapability.nameToType(name: upgradeName)).rawValue] = true
    }

    func hasUpgrade(upgrade: AssetCapabilityType) -> Bool {
        fatalError("not yet ported")
    }

    func clearGameEvents() {
        gameEvents.removeAll()
    }

    func addGameEvent(event: GameEvent) {
        gameEvents.append(event)
    }

    func appendGameEvents(events: [GameEvent]) {
        fatalError("not yet ported")
    }
}

class GameModel {
    private var randomNumberGenerator: RandomNumberGenerator
    private var actualMap: AssetDecoratedMap
    private var assetOccupancyMap: [[PlayerAsset?]]
    private var diagonalOccupancyMap: [[Bool?]]
    private var routerMap: RouterMap?
    private var players: [PlayerData]
    private var lumberAvailable: [[Int]]
    private(set) var gameCycle: Int = 0
    private var harvestTime: Int
    private var harvestSteps: Int
    private var mineTime: Int
    private var mineSteps: Int
    private var conveyTime: Int
    private var conveySteps: Int
    private var deathTime: Int
    private var deathSteps: Int
    private var decayTime: Int
    private var decaySteps: Int
    private var lumberPerHarvest: Int
    private var goldPerMining: Int

    init(mapIndex: Int, seed: UInt64, newColors: [PlayerColor]) {
        harvestTime = 5
        harvestSteps = PlayerAsset.updateFrequency * harvestTime
        mineTime = 5
        mineSteps = PlayerAsset.updateFrequency * mineTime
        conveyTime = 1
        conveySteps = PlayerAsset.updateFrequency * conveyTime
        deathTime = 1
        deathSteps = PlayerAsset.updateFrequency * deathTime
        decayTime = 4
        decaySteps = PlayerAsset.updateFrequency * decayTime
        lumberPerHarvest = 100
        goldPerMining = 100
        players = []

        randomNumberGenerator = RandomNumberGenerator()
        randomNumberGenerator.seed(seed)
        actualMap = AssetDecoratedMap.duplicateMap(at: mapIndex, newColors: newColors)

        for playerIndex in 0 ..< PlayerColor.numberOfColors {
            players.append(PlayerData(map: actualMap, color: PlayerColor(index: playerIndex)!))
        }
        assetOccupancyMap = Array(repeating: Array(repeating: nil, count: actualMap.width), count: actualMap.height)
        diagonalOccupancyMap = Array(repeating: Array(repeating: nil, count: actualMap.width), count: actualMap.height)
        lumberAvailable = Array(repeating: Array(repeating: 0, count: actualMap.width), count: actualMap.height)
        for row in 0 ..< actualMap.height {
            for col in 0 ..< actualMap.width {
                if actualMap.tileTypeAt(x: col, y: row) == .tree {
                    lumberAvailable[row][col] = players[0].lumber
                }
            }
        }
    }

    func validAsset(playerAsset: PlayerAsset) -> Bool {
        for asset in actualMap.assets {
            if asset === playerAsset {
                return true
            }
        }
        return false
    }

    func map() -> AssetDecoratedMap {
        return actualMap
    }

    func player(color: PlayerColor) -> PlayerData {
        return players[color.index]
    }

    func timestep() {
        fatalError("not yet implemented")
    }

    func clearGameEvents() {
        for player in players {
            player.clearGameEvents()
        }
    }
}
