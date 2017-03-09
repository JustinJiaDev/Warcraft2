struct BuildingUpgradeCapabilities {
    static let registrant = BuildingUpgradeCapabilities()

    init() {
        PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "Keep"))
        PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "Castle"))
        PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "GuardTower"))
        PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "CannonTower"))
    }

    func register() {}
}

class PlayerCapabilityBuildingUpgrade: PlayerCapability {

    class ActivatedCapability: ActivatedPlayerCapability {
        private var originalType: PlayerAssetType
        private var upgradeType: PlayerAssetType
        private var currentStep: Int
        private var totalSteps: Int
        private var lumber: Int
        private var gold: Int

        init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset, originalType: PlayerAssetType, upgradeType: PlayerAssetType, lumber: Int, gold: Int, steps: Int) {
            self.originalType = originalType
            self.upgradeType = upgradeType
            self.currentStep = 0
            self.totalSteps = steps
            self.lumber = lumber
            self.gold = gold
            super.init(actor: actor, playerData: playerData, target: target)
            self.playerData.decrementLumber(by: lumber)
            self.playerData.decrementGold(by: gold)
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        override func incrementStep() -> Bool {
            actor.incrementHitPoints(((upgradeType.hitPoints - originalType.hitPoints) * (currentStep + 1) / totalSteps) - ((upgradeType.hitPoints - originalType.hitPoints) * currentStep / totalSteps))

            if currentStep == 0 {
                var assetCommand = actor.currentCommand
                assetCommand.action = .construct
                actor.popCommand()
                actor.pushCommand(assetCommand)
                actor.changeType(to: upgradeType)
                actor.resetStep()
            }

            currentStep += 1
            actor.incrementStep()

            guard currentStep >= totalSteps else {
                return false
            }

            playerData.addGameEvent(GameEvent(type: .workComplete, asset: actor))
            actor.popCommand()
            if actor.range > 0 {
                actor.pushCommand(AssetCommand(action: .standGround, capability: nil, assetTarget: nil, activatedCapability: nil))
            }
            return true
        }

        override func cancel() {
            playerData.incrementLumber(by: lumber)
            playerData.incrementGold(by: gold)
            actor.changeType(to: originalType)
            actor.popCommand()
        }
    }

    private var buildingName: String

    init(buildingName: String) {
        self.buildingName = buildingName
        super.init(name: "Build" + buildingName, targetType: .none)
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
        guard playerData.assetRequirementsIsMet(name: buildingName) else {
            return false
        }
        return true
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return canInitiate(actor: actor, playerData: playerData)
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard let assetType = playerData.assetTypes[buildingName] else {
            return false
        }
        actor.clearCommand()
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(
                actor: actor,
                playerData: playerData,
                target: target,
                originalType: actor.assetType,
                upgradeType: assetType,
                lumber: assetType.lumberCost,
                gold: assetType.goldCost,
                steps: PlayerAsset.updateFrequency * assetType.buildTime
            )
        )
        actor.pushCommand(newCommand)
        return true
    }
}
