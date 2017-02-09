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

    func decrementLumber(by lumber: Int) -> Int {
        self.lumber -= lumber
        return lumber
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
        var currentEvents: [GameEvent] = [GameEvent]()
        var tempEvent: GameEvent?
        var index: Int = 0

        for row in assetOccupancyMap {
            for var cell in row {
                // cell = nullptr
            }
        }

        for var row in diagonalOccupancyMap {
            for index in 0 ..< row.count {
                row[index] = false
            }
        }

        for asset in actualMap.assets {
            if .conveyGold != asset.action && .conveyLumber != asset.action && .mineGold != asset.action {
                assetOccupancyMap[asset.tilePositionY][asset.tilePositionX] = asset
            }
        }

        for playerIndex in 1 ..< PlayerColor.numberOfColors {
            if players[playerIndex].isAlive() {
                players[playerIndex].updateVisibility()
            }
        }

        var allAssets = actualMap.assets
        for asset in allAssets {
            if .none == asset.action {
                asset.popCommand()
            }
            if .capability == asset.action {
                var command: AssetCommand {
                    return asset.currentCommand()
                }
                if command.activatedCapability != nil {
                    if (command.activatedCapability?.incrementstep()) != nil {
                        // All done
                    }
                } else {
                    var playerCapability: PlayerCapability = PlayerCapability.findCapability(type: command.capability)
                    asset.popCommand()
                    if playerCapability.canApply(actor: asset, playerData: players[asset.color.index], target: command.assetTarget!) {
                        playerCapability.applyCapability(actor: asset, playerData: players[asset.color.index], target: command.assetTarget!)
                    } else {
                        // Can't apply notify problem
                    }
                }
            } else if AssetAction.harvestLumber == asset.action {
                var command: AssetCommand
                command = asset.currentCommand()
                var tilePosition: Position
                tilePosition = (command.assetTarget?.tilePosition)!
                var harvestDirection: Direction = asset.tilePosition.adjacentTileDirection(position: tilePosition, objSize: 0)

                if TerrainMap.TileType.tree != actualMap.tileTypeAt(position: tilePosition) {
                    harvestDirection = Direction.max
                    tilePosition = asset.tilePosition
                }
                if Direction.max == harvestDirection {
                    if tilePosition == asset.tilePosition {
                        var newPosition: Position {
                            return players[asset.color.index].playerMap.findNearestReachableTileType(at: tilePosition, type: TerrainMap.TileType.tree)
                        }
                        asset.popCommand()
                        if 0 <= newPosition.x {
                            newPosition.setFromTile(newPosition)
                            command.assetTarget = self.players[asset.color.index].createMarker(pos: newPosition, addToMap: false)
                            asset.pushCommand(command: command)
                            command.action = .walk
                            asset.pushCommand(command: command)
                            asset.resetStep()
                        }
                    } else {
                        var newCommand: AssetCommand = command
                        newCommand.action = .walk
                        asset.pushCommand(command: newCommand)
                        asset.resetStep()
                    }
                } else {
                    tempEvent?.type = EventType.harvest
                    tempEvent?.asset = asset
                    currentEvents.append(tempEvent!)
                    asset.direction = harvestDirection
                    asset.incrementStep()
                    if harvestSteps <= asset.step {
                        var nearestRepository: PlayerAsset {
                            return players[asset.color.index].findNearestOwnedAsset(pos: asset.position, assetTypes: [AssetType.townHall, AssetType.keep, AssetType.castle, AssetType.lumberMill])
                        }
                        lumberAvailable[tilePosition.y][tilePosition.x] -= lumberPerHarvest
                        if 0 >= lumberAvailable[tilePosition.y][tilePosition.x] {
                            actualMap.changeTileType(position: tilePosition, to: TerrainMap.TileType.stump)
                        }
                        if nearestRepository != nil {
                            command.action = .conveyLumber
                            command.assetTarget = nearestRepository
                            asset.pushCommand(command: command)
                            command.action = .walk
                            asset.pushCommand(command: command)
                            asset.lumber = lumberPerHarvest
                            asset.resetStep()
                        } else {
                            asset.popCommand()
                            asset.lumber = lumberPerHarvest
                            asset.resetStep()
                        }
                    }
                }
            } else if .mineGold == asset.action {
                var command: AssetCommand = asset.currentCommand()

                var closestPosition: Position {
                    return (command.assetTarget?.closestPosition(asset.position))!
                }
                var tilePosition: Position = asset.position
                var mineDirection: Direction

                tilePosition.setToTile(closestPosition)
                mineDirection = asset.tilePosition.adjacentTileDirection(position: tilePosition, objSize: 0)
                if Direction.max == mineDirection && tilePosition != asset.tilePosition {
                    var newCommand: AssetCommand = asset.currentCommand()
                    newCommand.action = .walk
                    asset.pushCommand(command: newCommand)
                    asset.resetStep()
                } else {
                    if 0 == asset.step {
                        if ((command.assetTarget?.commandCount)! + 1) * goldPerMining <= (command.assetTarget?.gold)! {
                            var newCommand: AssetCommand = asset.currentCommand()
                            newCommand.action = .build
                            newCommand.assetTarget = asset

                            command.assetTarget?.enqueueCommand(command: newCommand)
                            asset.incrementStep()
                            asset.tilePosition.setToTile((command.assetTarget?.tilePosition)!)
                        } else {
                            asset.popCommand()
                        }
                    } else {
                        asset.incrementStep()
                        if mineSteps <= asset.step {
                            var oldTarget: PlayerAsset = command.assetTarget!
                            var nearestRepository: PlayerAsset {
                                return players[asset.color.index].findNearestOwnedAsset(pos: asset.position, assetTypes: [AssetType.townHall, AssetType.keep, AssetType.castle])
                            }
                            var nextTarget: Position = asset.position
                            nextTarget.setXToTile(players[asset.color.index].playerMap.width - 1)
                            nextTarget.setYToTile(players[asset.color.index].playerMap.height - 1)

                            command.assetTarget?.decrementGold(goldPerMining)
                            command.assetTarget?.popCommand()
                            if 0 >= (command.assetTarget?.gold)! {
                                var newCommand: AssetCommand = asset.currentCommand()
                                newCommand.action = .death
                                command.assetTarget?.clearCommand()
                                command.assetTarget?.pushCommand(command: newCommand)
                                command.assetTarget?.resetStep()
                            }
                            asset.gold = goldPerMining
                            if nearestRepository != nil {
                                command.action = .conveyGold
                                command.assetTarget = nearestRepository
                                asset.pushCommand(command: command)
                                command.action = .walk
                                asset.pushCommand(command: command)
                                asset.resetStep()
                                nextTarget = (command.assetTarget?.tilePosition)!
                            } else {
                                asset.popCommand()
                            }
                            asset.tilePosition.setToTile(players[asset.color.index].playerMap.findAssetPlacement(placeAsset: asset, fromAsset: oldTarget, nextTileTarget: nextTarget))
                        }
                    }
                }
            } else if AssetAction.standGround == asset.action {
                var command: AssetCommand = asset.currentCommand()
                var newTarget = players[asset.color.index].findNearestEnemy(pos: asset.position, inputRange: asset.effectiveRange)

                if newTarget != nil {
                    command.action = .none
                } else {
                    command.action = .attack
                    command.assetTarget = newTarget
                }
                asset.pushCommand(command: command)
                asset.resetStep()
            } else if .repair == asset.action {
                var currentCommand: AssetCommand
                currentCommand = asset.currentCommand()

                if (currentCommand.assetTarget?.isAlive)! {
                    var repairDirection: Direction {
                        return asset.tilePosition.adjacentTileDirection(position: (currentCommand.assetTarget?.tilePosition)!, objSize: (currentCommand.assetTarget?.size)!)
                    }
                    if .max == repairDirection {
                        var nextCommand: AssetCommand {
                            return asset.nextCommand()
                        }
                        currentCommand.action = .walk
                        asset.pushCommand(command: currentCommand)
                        asset.resetStep()
                    } else {
                        asset.direction = repairDirection
                        asset.incrementStep()
                        if asset.step == asset.attackSteps {
                            if players[asset.color.index].gold != 0 && players[asset.color.index].lumber != 0 {
                                var repairPoints: Int
                                repairPoints = (currentCommand.assetTarget?.maxHitPoints)! * (asset.attackSteps + asset.reloadSteps) / PlayerAsset.updateFrequency * (currentCommand.assetTarget?.buildTime)!

                                if 0 == repairPoints {
                                    repairPoints = 1
                                }
                                players[asset.color.index].decrementGold(by: 1)
                                players[asset.color.index].decrementLumber(by: 1)
                                currentCommand.assetTarget?.incrementHitPoints(repairPoints)
                                if currentCommand.assetTarget?.hitPoints == currentCommand.assetTarget?.maxHitPoints {
                                    tempEvent?.type = .workComplete
                                    tempEvent?.asset = asset
                                    players[asset.color.index].addGameEvent(event: tempEvent!)
                                    asset.popCommand()
                                }
                            } else {
                                asset.popCommand()
                            }
                        }
                        if asset.step >= asset.attackSteps + asset.reloadSteps {
                            asset.resetStep()
                        }
                    }
                } else {
                    asset.popCommand()
                }
            } else if .attack == asset.action {
                var currentCommand: AssetCommand
                currentCommand = asset.currentCommand()
                if .none == asset.type {
                    var closestTargetPosition: Position {
                        return (currentCommand.assetTarget?.closestPosition(asset.position))!
                    }
                    var deltaPosition: Position = asset.position
                    deltaPosition.x = closestTargetPosition.x - asset.positionX
                    deltaPosition.y = closestTargetPosition.y - asset.positionY

                    var movement: Int {
                        return Position.tileWidth * 5 / PlayerAsset.updateFrequency
                    }
                    var targetDistance: Int {
                        return asset.position.distance(position: closestTargetPosition)
                    }
                    var divisor: Int {
                        return (targetDistance + movement - 1) / movement
                    }

                    if divisor != 0 {
                        deltaPosition.x = deltaPosition.x / divisor
                        deltaPosition.y = deltaPosition.y / divisor
                    }
                    asset.positionX = (asset.positionX + deltaPosition.x)
                    asset.positionY = (asset.positionY + deltaPosition.y)
                    asset.direction = asset.position.directionTo(closestTargetPosition)
                    if Position.halfTileWidth * Position.halfTileHeight > asset.position.distanceSquared(closestTargetPosition) {
                        tempEvent?.type = .missleHit
                        tempEvent?.asset = asset
                        currentEvents.append(tempEvent!)
                        if (currentCommand.assetTarget?.isAlive)! {
                            var targetCommand: AssetCommand
                            targetCommand = (currentCommand.assetTarget?.currentCommand())!
                            tempEvent?.type = .attacked
                            tempEvent?.asset = currentCommand.assetTarget!
                            players[(currentCommand.assetTarget?.color.index)!].addGameEvent(event: tempEvent!)
                            if .mineGold != targetCommand.action {
                                if .conveyGold == targetCommand.action || .conveyLumber == targetCommand.action {
                                    currentCommand.assetTarget = targetCommand.assetTarget
                                } else if (.capability == targetCommand.action) && targetCommand.assetTarget != nil {
                                    if ((currentCommand.assetTarget?.speed) != nil) && AssetAction.construct == targetCommand.assetTarget?.action {
                                        currentCommand.assetTarget = targetCommand.assetTarget
                                    }
                                }
                                currentCommand.assetTarget?.decrementHitPoints(asset.hitPoints)
                                if !(currentCommand.assetTarget?.isAlive)! {
                                    var command: AssetCommand
                                    command = (currentCommand.assetTarget?.currentCommand())!

                                    tempEvent?.type = .death
                                    tempEvent?.asset = currentCommand.assetTarget!
                                    currentEvents.append(tempEvent!)

                                    if .capability == command.action && (command.assetTarget != nil) {
                                        if AssetAction.construct == command.assetTarget?.action {
                                            players[(command.assetTarget?.color.index)!].deleteAsset(asset: command.assetTarget!)
                                        }
                                    } else if .construct == command.action {
                                        if command.assetTarget != nil {
                                            command.assetTarget?.clearCommand()
                                        }
                                    }
                                    currentCommand.assetTarget?.direction = asset.direction.opposite
                                    command.action = .death
                                    currentCommand.assetTarget?.clearCommand()
                                    currentCommand.assetTarget?.pushCommand(command: command)
                                    currentCommand.assetTarget?.resetStep()
                                }
                            }
                        }
                        players[asset.color.index].deleteAsset(asset: asset)
                    }
                } else if (currentCommand.assetTarget?.isAlive)! {
                    if 1 == asset.effectiveRange {
                        let attackDirection: Direction = asset.tilePosition.adjacentTileDirection(position: (currentCommand.assetTarget?.tilePosition)!, objSize: (currentCommand.assetTarget?.size)!)
                        if .max == attackDirection {
                            var nextCommand: AssetCommand
                            nextCommand = asset.nextCommand()

                            if .standGround != nextCommand.action {
                                currentCommand.action = .walk
                                asset.pushCommand(command: currentCommand)
                                asset.resetStep()
                            } else {
                                asset.popCommand()
                            }
                        } else {
                            asset.direction = attackDirection
                            asset.incrementStep()
                            if asset.step == asset.attackSteps {
                                var damage: Int = asset.effectiveBasicDamage - (currentCommand.assetTarget?.effectiveArmor)!
                                damage = 0 > damage ? 0 : damage
                                damage += asset.effectivePiercingDamage
                                if Int(randomNumberGenerator.random()) & 0x1 != 0 {
                                    damage /= 2
                                }
                                currentCommand.assetTarget?.decrementHitPoints(damage)
                                tempEvent?.type = .missleHit
                                tempEvent?.asset = asset
                                currentEvents.append(tempEvent!)
                                tempEvent?.type = .attacked
                                tempEvent?.asset = currentCommand.assetTarget!
                                players[(currentCommand.assetTarget?.color.index)!].addGameEvent(event: tempEvent!)
                                if !(currentCommand.assetTarget?.isAlive)! {
                                    var command: AssetCommand = (currentCommand.assetTarget?.currentCommand())!
                                    tempEvent?.type = .death
                                    tempEvent?.asset = currentCommand.assetTarget!
                                    currentEvents.append(tempEvent!)
                                    if .capability == command.action && (command.assetTarget != nil) {
                                        if AssetAction.construct == command.assetTarget?.action {
                                            players[(command.assetTarget?.color.index)!].deleteAsset(asset: command.assetTarget!)
                                        }
                                    } else if .construct == command.action {
                                        if command.assetTarget != nil {
                                            command.assetTarget?.clearCommand()
                                        }
                                    }
                                    command.capability = .none
                                    command.assetTarget = nil
                                    command.activatedCapability = nil
                                    currentCommand.assetTarget?.direction = attackDirection.opposite
                                    command.action = .death
                                    currentCommand.assetTarget?.clearCommand()
                                    currentCommand.assetTarget?.pushCommand(command: command)
                                    currentCommand.assetTarget?.resetStep()
                                }
                            }
                            if asset.step >= asset.attackSteps + asset.reloadSteps {
                                asset.resetStep()
                            }
                        }
                    } else {
                        let closestTargetPosition: Position = (currentCommand.assetTarget?.closestPosition(asset.position))!
                        if closestTargetPosition.distanceSquared(asset.position) > RangeToDistanceSquared(range: asset.effectiveRange) {
                            let nextCommand: AssetCommand = asset.nextCommand()

                            if .standGround != nextCommand.action {
                                currentCommand.action = .walk
                                asset.pushCommand(command: currentCommand)
                                asset.resetStep()
                            } else {
                                asset.popCommand()
                            }
                        } else {
                            let attackDirection: Direction = asset.position.directionTo(closestTargetPosition)
                            asset.direction = attackDirection
                            asset.incrementStep()
                            if asset.step == asset.attackSteps {
                                var attackCommand: AssetCommand = currentCommand
                                let arrowAsset = players[PlayerColor.none.index].createAsset(assetTypeName: "None")
                                var damage: Int = asset.effectiveBasicDamage - (currentCommand.assetTarget?.effectiveArmor)!
                                damage = 0 > damage ? 0 : damage
                                damage += asset.effectivePiercingDamage
                                if Int(randomNumberGenerator.random()) & 0x1 != 0 {
                                    damage /= 2
                                }
                                tempEvent?.type = .missleFire
                                tempEvent?.asset = asset
                                currentEvents.append(tempEvent!)

                                arrowAsset.hitPoints = damage
                                arrowAsset.position = asset.position
                                if arrowAsset.positionX < closestTargetPosition.x {
                                    arrowAsset.positionX = arrowAsset.positionX + Position.halfTileWidth
                                } else if arrowAsset.positionX > closestTargetPosition.x {
                                    arrowAsset.positionX = arrowAsset.positionX - Position.halfTileWidth
                                }

                                if arrowAsset.positionY < closestTargetPosition.y {
                                    arrowAsset.positionY = arrowAsset.positionY + Position.halfTileHeight
                                } else if arrowAsset.positionY > closestTargetPosition.y {
                                    arrowAsset.positionY = arrowAsset.positionY - Position.halfTileHeight
                                }
                                arrowAsset.direction = attackDirection
                                attackCommand.action = .construct
                                attackCommand.assetTarget = asset
                                arrowAsset.pushCommand(command: attackCommand)
                                attackCommand.action = .attack
                                attackCommand.assetTarget = currentCommand.assetTarget
                                arrowAsset.pushCommand(command: attackCommand)
                            }
                            if asset.step >= asset.attackSteps + asset.reloadSteps {
                                asset.resetStep()
                            }
                        }
                    }
                } else {
                    let nextCommand = asset.nextCommand()
                    asset.popCommand()
                    if .standGround != nextCommand.action {
                        let newTarget = players[asset.color.index].findNearestEnemy(pos: asset.position, inputRange: asset.effectiveSight)

                        if newTarget != nil {
                            currentCommand.assetTarget = newTarget
                            asset.pushCommand(command: currentCommand)
                            asset.resetStep()
                        }
                    }
                }
            } else if .conveyLumber == asset.action || .conveyGold == asset.action {
                asset.incrementStep()
                if conveySteps <= asset.step {
                    let command = asset.currentCommand()
                    var nextTarget: Position?
                    nextTarget?.setXToTile(players[asset.color.index].playerMap.width - 1)
                    nextTarget?.setYToTile(players[asset.color.index].playerMap.height - 1)
                    players[asset.color.index].incrementGold(by: asset.gold)
                    players[asset.color.index].incrementLumber(by: asset.lumber)
                    asset.gold = 0
                    asset.lumber = 0
                    asset.popCommand()
                    asset.resetStep()
                    if .none != asset.action {
                        nextTarget = (asset.currentCommand().assetTarget?.tilePosition)!
                    }
                    asset.position = players[asset.color.index].playerMap.findAssetPlacement(placeAsset: asset, fromAsset: command.assetTarget!, nextTileTarget: nextTarget!)
                }
            } else if .construct == asset.action {
                let command: AssetCommand = asset.currentCommand()
                if command.activatedCapability != nil {
                    if (command.activatedCapability?.incrementstep()) != nil {
                        // All Done
                    }
                }
            } else if .death == asset.action {
                asset.incrementStep()
                if asset.step > deathSteps {
                    if asset.speed != 0 {
                        var decayCommand: AssetCommand?
                        let corpseAsset = players[PlayerColor.none.index].createAsset(assetTypeName: "None")
                        decayCommand?.action = .decay
                        corpseAsset.position = asset.position
                        corpseAsset.direction = asset.direction
                        corpseAsset.pushCommand(command: decayCommand!)
                    }
                    players[asset.color.index].deleteAsset(asset: asset)
                }
            } else if .decay == asset.action {
                asset.incrementStep()
                if asset.step > decaySteps {
                    players[asset.color.index].deleteAsset(asset: asset)
                }
            }
            if .walk == asset.action {
                if asset.tileAligned {
                    var command: AssetCommand = asset.currentCommand()
                    let nextCommand: AssetCommand = asset.nextCommand()
                    var travelDirection: Direction
                    let mapTarget: Position = (command.assetTarget?.closestPosition(asset.position))!

                    if .attack == nextCommand.action {
                        if (nextCommand.assetTarget?.closestPosition(asset.position).distanceSquared(asset.position))! <= RangeToDistanceSquared(range: asset.effectiveRange) {
                            asset.popCommand()
                            asset.resetStep()
                            continue
                        }
                    }

                    travelDirection = (routerMap?.findRoute(resMap: players[asset.color.index].playerMap, asset: asset, target: mapTarget))!
                    if .max != travelDirection {
                        asset.direction = travelDirection
                    } else {
                        let tilePosition: Position = asset.position
                        tilePosition.setToTile(mapTarget)
                        if tilePosition == asset.tilePosition || .max != asset.tilePosition.adjacentTileDirection(position: tilePosition, objSize: 0) {
                            asset.popCommand()
                            asset.resetStep()
                            continue
                        } else if .harvestLumber == nextCommand.action {
                            let newPosition: Position = players[asset.color.index].playerMap.findNearestReachableTileType(at: asset.tilePosition, type: .tree)
                            asset.popCommand()
                            asset.popCommand()
                            if 0 <= newPosition.x {
                                newPosition.setFromTile(newPosition)
                                command.action = .harvestLumber
                                command.assetTarget = players[asset.color.index].createMarker(pos: newPosition, addToMap: false)
                                asset.pushCommand(command: command)
                                command.action = .walk
                                asset.pushCommand(command: command)
                                asset.resetStep()
                                continue
                            }
                        } else {
                            command.action = .none
                            asset.pushCommand(command: command)
                            asset.resetStep()
                            continue
                        }
                    }
                }
                if asset.moveStep(occupancyMap: &assetOccupancyMap, diagonals: &diagonalOccupancyMap) != nil {
                    asset.direction = asset.position.tileOctant.opposite
                }
            }
        }
        gameCycle += 1
        for playerIndex in 0 ..< PlayerColor.numberOfColors {
            players[playerIndex].incrementCycle()
            players[playerIndex].appendGameEvents(events: currentEvents)
        }
    }

    func clearGameEvents() {
        for player in players {
            player.clearGameEvents()
        }
    }
}
