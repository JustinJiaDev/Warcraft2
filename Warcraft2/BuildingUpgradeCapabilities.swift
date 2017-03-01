class PlayerCapabilityBuildingUpgrade: PlayerCapability {

    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "Keep"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "Castle"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "GuardTower"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "CannonTower"))
        }
    }

    static let registrant = Registrant()

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
            self.playerData.decrementLumber(by: self.lumber)
            self.playerData.decrementGold(by: self.gold)
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        override func incrementStep() -> Bool {
            let addHitPoints = ((upgradeType.hitPoints - originalType.hitPoints) * (currentStep + 1) / totalSteps) - ((upgradeType.hitPoints - originalType.hitPoints) * currentStep / totalSteps)

            if currentStep == 0 {
                var assetCommand = actor.currentCommand
                assetCommand.action = AssetAction.construct
                actor.popCommand()
                actor.pushCommand(assetCommand)
                actor.changeType(to: upgradeType)
                actor.resetStep()
            }

            actor.incrementHitPoints(addHitPoints)

            if actor.hitPoints > actor.maxHitPoints {
                actor.hitPoints = actor.maxHitPoints
            }

            currentStep += 1
            actor.incrementStep()
            if currentStep >= totalSteps {
                playerData.addGameEvent(GameEvent(type: .workComplete, asset: actor))
                actor.popCommand()
                if actor.range != 0 {
                    let command = AssetCommand(action: .standGround, capability: nil, assetTarget: nil, activatedCapability: nil)
                    actor.pushCommand(command)
                }
                return true
            }
            return false
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
        if let assetType = playerData.assetTypes[buildingName] {
            if assetType.lumberCost > playerData.lumber {
                return false
            }
            if assetType.goldCost > playerData.gold {
                return false
            }
            if !playerData.assetRequirementsIsMet(name: buildingName) {
                return false
            }
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
