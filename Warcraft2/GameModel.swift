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
    private(set) var actualMap: AssetDecoratedMap
    private(set) var visibilityMap: VisibilityMap
    private(set) var playerMap: AssetDecoratedMap
    private(set) var assetTypes: [String: PlayerAssetType]
    private(set) var assets: [PlayerAsset]
    private(set) var upgrades: [Bool]
    private(set) var gameEvents: [GameEvent]
    private(set) var gold: Int
    private(set) var lumber: Int
    private(set) var gameCycle: Int

    var isAlive: Bool {
        return assets.count != 0
    }

    var foodConsumption: Int {
        var totalConsumption = 0
        for asset in assets where asset.foodConsumption > 0 {
            totalConsumption += asset.foodConsumption
        }
        return totalConsumption
    }

    var foodProduction: Int {
        var totalProduction = 0
        for asset in assets where asset.foodConsumption < 0 && (asset.action != .construct || asset.currentCommand.assetTarget == nil) {
            totalProduction += -asset.foodConsumption
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
        self.visibilityMap = map.createVisibilityMap()
        self.playerMap = map.createInitializeMap()
        self.assetTypes = PlayerAssetType.duplicateRegistry(changeColorTo: color)
        self.assets = []
        self.upgrades = Array(repeating: false, count: AssetCapabilityType.allValues.count)
        self.gameEvents = []
        self.gold = 0
        self.lumber = 0
        self.gameCycle = 0

        for initialResource in actualMap.resourceInitializationList where initialResource.color == color {
            self.gold = initialResource.gold
            self.lumber = initialResource.lumber
        }

        for initialAsset in actualMap.assetInitializationList where initialAsset.color == color {
            printDebug("Init \(initialAsset.type) \(initialAsset.color) (\(initialAsset.tilePosition.x), \(initialAsset.tilePosition.y))", level: .low)
            let createdAsset = createAsset(initialAsset.type)
            createdAsset.tilePosition = initialAsset.tilePosition
            if PlayerAssetType.findType(initialAsset.type) == .goldMine {
                createdAsset.gold = self.gold
            }
        }
    }

    func incrementCycle() {
        gameCycle += 1
    }

    @discardableResult func incrementGold(by gold: Int) -> Int {
        self.gold += gold
        return self.gold
    }

    @discardableResult func decrementGold(by gold: Int) -> Int {
        self.gold -= gold
        return self.gold
    }

    @discardableResult func incrementLumber(by lumber: Int) -> Int {
        self.lumber += lumber
        return self.lumber
    }

    @discardableResult func decrementLumber(by lumber: Int) -> Int {
        self.lumber -= lumber
        return lumber
    }

    func createMarker(at position: Position, addToMap: Bool) -> PlayerAsset {
        let newMarker = assetTypes["None"]!.construct()
        newMarker.tilePosition = Position.tile(fromAbsolute: position)
        if addToMap {
            playerMap.addAsset(newMarker)
        }
        return newMarker
    }

    func createAsset(_ name: String) -> PlayerAsset {
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
        var assetExistence: [AssetType: Bool] = [:]
        for asset in assets where asset.action != .construct {
            assetExistence[asset.type] = true
        }

        for requirement in assetTypes[name]!.assetRequirements where assetExistence[requirement] == nil {
            if requirement == .keep && assetExistence[.castle] != nil {
                continue
            }
            if requirement == .townHall && (assetExistence[.castle] != nil || assetExistence[.keep] != nil) {
                continue
            }
            return false
        }
        return true
    }

    func updateVisibility() {
        var assetsToBeRemoved: [PlayerAsset] = []
        visibilityMap.update(assets: assets)
        playerMap.updateMap(visibilityMap: visibilityMap, assetDecoratedMap: actualMap)
        for asset in playerMap.assets where asset.type == .none && asset.action == .none {
            asset.incrementStep()
            if asset.step * 2 > PlayerAsset.updateFrequency {
                assetsToBeRemoved.append(asset)
            }
        }
        for asset in assetsToBeRemoved {
            playerMap.removeAsset(asset)
        }
    }

    func selectAssets(in selectArea: Rectangle, assetType: AssetType, selectIdentical: Bool = false) -> [PlayerAsset] {
        var selectedAssets: [PlayerAsset] = []
        if selectArea.width == 0 || selectArea.height == 0 {
            if let bestAsset = selectAsset(at: Position(x: selectArea.x, y: selectArea.y), assetType: assetType) {
                selectedAssets.append(bestAsset)
                if selectIdentical && bestAsset.speed != 0 {
                    for asset in assets where bestAsset !== asset && asset.type == assetType {
                        selectedAssets.append(asset)
                    }
                }
            }
        } else {
            var anyMovable = false
            for asset in assets {
                if selectArea.x <= asset.positionX
                    && asset.positionX < selectArea.x + selectArea.width
                    && selectArea.y <= asset.positionY
                    && asset.positionY < selectArea.y + selectArea.height {
                    if anyMovable {
                        if asset.speed != 0 {
                            selectedAssets.append(asset)
                        }
                    } else {
                        if asset.speed != 0 {
                            selectedAssets.removeAll()
                            selectedAssets.append(asset)
                            anyMovable = true
                        } else if selectedAssets.isEmpty {
                            selectedAssets.append(asset)
                        }
                    }
                }
            }
        }
        return selectedAssets
    }

    func selectAsset(at position: Position, assetType: AssetType) -> PlayerAsset? {
        guard assetType != .none else {
            return nil
        }
        var bestAsset: PlayerAsset?
        var bestDistanceSquared = -1
        for asset in assets where asset.type == assetType {
            let currentDistanceSquared = squaredDistanceBetween(asset.position, position)
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
                let currentDistanceSquared = squaredDistanceBetween(asset.position, position)
                if bestDistanceSquared == -1 || currentDistanceSquared < bestDistanceSquared {
                    bestDistanceSquared = currentDistanceSquared
                    bestAsset = asset
                }
                break
            }
        }
        return bestAsset
    }

    func findNearestAsset(at position: Position, within range: Int) -> PlayerAsset? {
        var bestAsset: PlayerAsset?
        var bestDistanceSquared = -1
        for asset in playerMap.assets {
            let currentDistanceSquared = squaredDistanceBetween(asset.position, position)
            if bestDistanceSquared == -1 || currentDistanceSquared < bestDistanceSquared {
                bestDistanceSquared = currentDistanceSquared
                bestAsset = asset
            }
        }
        return bestDistanceSquared <= range * range ? bestAsset : nil
    }

    func findNearestAsset(at position: Position, assetType: AssetType) -> PlayerAsset? {
        var bestAsset: PlayerAsset?
        var bestDistanceSquared = -1
        for asset in playerMap.assets where asset.type == assetType {
            let currentDistanceSquared = squaredDistanceBetween(asset.position, position)
            if bestDistanceSquared == -1 || currentDistanceSquared < bestDistanceSquared {
                bestDistanceSquared = currentDistanceSquared
                bestAsset = asset
            }
        }
        return bestAsset
    }

    func findNearestEnemy(at position: Position, within inputRange: Int) -> PlayerAsset? {
        var bestAsset: PlayerAsset?
        var bestDistanceSquared = -1
        var range = inputRange
        if range > 0 {
            range = rangeToDistanceSquared(range)
        }

        for asset in playerMap.assets where asset.color != color && asset.color != .none && asset.isAlive {
            let command = asset.currentCommand
            if command.action == .capability, let target = command.assetTarget, target.action == .construct {
                continue
            }
            if ![.conveyGold, .conveyLumber, .mineGold].contains(command.action) {
                let currentDistanceSquared = squaredDistanceBetween(position, asset.closestPosition(position))
                let isOutsideRange = range < 0 || range >= currentDistanceSquared
                if isOutsideRange {
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
        let assetType: PlayerAssetType = assetTypes[PlayerAssetType.findName(assetTypeInput)]!
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
                        let currentDistance: Int = squaredDistanceBetween(builder.tilePosition, tempPosition)
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
                        let currentDistance: Int = squaredDistanceBetween(builder.tilePosition, tempPosition)
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
                        let currentDistance: Int = squaredDistanceBetween(builder.tilePosition, tempPosition)
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
                        let currentDistance: Int = squaredDistanceBetween(builder.tilePosition, tempPosition)
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

    func addUpgrade(_ name: String) {
        let upgrade = PlayerUpgrade.findUpgrade(name) ?? PlayerUpgrade()
        for assetType in upgrade.affectedAssets {
            let assetName = PlayerAssetType.findName(assetType)
            if let assetType = assetTypes[assetName] {
                assetType.addUpgrade(upgrade)
            }
        }
        upgrades[PlayerCapability.findType(name).rawValue] = true
    }

    func hasUpgrade(_ type: AssetCapabilityType) -> Bool {
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
    enum GameError: Error {
        case cannotApplyCapability
        case missingAssetTarget
    }

    private let harvestTime: Int
    private let harvestSteps: Int
    private let mineTime: Int
    private let mineSteps: Int
    private let conveyTime: Int
    private let conveySteps: Int
    private let deathTime: Int
    private let deathSteps: Int
    private let decayTime: Int
    private let decaySteps: Int
    private let lumberPerHarvest: Int
    private let goldPerMining: Int
    private let randomNumberGenerator: RandomNumberGenerator

    private(set) var gameCycle: Int
    private(set) var actualMap: AssetDecoratedMap
    private let routerMap: RouterMap

    private let players: [PlayerData]

    private var assetOccupancyMap: [[PlayerAsset?]]
    private var diagonalOccupancyMap: [[Bool]] = [[]]
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

        let duplicatedMap = AssetDecoratedMap.duplicateMap(at: mapIndex, newColors: newColors)

        actualMap = duplicatedMap
        routerMap = RouterMap()

        players = PlayerColor.allValues.map { playerColor in
            return PlayerData(map: duplicatedMap, color: playerColor)
        }

        assetOccupancyMap = Array(repeating: Array(repeating: nil, count: actualMap.width), count: actualMap.height)
        diagonalOccupancyMap = Array(repeating: Array(repeating: false, count: actualMap.width), count: actualMap.height)

        lumberAvailable = Array(repeating: Array(repeating: 0, count: actualMap.width), count: actualMap.height)
        for row in 0 ..< actualMap.height {
            for column in 0 ..< actualMap.width where actualMap.tileTypeAt(x: column, y: row) == .tree {
                lumberAvailable[row][column] = players[0].lumber
            }
        }
    }

    func isValidAsset(_ playerAsset: PlayerAsset) -> Bool {
        return actualMap.assets.contains { asset in
            return asset === playerAsset
        }
    }

    func player(_ color: PlayerColor) -> PlayerData {
        return players[color.index]
    }

    func timestep() {
        assetOccupancyMap = Array(repeating: Array(repeating: nil, count: assetOccupancyMap[0].count), count: assetOccupancyMap.count)
        diagonalOccupancyMap = Array(repeating: Array(repeating: false, count: diagonalOccupancyMap[0].count), count: diagonalOccupancyMap.count)

        for asset in actualMap.assets where ![.conveyGold, .conveyLumber, .mineGold].contains(asset.action) {
            assetOccupancyMap[asset.tilePositionY][asset.tilePositionX] = asset
        }

        for playerIndex in 1 ..< PlayerColor.allValues.count where players[playerIndex].isAlive {
            players[playerIndex].updateVisibility()
        }

        var currentEvents: [GameEvent] = []
        for asset in actualMap.assets {
            switch asset.action {
            case .none: asset.popCommand()
            case .capability: handleCapabilityEvent(for: asset)
            case .harvestLumber: handleHarvestLumberEvent(for: asset, currentEvents: &currentEvents)
            case .mineGold: handleMineGoldEvent(for: asset)
            case .standGround: handleStandGroundEvent(for: asset)
            case .repair: handleRepairEvent(for: asset)
            case .attack: handleAttackEvent(for: asset, currentEvents: &currentEvents)
            case .conveyLumber, .conveyGold: handleConveyEvent(for: asset)
            case .construct: handleConstructEvent(for: asset)
            case .death: handleDeathEvent(for: asset)
            case .decay: handleDecayEvent(for: asset)
            case .walk: handleWalkEvent(for: asset)
            default: break
            }
        }
        gameCycle += 1
        for playerIndex in 0 ..< PlayerColor.allValues.count {
            players[playerIndex].incrementCycle()
            players[playerIndex].appendGameEvents(currentEvents)
        }
    }

    func clearGameEvents() {
        for player in players {
            player.clearGameEvents()
        }
    }

    private func handleCapabilityEvent(for asset: PlayerAsset) {
        let command = asset.currentCommand
        if let activatedCapability = command.activatedCapability {
            activatedCapability.incrementStep()
        } else {
            let capability = PlayerCapability.findCapability(command.capability!)
            asset.popCommand()
            let target = command.assetTarget!
            if capability.canApply(actor: asset, playerData: players[asset.color.index], target: target) {
                capability.applyCapability(actor: asset, playerData: players[asset.color.index], target: target)
            } else {
                printError("Cannot apply capability.")
            }
        }
    }

    private func handleHarvestLumberEvent(for asset: PlayerAsset, currentEvents: inout [GameEvent]) {
        var command = asset.currentCommand
        let target = command.assetTarget!
        var tilePosition = target.tilePosition
        var harvestDirection = asset.tilePosition.directionToAdjacentTile(searchingFrom: tilePosition)

        if actualMap.tileTypeAt(position: tilePosition) != .tree {
            harvestDirection = .max
            tilePosition = asset.tilePosition
        }
        if harvestDirection == .max {
            if tilePosition == asset.tilePosition {
                let newPosition = players[asset.color.index].playerMap.findNearestReachableTileType(at: tilePosition, type: .tree)
                asset.popCommand()
                if newPosition.x >= 0 {
                    command.assetTarget = self.players[asset.color.index].createMarker(at: Position.absolute(fromTile: newPosition), addToMap: false)
                    asset.pushCommand(command)
                    command.action = .walk
                    asset.pushCommand(command)
                    asset.resetStep()
                }
            } else {
                var newCommand = command
                newCommand.action = .walk
                asset.pushCommand(newCommand)
                asset.resetStep()
            }
        } else {
            let tempEvent = GameEvent(type: .harvest, asset: asset)
            currentEvents.append(tempEvent)
            asset.direction = harvestDirection
            asset.incrementStep()
            if harvestSteps <= asset.step {
                let nearestRepository = players[asset.color.index].findNearestOwnedAsset(at: asset.position, assetTypes: [.townHall, .keep, .castle, .lumberMill])
                lumberAvailable[tilePosition.y][tilePosition.x] -= lumberPerHarvest

                GameSound.current.play(.tree)

                if lumberAvailable[tilePosition.y][tilePosition.x] <= 0 {
                    actualMap.changeTileType(at: tilePosition, to: .stump)
                }
                if nearestRepository != nil {
                    command.action = .conveyLumber
                    command.assetTarget = nearestRepository
                    asset.pushCommand(command)
                    command.action = .walk
                    asset.pushCommand(command)
                    asset.lumber = lumberPerHarvest
                    asset.resetStep()
                } else {
                    asset.popCommand()
                    asset.lumber = lumberPerHarvest
                    asset.resetStep()
                }
            }
        }
    }

    private func handleMineGoldEvent(for asset: PlayerAsset) {
        var command = asset.currentCommand
        let target = command.assetTarget!
        let closestPosition = target.closestPosition(asset.position)
        let tilePosition = Position.tile(fromAbsolute: closestPosition)
        let mineDirection = asset.tilePosition.directionToAdjacentTile(searchingFrom: tilePosition)
        if mineDirection == .max && tilePosition != asset.tilePosition {
            var newCommand = command
            newCommand.action = .walk
            asset.pushCommand(newCommand)
            asset.resetStep()
        } else {
            if asset.step == 0 {
                if (target.commandCount + 1) * goldPerMining <= target.gold {
                    let newCommand = AssetCommand(action: .build, capability: .none, assetTarget: asset, activatedCapability: nil)
                    target.enqueueCommand(newCommand)
                    asset.incrementStep()
                    asset.tilePosition = target.tilePosition
                } else {
                    asset.popCommand()
                }
            } else {
                asset.incrementStep()
                if mineSteps <= asset.step {
                    let oldTarget = target
                    let nearestRepository = players[asset.color.index].findNearestOwnedAsset(at: asset.position, assetTypes: [.townHall, .keep, .castle])
                    var nextTarget = Position(x: players[asset.color.index].playerMap.width - 1, y: players[asset.color.index].playerMap.height - 1)

                    target.decrementGold(goldPerMining)

                    GameSound.current.play(.goldMine)

                    target.popCommand()
                    if target.gold <= 0 {
                        let newCommand = AssetCommand(action: .death, capability: .none, assetTarget: nil, activatedCapability: nil)
                        target.clearCommand()
                        target.pushCommand(newCommand)
                        target.resetStep()
                    }
                    asset.gold = goldPerMining
                    if nearestRepository != nil {
                        command.action = .conveyGold
                        command.assetTarget = nearestRepository
                        asset.pushCommand(command)
                        command.action = .walk
                        asset.pushCommand(command)
                        asset.resetStep()
                        nextTarget = command.assetTarget!.tilePosition
                    } else {
                        asset.popCommand()
                    }
                    asset.tilePosition = players[asset.color.index].playerMap.findAssetPlacement(placeAsset: asset, fromAsset: oldTarget, nextTileTarget: nextTarget)
                }
            }
        }
    }

    private func handleStandGroundEvent(for asset: PlayerAsset) {
        var command = asset.currentCommand
        if let newTarget = players[asset.color.index].findNearestEnemy(at: asset.position, within: asset.effectiveRange) {
            command.action = .attack
            command.assetTarget = newTarget
        } else {
            command.action = .none
        }
        asset.pushCommand(command)
        asset.resetStep()
    }

    private func handleRepairEvent(for asset: PlayerAsset) {
        var currentCommand = asset.currentCommand
        let currentTarget = currentCommand.assetTarget!
        if currentTarget.isAlive {
            let repairDirection = asset.tilePosition.directionToAdjacentTile(searchingFrom: currentTarget.tilePosition, areaLength: currentTarget.size)
            if repairDirection == .max {
                currentCommand.action = .walk
                asset.pushCommand(currentCommand)
                asset.resetStep()
            } else {
                asset.direction = repairDirection
                asset.incrementStep()
                if asset.step == asset.attackSteps {
                    if players[asset.color.index].gold != 0 && players[asset.color.index].lumber != 0 {
                        var repairPoints = currentTarget.maxHitPoints * (asset.attackSteps + asset.reloadSteps) / PlayerAsset.updateFrequency * currentTarget.buildTime
                        if repairPoints == 0 {
                            repairPoints = 1
                        }
                        players[asset.color.index].decrementGold(by: 1)
                        players[asset.color.index].decrementLumber(by: 1)
                        currentTarget.incrementHitPoints(repairPoints)
                        if currentTarget.hitPoints == currentTarget.maxHitPoints {
                            let tempEvent = GameEvent(type: .workComplete, asset: asset)
                            players[asset.color.index].addGameEvent(tempEvent)
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
    }

    private func handleAttackEvent(for asset: PlayerAsset, currentEvents: inout [GameEvent]) {
        var currentCommand = asset.currentCommand
        if asset.type == .none {
            let closestTargetPosition = currentCommand.assetTarget!.closestPosition(asset.position)
            var deltaPosition = Position(x: closestTargetPosition.x - asset.positionX, y: closestTargetPosition.y - asset.positionY)

            let movement = Position.tileWidth * 5 / PlayerAsset.updateFrequency
            let targetDistance = distanceBetween(asset.position, closestTargetPosition)
            let divisor = (targetDistance + movement - 1) / movement

            if divisor != 0 {
                deltaPosition = Position(x: deltaPosition.x / divisor, y: deltaPosition.y / divisor)
            }
            asset.position = Position(x: asset.positionX + deltaPosition.x, y: asset.positionY + deltaPosition.y)
            asset.direction = asset.position.directionTo(closestTargetPosition)

            if Position.halfTileWidth * Position.halfTileHeight > squaredDistanceBetween(asset.position, closestTargetPosition) {
                let tempEvent = GameEvent(type: .missleHit, asset: asset)
                currentEvents.append(tempEvent)

                if currentCommand.assetTarget!.isAlive {
                    let targetCommand = currentCommand.assetTarget!.currentCommand
                    let tempEvent = GameEvent(type: .attacked, asset: currentCommand.assetTarget!)
                    players[currentCommand.assetTarget!.color.index].addGameEvent(tempEvent)
                    if targetCommand.action != .mineGold {
                        if [.conveyGold, .conveyLumber].contains(targetCommand.action) {
                            currentCommand.assetTarget = targetCommand.assetTarget
                        } else if targetCommand.action == .capability && targetCommand.assetTarget != nil {
                            if currentCommand.assetTarget!.speed != 0 && targetCommand.assetTarget!.action != .construct {
                                currentCommand.assetTarget = targetCommand.assetTarget
                            }
                        }
                        currentCommand.assetTarget!.decrementHitPoints(asset.hitPoints)
                        if currentCommand.assetTarget!.isAlive == false {
                            var command = currentCommand.assetTarget!.currentCommand
                            let tempEvent = GameEvent(type: .death, asset: currentCommand.assetTarget!)
                            currentEvents.append(tempEvent)

                            if let target = command.assetTarget, command.action == .capability {
                                if target.action == .construct {
                                    players[target.color.index].deleteAsset(target)
                                }
                            } else if command.action == .construct {
                                if let target = command.assetTarget {
                                    target.clearCommand()
                                }
                            }
                            currentCommand.assetTarget!.direction = asset.direction.opposite
                            command.action = .death
                            currentCommand.assetTarget!.clearCommand()
                            currentCommand.assetTarget!.pushCommand(command)
                            currentCommand.assetTarget!.resetStep()
                        }
                    }
                }
                players[asset.color.index].deleteAsset(asset)
            }
        } else if currentCommand.assetTarget!.isAlive {
            if asset.effectiveRange == 1 {
                let attackDirection = asset.tilePosition.directionToAdjacentTile(searchingFrom: currentCommand.assetTarget!.tilePosition, areaLength: currentCommand.assetTarget!.size)
                if attackDirection == .max {
                    let nextCommand = asset.nextCommand
                    if nextCommand.action != .standGround {
                        currentCommand.action = .walk
                        asset.pushCommand(currentCommand)
                        asset.resetStep()
                    } else {
                        asset.popCommand()
                    }
                } else {
                    asset.direction = attackDirection
                    asset.incrementStep()
                    if asset.step == asset.attackSteps {
                        var damage = asset.effectiveBasicDamage - currentCommand.assetTarget!.effectiveArmor
                        damage = damage < 0 ? 0 : damage
                        damage += asset.effectivePiercingDamage
                        if Int(randomNumberGenerator.random()) & 0x1 != 0 {
                            damage /= 2
                        }
                        currentCommand.assetTarget!.decrementHitPoints(damage)
                        var tempEvent = GameEvent(type: .missleHit, asset: asset)

                        currentEvents.append(tempEvent)
                        tempEvent = GameEvent(type: .attacked, asset: currentCommand.assetTarget!)
                        players[currentCommand.assetTarget!.color.index].addGameEvent(tempEvent)
                        if currentCommand.assetTarget!.isAlive == false {
                            var command = currentCommand.assetTarget!.currentCommand
                            tempEvent = GameEvent(type: .death, asset: currentCommand.assetTarget!)
                            currentEvents.append(tempEvent)
                            if let target = command.assetTarget, command.action == .capability {
                                if target.action == .construct {
                                    players[target.color.index].deleteAsset(target)
                                }
                            } else if command.action == .construct {
                                if let target = command.assetTarget {
                                    target.clearCommand()
                                }
                            }
                            command.capability = .none
                            command.assetTarget = nil
                            command.activatedCapability = nil
                            currentCommand.assetTarget!.direction = attackDirection.opposite
                            command.action = .death
                            currentCommand.assetTarget!.clearCommand()
                            currentCommand.assetTarget!.pushCommand(command)
                            currentCommand.assetTarget!.resetStep()
                        }
                    }
                    if asset.step >= asset.attackSteps + asset.reloadSteps {
                        asset.resetStep()
                    }
                }
            } else {
                let closestTargetPosition = currentCommand.assetTarget!.closestPosition(asset.position)
                if squaredDistanceBetween(asset.position, closestTargetPosition) > rangeToDistanceSquared(asset.effectiveRange) {
                    let nextCommand = asset.nextCommand
                    if nextCommand.action != .standGround {
                        currentCommand.action = .walk
                        asset.pushCommand(currentCommand)
                        asset.resetStep()
                    } else {
                        asset.popCommand()
                    }
                } else {
                    let attackDirection = asset.position.directionTo(closestTargetPosition)
                    asset.direction = attackDirection
                    asset.incrementStep()
                    if asset.step == asset.attackSteps {
                        let arrowAsset = players[PlayerColor.none.index].createAsset("None")
                        var damage = asset.effectiveBasicDamage - currentCommand.assetTarget!.effectiveArmor
                        damage = damage < 0 ? 0 : damage
                        damage += asset.effectivePiercingDamage
                        if Int(randomNumberGenerator.random()) & 0x1 != 0 {
                            damage /= 2
                        }
                        let tempEvent = GameEvent(type: .missleFire, asset: asset)
                        currentEvents.append(tempEvent)

                        arrowAsset.hitPoints = damage
                        arrowAsset.position = asset.position
                        if arrowAsset.positionX < closestTargetPosition.x {
                            arrowAsset.position.x = arrowAsset.positionX + Position.halfTileWidth
                        } else if arrowAsset.positionX > closestTargetPosition.x {
                            arrowAsset.position.x = arrowAsset.positionX - Position.halfTileWidth
                        }

                        if arrowAsset.positionY < closestTargetPosition.y {
                            arrowAsset.position.y = arrowAsset.positionY + Position.halfTileHeight
                        } else if arrowAsset.positionY > closestTargetPosition.y {
                            arrowAsset.position.y = arrowAsset.positionY - Position.halfTileHeight
                        }
                        arrowAsset.direction = attackDirection
                        var attackCommand = AssetCommand(action: .construct, capability: .none, assetTarget: asset, activatedCapability: nil)
                        arrowAsset.pushCommand(attackCommand)
                        attackCommand.action = .attack
                        attackCommand.assetTarget = currentCommand.assetTarget

                        arrowAsset.pushCommand(attackCommand)
                    }
                    if asset.step >= asset.attackSteps + asset.reloadSteps {
                        asset.resetStep()
                    }
                }
            }
        } else {
            let nextCommand = asset.nextCommand
            asset.popCommand()
            if nextCommand.action != .standGround {
                if let newTarget = players[asset.color.index].findNearestEnemy(at: asset.position, within: asset.effectiveSight) {
                    currentCommand.assetTarget = newTarget
                    asset.pushCommand(currentCommand)
                    asset.resetStep()
                }
            }
        }
    }

    private func handleConveyEvent(for asset: PlayerAsset) {
        asset.incrementStep()
        if conveySteps <= asset.step {
            let command = asset.currentCommand
            var nextTarget = Position(x: players[asset.color.index].playerMap.width - 1, y: players[asset.color.index].playerMap.height - 1)
            players[asset.color.index].incrementGold(by: asset.gold)
            players[asset.color.index].incrementLumber(by: asset.lumber)
            asset.gold = 0
            asset.lumber = 0
            asset.popCommand()
            asset.resetStep()
            if asset.action != .none {
                nextTarget = asset.currentCommand.assetTarget!.tilePosition
            }
            asset.tilePosition = players[asset.color.index].playerMap.findAssetPlacement(placeAsset: asset, fromAsset: command.assetTarget!, nextTileTarget: nextTarget)
        }
    }

    private func handleConstructEvent(for asset: PlayerAsset) {
        let command = asset.currentCommand
        if let activatedCapability = command.activatedCapability {
            activatedCapability.incrementStep()
        }
    }

    private func handleDeathEvent(for asset: PlayerAsset) {
        asset.incrementStep()
        if asset.step > deathSteps {
            if asset.speed != 0 {
                let corpseAsset = players[PlayerColor.none.index].createAsset("None")
                let decayCommand = AssetCommand(action: .decay, capability: .none, assetTarget: nil, activatedCapability: nil)
                corpseAsset.position = asset.position
                corpseAsset.direction = asset.direction
                corpseAsset.pushCommand(decayCommand)
            }
            players[asset.color.index].deleteAsset(asset)
        }
    }

    private func handleDecayEvent(for asset: PlayerAsset) {
        asset.incrementStep()
        if asset.step > decaySteps {
            players[asset.color.index].deleteAsset(asset)
        }
    }

    private func handleWalkEvent(for asset: PlayerAsset) {
        if asset.tileAligned {
            var command = asset.currentCommand
            let nextCommand = asset.nextCommand
            let mapTarget = command.assetTarget!.closestPosition(asset.position)

            if nextCommand.action == .attack && squaredDistanceBetween(asset.position, nextCommand.assetTarget!.closestPosition(asset.position)) <= rangeToDistanceSquared(asset.effectiveRange) {
                asset.popCommand()
                asset.resetStep()
                return
            }

            let travelDirection = routerMap.findRoute(assetMap: players[asset.color.index].playerMap, asset: asset, target: mapTarget)
            if travelDirection != .max {
                asset.direction = travelDirection
            } else {
                let tilePosition = Position.tile(fromAbsolute: mapTarget)
                if tilePosition == asset.tilePosition || asset.tilePosition.directionToAdjacentTile(searchingFrom: tilePosition) != .max {
                    asset.popCommand()
                    asset.resetStep()
                    return
                } else if nextCommand.action == .harvestLumber {
                    let newPosition = players[asset.color.index].playerMap.findNearestReachableTileType(at: asset.tilePosition, type: .tree)
                    asset.popCommand()
                    asset.popCommand()
                    if newPosition.x >= 0 {
                        command.action = .harvestLumber
                        command.assetTarget = players[asset.color.index].createMarker(at: Position.absolute(fromTile: newPosition), addToMap: false)
                        asset.pushCommand(command)
                        command.action = .walk
                        asset.pushCommand(command)
                        asset.resetStep()
                        return
                    }
                } else {
                    command.action = .none
                    asset.pushCommand(command)
                    asset.resetStep()
                    return
                }
            }
        }
        if !asset.moveStep(occupancyMap: &assetOccupancyMap, diagonals: &diagonalOccupancyMap) {
            asset.direction = asset.position.tileOctant.opposite
        }
    }
}
