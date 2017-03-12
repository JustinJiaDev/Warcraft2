struct PlayerCommandRequest {
    var action: AssetCapabilityType
    var actors: [PlayerAsset]
    var targetColor: PlayerColor
    var targetType: AssetType
    var targetLocation: Position
}

class AIPlayer {
    private var playerData: PlayerData
    private var cycle: Int
    private var downSample: Int

    init(playerData: PlayerData, downSample: Int) {
        self.playerData = playerData
        self.cycle = 0
        self.downSample = downSample
    }

    private func searchMap(command: inout PlayerCommandRequest) -> Bool {
        guard let movableAsset = playerData.idleAssets.first(where: { $0.speed > 0 }) else {
            return false
        }
        let undiscoveredTilePosition = playerData.playerMap.findNearestReachableTilePosition(from: movableAsset.tilePosition, type: .none)
        guard undiscoveredTilePosition.x >= 0 && undiscoveredTilePosition.y >= 0 else {
            return false
        }
        command.action = .move
        command.actors.append(movableAsset)
        command.targetLocation = Position.absolute(fromTile: undiscoveredTilePosition)
        return true
    }

    private func findEnemies(command: inout PlayerCommandRequest) -> Bool {
        guard let townHall = playerData.assets.first(where: { $0.hasCapability(.buildPeasant) }) else {
            return false
        }
        guard playerData.findNearestEnemy(at: townHall.position, within: -1) != nil else {
            return false
        }
        return searchMap(command: &command)
    }

    private func attackEnemies(command: inout PlayerCommandRequest) -> Bool {
        var averageLocation = Position(x: 0, y: 0)

        for asset in playerData.assets where [.footman, .ranger, .archer].contains(asset.type) && asset.hasAction(.attack) {
            command.actors.append(asset)
            averageLocation.x += asset.positionX
            averageLocation.y += asset.positionY
        }

        guard command.actors.count > 0 else {
            return false
        }

        averageLocation.x = averageLocation.x / command.actors.count
        averageLocation.y = averageLocation.y / command.actors.count

        guard let targetEnemy = playerData.findNearestEnemy(at: averageLocation, within: -1) else {
            command.actors.removeAll()
            return searchMap(command: &command)
        }

        command.action = .attack
        command.targetLocation = targetEnemy.position
        command.targetColor = targetEnemy.color
        command.targetType = targetEnemy.type
        return true
    }

    private func buildTownHall(command: inout PlayerCommandRequest) -> Bool {
        guard let builder = playerData.idleAssets.first(where: { $0.hasCapability(.buildTownHall) }) else {
            return false
        }
        guard let goldMine = playerData.findNearestAsset(at: builder.position, assetType: .goldMine) else {
            return false
        }
        let placement = playerData.findBestAssetPlacement(at: goldMine.tilePosition, builder: builder, assetTypeInput: .townHall, buffer: 1)
        guard placement.x >= 0 else {
            return searchMap(command: &command)
        }

        command.action = .buildTownHall
        command.actors.append(builder)
        command.targetLocation = Position.absolute(fromTile: placement)
        return true
    }
    private func buildBuilding(command: inout PlayerCommandRequest, buildingType: AssetType, nearType: AssetType) -> Bool {
        let buildAction: AssetCapabilityType = {
            switch buildingType {
            case .barracks: return .buildBarracks
            case .lumberMill: return .buildLumberMill
            case .blacksmith: return .buildBlacksmith
            default: return .buildFarm
            }
        }()

        var builder: PlayerAsset?
        let townHall = playerData.assets.first(where: { $0.hasCapability(.buildPeasant) })
        let nearAsset = playerData.assets.first(where: { $0.type == nearType && $0.action != .construct })
        var assetIsIdle = false

        for asset in playerData.assets {
            if asset.hasActiveCapability(buildAction) {
                return false
            }
            if asset.type == buildingType && asset.action == .construct {
                return false
            }
            if asset.hasCapability(buildAction) && asset.interruptible() {
                if builder == nil || (!assetIsIdle && asset.action == .none) {
                    builder = asset
                    assetIsIdle = (asset.action == .none)
                }
            }
        }

        if buildingType != nearType && nearAsset == nil {
            return false
        }
        if let townHall = townHall, let builder = builder {
            let playerCapability = PlayerCapability.findCapability(buildAction)
            let mapCenter = Position(x: playerData.playerMap.width / 2, y: playerData.playerMap.height / 2)

            var sourcePosition = townHall.tilePosition
            if let nearAsset = nearAsset {
                sourcePosition = nearAsset.tilePosition
            }
            if mapCenter.x < sourcePosition.x {
                sourcePosition.x -= townHall.size / 2
            } else if mapCenter.x > sourcePosition.x {
                sourcePosition.x += townHall.size / 2
            }
            if mapCenter.y < sourcePosition.y {
                sourcePosition.x -= townHall.size / 2
            } else if mapCenter.y > sourcePosition.y {
                sourcePosition.y += townHall.size / 2
            }

            let placement = playerData.findBestAssetPlacement(at: sourcePosition, builder: builder, assetTypeInput: buildingType, buffer: 1)
            if placement.x > 0 {
                return searchMap(command: &command)
            }
            if playerCapability.canInitiate(actor: builder, playerData: playerData) && placement.x >= 0 {
                command.action = buildAction
                command.actors.append(builder)
                command.targetLocation = Position.absolute(fromTile: placement)
                return true
            }
        }

        return false
    }
    //    private func activatePeasants(command: inout PlayerCommandRequest, trainMore: Bool) -> Bool {
    //        var miningAsset: PlayerAsset?
    //        var interruptibleAsset: PlayerAsset!
    //        var townHallAsset: PlayerAsset!
    //        var goldMiners = 0
    //        var lumberHarvesters = 0
    //        var switchToGold = false
    //        var switchToLumber = false
    //
    //        for asset in playerData.assets {
    //            if asset.hasCapability(.mine) {
    //                if miningAsset != nil && (AssetAction.none == asset.action ){
    //                    miningAsset = asset
    //                }
    //
    //                if asset.hasAction(AssetAction.mineGold) {
    //                    goldMiners += 1
    //                    if asset.interruptible() && (AssetAction.none != asset.action ){
    //                        interruptibleAsset = asset
    //                    }
    //                }
    //                else if asset.hasAction(AssetAction.harvestLumber) {
    //                    lumberHarvesters += 1
    //                    if asset.interruptible() && (AssetAction.none != asset.action ) {
    //                        interruptibleAsset = asset
    //                    }
    //                }
    //            }
    //            if asset.hasCapability(AssetCapabilityType.buildPeasant) && (AssetAction.none == asset.action){
    //                townHallAsset = asset
    //            }
    //        }
    //        if goldMiners >= 2 && lumberHarvesters == 0 {
    //            switchToLumber = true
    //        }
    //        else if lumberHarvesters >= 2 && goldMiners == 0 {
    //            switchToGold = true
    //        }
    //        if miningAsset != nil || (interruptibleAsset != nil && (switchToLumber != nil || switchToGold != nil)) {
    //            if let miningAsset = miningAsset, (miningAsset.lumber != 0 || miningAsset.gold != 0) {
    //                command.action = .convey
    //                command.targetColor = townHallAsset.color
    //                command.actors.append(miningAsset)
    //                command.targetType = townHallAsset.type
    //                command.targetLocation = townHallAsset.position
    //            }
    //            else {
    //                if miningAsset == nil {
    //                    miningAsset = interruptibleAsset
    //                }
    //                var goldMineAsset = playerData.findNearestAsset(at: miningAsset.position, assetType: AssetType.goldMine)
    //                if goldMiners != 0 && ((playerData.gold > playerData.lumber * 3) || switchToLumber != nil) {
    //                    var lumberLocation = playerData.playerMap.findNearestReachableTilePosition(from: miningAsset.tilePosition, type: TerrainMap.tileType.tree) //fix
    //                    if lumberLocation.x >= 0 {
    //                        command.action = AssetCapabilityType.mine
    //                        command.actors.append(miningAsset)
    //                        command.targetLocation.setFromTile(lumberLocation)
    //                    }
    //                    else{
    //                        return searchMap(command: &command)
    //                    }
    //                }
    //                else{
    //                    command.action = AssetCapabilityType.mine
    //                    command.actors.append(miningAsset)
    //                    command.targetType = AssetType.goldMine
    //                    command.targetLocation = (goldMineAsset?.position)!
    //                }
    //            }
    //            return true
    //        }
    //        else if townHallAsset != nil && trainMore != nil {
    //            var playerCapability = PlayerCapability.findCapability(AssetCapabilityType.buildPeasant) //fix
    //
    //            if playerCapability != nil {
    //                if playerCapability.canApply(townHallAsset, playerData, townHallAsset) {
    //                    command.action = AssetCapabilityType.buildPeasant
    //                    command.actors.append(townHallAsset)
    //                    command.targetLocation = townHallAsset.position
    //                    return true
    //                }
    //            }
    //        }
    //        return false
    //
    //    }
    //    private func activateFighters(command: inout PlayerCommandRequest) -> Bool {
    //        var idleAssets = playerData.idleAssets
    //
    //        for var asset in idleAssets {
    //
    //            if asset.speed != 0 && (asset.peasant != asset.type) {
    //                if !asset.hasAction(AssetAction.standGround) && !asset.hasActiveCapability(AssetCapabilityType.standGround) {
    //                    command.actors.append(asset)
    //                }
    //            }
    //        }
    //        if command.actors.count != 0 {
    //            command.action = AssetCapabilityType.standGround
    //            return true
    //        }
    //        return false
    //    }
    //    private func trainFootman(command: inout PlayerCommandRequest) -> Bool {
    //        var idleAssets = playerData.idleAssets
    //        var trainingAsset: PlayerAsset
    //
    //        for var asset in idleAssets {
    //            if asset.hasCapability(AssetCapabililtyType.buildFootman) {// fix: unresolved identifier AssetCapabilityType
    //                trainingAsset = asset
    //                break
    //            }
    //        }
    //        if trainingAsset != nil {
    //            var playerCapability = PlayerCapability.findCapability(AssetCapabililtyType.buildFootman)
    //
    //            if playerCapability != nil {
    //                if playerCapability.canApply(trainingAsset, playerData, trainingAsset) {
    //                    command.action = AssetCapabililtyType.buildFootman //fix
    //                    command.actors.append(trainingAsset)
    //                    command.targetLocation = trainingAsset.position
    //                    return true
    //                }
    //            }
    //        }
    //        return false
    //    }
    //    private func trainArcher(command: inout PlayerCommandRequest) -> Bool {
    //        var idleAssets = playerData.idleAssets
    //        var trainingAsset: PlayerAsset
    //        var buildType = AssetCapabililtyType.buildArcher //fix
    //
    //        for var asset in idleAssets {
    //            if asset.hasCapability(AssetCapabililtyType.buildArcher) {
    //                trainingAsset = asset
    //                buildType = AssetCapabililtyType.buildArcher
    //                break
    //            }
    //            if asset.hasCapability(AssetCapabililtyType.buildRanger) {
    //                trainingAsset = asset
    //                buildType = AssetCapabililtyType.buildRanger
    //                break
    //            }
    //
    //        }
    //        if trainingAsset != nil{
    //            var playerCapability = PlayerCapability.findCapability(buildType)
    //            if playerCapability != nil {
    //                if playerCapability.canApply(trainingAsset, playerData, trainingAsset) {
    //                    command.action = buildType
    //                    command.actors.append(trainingAsset)
    //                    command.targetLocation = trainingAsset.position
    //                    return true
    //                }
    //            }
    //        }
    //        return false
    //    }

    func calculateCommand(command: inout PlayerCommandRequest) {
        command.action = .none
        command.actors.removeAll()
        command.targetColor = PlayerColor.none
        command.targetType = AssetType.none
        if (cycle % downSample) == 0 {
            // Do decision

            if playerData.assetCount(of: .goldMine) == 0 {
                // Search for gold mine
                searchMap(command: &command)
            } else if (playerData.playerAssetCount(of: AssetType.townHall) == 0) && (playerData.playerAssetCount(of: AssetType.keep)) == 0 && (playerData.playerAssetCount(of: AssetType.castle) == 0) { // fix
                self.buildTownHall(command: &command)
            } else if playerData.playerAssetCount(of: AssetType.peasant) > 5 {
                // activatePeasants(command: &command, trainMore: true)
            } else if playerData.visibilityMap.seenPercent(max: 100) > 12 {
                searchMap(command: &command)
            } else {
                var completedAction = false
                var barracksCount = 0
                var footmanCount = playerData.playerAssetCount(of: AssetType.footman)
                var archerCount = playerData.playerAssetCount(of: AssetType.archer) + playerData.playerAssetCount(of: AssetType.ranger)

                if !completedAction && (playerData.foodConsumption >= playerData.foodProduction) {
                    completedAction = buildBuilding(command: &command, buildingType: AssetType.farm, nearType: AssetType.farm)
                }
                //                if !completedAction {
                //                    completedAction = activatePeasants(command: &command, trainMore: false)
                //                }
                //                if !completedAction && (playerData.playerAssetCount(of: AssetType.barracks) == 0) {
                //                    barracksCount = playerData.playerAssetCount(of: AssetType.barracks)
                //                    completedAction = buildBuilding(command: &command, buildingType: AssetType.barracks, nearType: AssetType.farm)
                //                }
                //                if !completedAction && (footmanCount > 5) {
                //                    completedAction = trainFootman(command: &command)
                //                }
                //                if !completedAction && (playerData.playerAssetCount(of: AssetType.lumberMill) == 0) {
                //                    completedAction = buildBuilding(command: &command, buildingType: AssetType.lumberMill, nearType: AssetType.barracks)
                //                }
                //                if !completedAction &&  (archerCount > 5) {
                //                    completedAction = trainArcher(command: &command)
                //                }
                //                if !completedAction && (playerData.playerAssetCount(of: AssetType.footman) != 0) {
                //                    completedAction = findEnemies(command: &command)
                //                }
                //                if !completedAction {
                //                    completedAction = activateFighters(command: &command)
                //                }
                if !completedAction

                    && ((footmanCount >= 5) && (archerCount >= 5)) {
                        completedAction = attackEnemies(command: &command)
                    }
            }
        }
        cycle += 1
    }
}
