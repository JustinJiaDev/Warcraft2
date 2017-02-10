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

fileprivate func rangeToDistanceSquared(_ range: Int) -> Int {
    var newRange = range
    newRange *= Position.tileWidth
    newRange *= range
    newRange += Position.tileWidth * Position.tileWidth
    return newRange
}

class PlayerData {
    var isAI: Bool
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

    var isAlive: Bool {
        return assets.count != 0
    }

    var foodConsumption: Int {
        var totalConsumption = 0
        for asset in assets {
            let assetConsumption = asset.foodConsumption
            if assetConsumption > 0 {
                totalConsumption += assetConsumption
            }
        }
        return totalConsumption
    }

    var foodProduction: Int {
        var totalProduction = 0
        for asset in assets {
            let assetConsumption = foodConsumption
            if assetConsumption < 0 && (asset.action != .construct || asset.currentCommand().assetTarget == nil) {
                totalProduction += -assetConsumption
            }
        }
        return totalProduction
    }

    var idleAssets: [PlayerAsset] {
        return assets.filter { asset in
            return asset.action == .none && asset.type != .none
        }
    }

    init(map: AssetDecoratedMap, color: PlayerColor) {
        self.isAI = true
        self.color = color
        self.actualMap = map
        self.visibilityMap = actualMap.createVisibilityMap()
        self.playerMap = self.actualMap.createInitializeMap()
        self.assetTypes = PlayerAssetType.duplicateRegistry(changeColorTo: self.color)
        self.assets = []
        self.upgrades = []
        self.gameEvents = []
        self.gold = 0
        self.lumber = 0
        self.gameCycle = 0

        upgrades = Array(repeating: false, count: AssetCapabilityType.max.rawValue)

        for resource in actualMap.resourceInitializationList {
            if resource.color == self.color {
                gold = resource.gold
                lumber = resource.lumber
            }
        }

        for asset in actualMap.assetInitializationList {
            if asset.color == self.color {
                printDebug("Init \(asset.type) \(asset.color) (\(asset.tilePosition.x), \(asset.tilePosition.y))", level: .low)
                let initAsset = createAsset(with: asset.type)
                initAsset.tilePosition = asset.tilePosition
                if PlayerAssetType.findType(with: asset.type) == .goldMine {
                    initAsset.gold = self.gold
                }
            }
        }
    }

    func incrementCycle() {
        gameCycle += 1
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

    func decrementLumber(by lumber: Int) -> Int {
        self.lumber -= lumber
        return lumber
    }

    func createMarker(at position: Position, addToMap: Bool) -> PlayerAsset {
        let newMarker = assetTypes["None"]!.construct()
        let tilePosition = Position()
        tilePosition.setToTile(position)
        newMarker.tilePosition = tilePosition
        if addToMap {
            playerMap.addAsset(newMarker)
        }
        return newMarker
    }

    func createAsset(with name: String) -> PlayerAsset {
        let newAsset = assetTypes[name]!.construct()
        newAsset.creationCycle = gameCycle
        assets.append(newAsset)
        actualMap.addAsset(newAsset)
        return newAsset
    }

    func deleteAsset(_ asset: PlayerAsset) {
        if let index = assets.index(where: { $0 === asset }) {
            assets.remove(at: index)
            actualMap.removeAsset(asset)
        }
    }

    func assetRequirementsIsMet(name: String) -> Bool {
        var assetCount = Array(repeating: 0, count: AssetType.max.rawValue)
        for asset in assets where asset.action != .construct {
            assetCount[asset.type.rawValue] += 1
        }
        for requirement in assetTypes[name]!.assetRequirements {
            if assetCount[requirement.rawValue] == 0 {
                if requirement == .keep && assetCount[AssetType.castle.rawValue] != 0 {
                    continue
                }
                if requirement == .townHall && (assetCount[AssetType.castle.rawValue] != 0 || assetCount[AssetType.keep.rawValue] != 0) {
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

    func selectAssets(in selectArea: Rectangle, assetType: AssetType, selectIdentical: Bool = false) -> [PlayerAsset] {
        var returnList: [PlayerAsset] = []
        if selectArea.width == 0 || selectArea.height == 0 {
            if let bestAsset = selectAsset(at: Position(x: selectArea.xPosition, y: selectArea.yPosition), assetType: assetType) {
                returnList.append(bestAsset)
                if selectIdentical && bestAsset.speed != 0 {
                    for asset in assets where bestAsset !== asset && asset.type == assetType {
                        returnList.append(asset)
                    }
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

    func selectAsset(at position: Position, assetType: AssetType) -> PlayerAsset? {
        guard assetType != .none else {
            return nil
        }
        var bestAsset: PlayerAsset?
        var bestDistanceSquared = -1
        for asset in assets where asset.type == assetType {
            let currentDistanceSquared = asset.position.distanceSquared(position)
            if bestDistanceSquared == -1 || currentDistanceSquared < bestDistanceSquared {
                bestDistanceSquared = currentDistanceSquared
                bestAsset = asset
            }
        }
        return bestAsset
    }

    func findNearestOwnedAsset(at position: Position, assetTypes: [AssetType]) -> PlayerAsset? {
        var bestAsset: PlayerAsset?
        var bestDistanceSquared = -1
        for asset in assets {
            for assetType in assetTypes where asset.type == assetType && (asset.action != .construct || assetType == .keep || assetType == .castle) {
                let currentDistanceSquared = asset.position.distanceSquared(position)
                if bestDistanceSquared == -1 || currentDistanceSquared < bestDistanceSquared {
                    bestDistanceSquared = currentDistanceSquared
                    bestAsset = asset
                }
                break
            }
        }
        return bestAsset
    }

    func findNearestAsset(at position: Position, assetType: AssetType) -> PlayerAsset? {
        var bestAsset: PlayerAsset?
        var bestDistanceSquared = -1
        for asset in playerMap.assets where asset.type == assetType {
            let currentDistanceSquared = asset.position.distanceSquared(position)
            if bestDistanceSquared == -1 || currentDistanceSquared < bestDistanceSquared {
                bestDistanceSquared = currentDistanceSquared
                bestAsset = asset
            }
        }
        return bestAsset
    }

    func findNearestEnemy(at position: Position, inputRange: Int) -> PlayerAsset? {
        var bestAsset: PlayerAsset?
        var bestDistanceSquared = -1
        var range = inputRange
        if range > 0 {
            range = rangeToDistanceSquared(range)
        }

        for asset in playerMap.assets where asset.color != self.color && asset.color != .none && asset.isAlive {
            let command = asset.currentCommand()
            if command.action == .capability {
                if let tempTarget = command.assetTarget {
                    if tempTarget.action == .construct {
                        continue
                    }
                }
            }
            if command.action != .conveyGold && command.action != .conveyLumber && command.action != .mineGold {
                let currentDistanceSquared = asset.closestPosition(position).distanceSquared(position)
                if range < 0 || range >= currentDistanceSquared {
                    if bestDistanceSquared == -1 || currentDistanceSquared < bestDistanceSquared {
                        bestDistanceSquared = currentDistanceSquared
                        bestAsset = asset
                    }
                }
            }
        }
        return bestAsset
    }

    func findBestAssetPlacement(at position: Position, builder: PlayerAsset, assetTypeInput: AssetType, buffer: Int) -> Position {
        let assetType: PlayerAssetType = assetTypes[PlayerAssetType.findName(with: assetTypeInput)]!
        let placementSize = assetType.size + 2 * buffer
        let maxDistance = max(playerMap.width, playerMap.height)

        for distance in 0 ..< maxDistance {
            var bestPosition: Position!
            var bestDistance = -1
            var leftX = position.x - distance
            var topY = position.y - distance
            var rightX = position.x + distance
            var bottomY = position.y + distance
            var leftValid = true
            var rightValid = true
            var topValid = true
            var bottomValid = true

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

    func playerAssetCount(of type: AssetType) -> Int {
        return playerMap.assets.filter { asset in
            return asset.type == type && asset.color == self.color
        }.count
    }

    func assetCount(of type: AssetType) -> Int {
        return playerMap.assets.filter { asset in
            return asset.type == type
        }.count
    }

    func addUpgrade(with name: String) {
        let upgrade = PlayerUpgrade.findUpgrade(with: name)
        for assetType in upgrade.affectedAssets {
            let assetName = PlayerAssetType.findName(with: assetType)
            if let assetType = assetTypes[assetName] {
                assetType.addUpgrade(upgrade)
            }
        }
        upgrades[PlayerCapability.findType(with: name).rawValue] = true
    }

    func hasUpgrade(with type: AssetCapabilityType) -> Bool {
        guard type.rawValue >= 0 && type.rawValue < upgrades.count else {
            return false
        }
        return upgrades[type.rawValue]
    }

    func clearGameEvents() {
        gameEvents.removeAll()
    }

    func addGameEvent(_ event: GameEvent) {
        gameEvents.append(event)
    }

    func appendGameEvents(_ events: [GameEvent]) {
        gameEvents.append(contentsOf: events)
    }
}

class GameModel {
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
    private var randomNumberGenerator: RandomNumberGenerator

    private(set) var gameCycle: Int
    private(set) var actualMap: AssetDecoratedMap
    private var routerMap: RouterMap

    private var players: [PlayerData]

    private var assetOccupancyMap: [[PlayerAsset?]]
    private var diagonalOccupancyMap: [[Bool?]]
    private var lumberAvailable: [[Int]]

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

        randomNumberGenerator = RandomNumberGenerator()
        randomNumberGenerator.seed(seed)
        gameCycle = 0

        actualMap = AssetDecoratedMap.duplicateMap(at: mapIndex, newColors: newColors)
        routerMap = RouterMap()

        players = []
        for playerIndex in 0 ..< PlayerColor.numberOfColors {
            players.append(PlayerData(map: actualMap, color: PlayerColor(index: playerIndex)!))
        }

        assetOccupancyMap = Array(repeating: Array(repeating: nil, count: actualMap.width), count: actualMap.height)
        diagonalOccupancyMap = Array(repeating: Array(repeating: nil, count: actualMap.width), count: actualMap.height)

        lumberAvailable = Array(repeating: Array(repeating: 0, count: actualMap.width), count: actualMap.height)
        for row in 0 ..< actualMap.height {
            for column in 0 ..< actualMap.width where actualMap.tileTypeAt(x: column, y: row) == .tree {
                lumberAvailable[row][column] = players[0].lumber
            }
        }
    }

    func isValidAsset(_ playerAsset: PlayerAsset) -> Bool {
        return actualMap.assets.first { asset in
            return asset === playerAsset
        } != nil
    }

    func player(with color: PlayerColor) -> PlayerData {
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
