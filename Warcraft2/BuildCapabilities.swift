struct BuildCapabilities {
    static let registrant = BasicCapabilities()

    init() {
        PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "TownHall"))
        PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "Farm"))
        PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "Barracks"))
        PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "LumberMill"))
        PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "Blacksmith"))
        PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "ScoutTower"))
    }

    func register() {}
}

class PlayerCapabilityBuildNormal: PlayerCapability {

    class ActivatedCapability: ActivatedPlayerCapability {

        private var currentStep: Int
        private var totalSteps: Int
        private var lumber: Int
        private var gold: Int

        init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset, lumber: Int, gold: Int, steps: Int) {
            self.currentStep = 0
            self.totalSteps = steps
            self.lumber = lumber
            self.gold = gold
            super.init(actor: actor, playerData: playerData, target: target)
            self.playerData.decrementLumber(by: lumber)
            self.playerData.decrementGold(by: gold)
            target.pushCommand(AssetCommand(action: .construct, capability: nil, assetTarget: actor, activatedCapability: nil))
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        override func incrementStep() -> Bool {
            target.incrementHitPoints((target.maxHitPoints * (currentStep + 1) / totalSteps) - (target.maxHitPoints * currentStep / totalSteps))

            if target.hitPoints > target.maxHitPoints {
                target.hitPoints = target.maxHitPoints
            }

            currentStep += 1
            actor.incrementStep()
            target.incrementStep()

            guard currentStep >= totalSteps else {
                return false
            }

            playerData.addGameEvent(GameEvent(type: .workComplete, asset: actor))
            target.popCommand()
            actor.popCommand()
            actor.tilePosition = Position.tile(
                fromAbsolute: playerData.playerMap.findAssetPlacement(
                    placeAsset: actor,
                    fromAsset: target,
                    nextTileTarget: Position(x: playerData.playerMap.width - 1, y: playerData.playerMap.height - 1)
                )
            )
            actor.resetStep()
            target.resetStep()
            return true
        }

        override func cancel() {
            playerData.incrementLumber(by: lumber)
            playerData.incrementGold(by: gold)
            playerData.deleteAsset(target)
            actor.popCommand()
        }
    }

    private var buildingName: String

    init(buildingName: String) {
        self.buildingName = buildingName
        super.init(name: "Build" + buildingName, targetType: .terrainOrAsset)
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        guard let assetType = playerData.assetTypes[buildingName] else {
            return false
        }
        guard assetType.lumberCost <= playerData.lumber else {
            return false
        }
        guard assetType.goldCost <= playerData.gold else {
            return false
        }
        return true
    }
    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor === target || target.type == .none else {
            return false
        }
        guard let assetType = playerData.assetTypes[buildingName] else {
            return false
        }
        guard assetType.lumberCost <= playerData.lumber else {
            return false
        }
        guard assetType.goldCost <= playerData.gold else {
            return false
        }
        guard playerData.playerMap.canPlaceAsset(at: target.tilePosition, size: assetType.size, ignoreAsset: actor) else {
            return false
        }
        return true
    }
    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard let assetType = playerData.assetTypes[buildingName] else {
            return false
        }
        actor.clearCommand()
        if actor.tilePosition == target.tilePosition {
            let newAsset = playerData.createAsset(buildingName)
            newAsset.tilePosition = Position.tile(fromAbsolute: target.position)
            newAsset.hitPoints = 1

            let newCommand = AssetCommand(
                action: .capability,
                capability: .none,
                assetTarget: newAsset,
                activatedCapability: ActivatedCapability(
                    actor: actor,
                    playerData: playerData,
                    target: newAsset,
                    lumber: assetType.lumberCost,
                    gold: assetType.goldCost,
                    steps: PlayerAsset.updateFrequency * assetType.buildTime
                )
            )
            actor.pushCommand(newCommand)
        } else {
            actor.pushCommand(AssetCommand(action: .capability, capability: .none, assetTarget: target, activatedCapability: nil))
            actor.pushCommand(AssetCommand(action: .walk, capability: .none, assetTarget: target, activatedCapability: nil))
        }
        return true
    }
}
