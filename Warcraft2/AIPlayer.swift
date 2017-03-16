class AIPlayer {
    private(set) var playerData: PlayerData
    private(set) var downSample: Int
    private(set) var aiLevel: Int
    private(set) var cycle: Int

    static var level: Int = 0

    private var action: AssetCapabilityType?
    private var actor: PlayerAsset?
    private var target: PlayerAsset?

    init(playerData: PlayerData, downSample: Int, aiLevel: Int) {
        self.playerData = playerData
        self.downSample = downSample
        self.aiLevel = aiLevel
        self.cycle = 0
    }

    @discardableResult private func searchMap() -> Bool {
        guard let movableAsset = playerData.idleAssets.first(where: { $0.speed > 0 && $0.isInterruptible }) else {
            return false
        }
        let undiscoveredTilePosition = playerData.playerMap.findNearestReachableTilePosition(from: movableAsset.tilePosition, type: .none)
        guard undiscoveredTilePosition.x >= 0 && undiscoveredTilePosition.y >= 0 else {
            return false
        }
        action = .move
        actor = movableAsset
        target = playerData.createMarker(at: Position.absolute(fromTile: undiscoveredTilePosition), addToMap: false)
        return true
    }

    @discardableResult private func findEnemies() -> Bool {
        guard let townHall = playerData.assets.first(where: { $0.hasCapability(.buildPeasant) }) else {
            return false
        }
        guard playerData.findNearestEnemy(at: townHall.position, within: -1) != nil else {
            return false
        }
        return searchMap()
    }

    @discardableResult private func attackEnemies() -> Bool {
        guard let fighter = playerData.idleAssets.first(where: { $0.type != .peasant && $0.isInterruptible }) else {
            return false
        }
        guard let enemy = playerData.findNearestEnemy(at: fighter.position, within: -1) else {
            return searchMap()
        }
        action = .attack
        actor = fighter
        target = enemy
        return true
    }

    @discardableResult private func buildTownHall() -> Bool {
        guard let builder = playerData.idleAssets.first(where: { $0.hasCapability(.buildTownHall) && $0.isInterruptible }) else {
            return false
        }
        guard let goldMine = playerData.findNearestAsset(at: builder.position, assetType: .goldMine) else {
            return false
        }
        let placementTilePosition = playerData.findBestAssetPlacementTilePosition(from: goldMine.tilePosition, builder: builder, assetType: .townHall, buffer: 1)
        guard placementTilePosition.x >= 0 && placementTilePosition.y >= 0 else {
            return searchMap()
        }
        action = .buildTownHall
        actor = builder
        target = playerData.createMarker(at: Position.absolute(fromTile: placementTilePosition), addToMap: false)
        return true
    }

    @discardableResult private func buildBuilding(buildingType: AssetType, nearType: AssetType) -> Bool {
        let buildAction: AssetCapabilityType = {
            switch buildingType {
            case .barracks: return .buildBarracks
            case .lumberMill: return .buildLumberMill
            case .blacksmith: return .buildBlacksmith
            default: return .buildFarm
            }
        }()
        guard let builder = playerData.idleAssets.first(where: { $0.hasCapability(buildAction) && $0.isInterruptible }) else {
            return false
        }
        guard let townHall = playerData.assets.first(where: { $0.hasCapability(.buildPeasant) }) else {
            return false
        }
        let nearAsset = playerData.assets.first(where: { $0.type == nearType && $0.action != .construct })
        let sourceTilePosition = nearAsset?.tilePosition ?? townHall.tilePosition
        let placementTilePosition = playerData.findBestAssetPlacementTilePosition(from: sourceTilePosition, builder: builder, assetType: buildingType, buffer: 1)
        guard placementTilePosition.x >= 0 && placementTilePosition.y >= 0 else {
            return searchMap()
        }
        action = buildAction
        actor = builder
        target = playerData.createMarker(at: Position.absolute(fromTile: placementTilePosition), addToMap: false)
        return true
    }

    @discardableResult private func activatePeasant() -> Bool {
        let miningAsset = playerData.idleAssets.first(where: { $0.hasCapability(.mine) })
        let interruptibleAsset = playerData.assets.first(where: { $0.hasCapability(.mine) && $0.isInterruptible && $0.action != .none })
        let goldMiners = playerData.assets.filter({ $0.hasAction(.mineGold) }).count
        let lumberHarvesters = playerData.assets.filter({ $0.hasAction(.harvestLumber) }).count
        let switchToGold = lumberHarvesters >= 2 && goldMiners == 0
        let switchToLumber = goldMiners >= 2 && lumberHarvesters == 0
        guard let townhall = playerData.idleAssets.first(where: { $0.hasCapability(.buildPeasant) }) else {
            return false
        }
        guard miningAsset != nil || (interruptibleAsset != nil && (switchToLumber || switchToGold)) else {
            return false
        }
        if let miningAsset = miningAsset, (miningAsset.lumber > 0 || miningAsset.gold > 0) {
            action = .convey
            actor = miningAsset
            target = townhall
        } else {
            let miningAsset = (miningAsset ?? interruptibleAsset)!
            if goldMiners > 0 && (playerData.gold > playerData.lumber * 3 || switchToLumber) {
                let lumberTileLocation = playerData.playerMap.findNearestReachableTilePosition(from: townhall.tilePosition, type: .tree)
                guard lumberTileLocation.x >= 0 && lumberTileLocation.y >= 0 else {
                    return searchMap()
                }
                action = .mine
                actor = miningAsset
                // FIXME: The peasant (maybe under some condition) can't go to the target location and collect lumber.
                target = playerData.createMarker(at: Position.absolute(fromTile: lumberTileLocation), addToMap: false)
            } else {
                action = .mine
                actor = miningAsset
                target = playerData.findNearestAsset(at: miningAsset.position, assetType: .goldMine)
            }
        }
        return true
    }

    @discardableResult private func activateFighter() -> Bool {
        guard let fighter = playerData.idleAssets.first(where: { $0.type != .peasant && $0.hasCapability(.attack) && $0.hasAction(.standGround) && !$0.hasActiveCapability(.standGround) }) else {
            return false
        }
        action = .standGround
        actor = fighter
        target = fighter
        return true
    }

    @discardableResult private func trainPeasant() -> Bool {
        guard let trainer = playerData.idleAssets.first(where: { $0.hasCapability(.buildPeasant) }) else {
            return false
        }
        action = .buildPeasant
        actor = trainer
        target = trainer
        return true
    }

    @discardableResult private func trainFootman() -> Bool {
        guard let trainer = playerData.idleAssets.first(where: { $0.hasCapability(.buildFootman) }) else {
            return false
        }
        action = .buildFootman
        actor = trainer
        target = trainer
        return true
    }

    @discardableResult private func trainArcher() -> Bool {
        guard let trainer = playerData.idleAssets.first(where: { $0.hasCapability(.buildArcher) || $0.hasCapability(.buildRanger) }) else {
            return false
        }
        action = trainer.hasCapability(.buildArcher) ? .buildArcher : .buildRanger
        actor = trainer
        target = trainer
        return true
    }

    func calculateCommand() {
        guard aiLevel != 0 else {
            return
        }
        if cycle % downSample == 0 {
            if playerData.assetCount(of: .goldMine) == 0 {
                searchMap()
            } else if playerData.playerAssetCount(of: .townHall) == 0 && playerData.playerAssetCount(of: .keep) == 0 && playerData.playerAssetCount(of: .castle) == 0 {
                buildTownHall()
            } else if playerData.idleAssets.contains(where: { $0.type == .peasant }) {
                activatePeasant()
            } else if playerData.playerAssetCount(of: AssetType.peasant) < 5 {
                trainPeasant()
            } else if playerData.visibilityMap.seenPercent(max: 100) < 12 {
                searchMap()
            } else {
                var completedAction = false
                let footmanCount = playerData.playerAssetCount(of: .footman)
                let archerCount = playerData.playerAssetCount(of: .archer) + playerData.playerAssetCount(of: .ranger)
                if !completedAction && (playerData.foodConsumption >= playerData.foodProduction) {
                    completedAction = buildBuilding(buildingType: .farm, nearType: .farm)
                }
                if !completedAction && playerData.playerAssetCount(of: .barracks) == 0 {
                    completedAction = buildBuilding(buildingType: .barracks, nearType: .farm)
                }
                if !completedAction && footmanCount < 5 {
                    completedAction = trainFootman()
                }
                if !completedAction && playerData.playerAssetCount(of: AssetType.lumberMill) == 0 {
                    completedAction = buildBuilding(buildingType: .lumberMill, nearType: .barracks)
                }
                if !completedAction && archerCount < 5 {
                    completedAction = trainArcher()
                }
                if !completedAction && playerData.playerAssetCount(of: .footman) != 0 {
                    completedAction = findEnemies()
                }
                if !completedAction {
                    completedAction = activateFighter()
                }
                if !completedAction && footmanCount >= 5 && archerCount >= 5 {
                    completedAction = attackEnemies()
                }
            }
            if let action = action, let actor = actor, let target = target {
                let capability = PlayerCapability.findCapability(action)
                if action == .mine && target.type == .none {
                }
                if capability.canApply(actor: actor, playerData: playerData, target: target) {
                    capability.applyCapability(actor: actor, playerData: playerData, target: target)
                }
            }
            action = nil
            actor = nil
            target = nil
        }
        cycle += 1
    }
}
