class PlayerCapabilityBuildingUpgrade: PlayerCapability {

    private class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "Keep"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "Castle"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "GuardTower"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "CannonTower")) //removed private from player capability.register
        }
    }

    private let registrant: Registrant

    class ActivatedCapability: ActivatedPlayerCapability {

        private var originalType: PlayerAssetType
        private var upgradeType: PlayerAssetType
        private var currentStep: Int
        private var totalSteps: Int
        private var lumber: Int
        private var gold: Int

        init(actor: PlayerAsset, playerData: PlayerAsset, target: PlayerAsset, originalType: PlayerAssetType, upgradeType: PlayerAssetType, lumber: Int, gold: Int, steps: Int) {
            super.init(actor: actor, playerData: playerData, target: target) //can't convert playerasset to playerdata
            let assetCommand: AssetCommand

            self.originalType = originalType
            self.upgradeType = upgradeType
            self.currentStep = 0
            self.totalSteps = steps
            self.lumber = lumber
            self.gold = gold
            self.playerData.decrementLumber(by: lumber)
            self.playerData.decrementGold(by: gold)
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        func incrementStep() -> Bool {
            var addHitPoints = ((upgradeType.hitPoints - originalType.hitPoints) * (currentStep + 1) / totalSteps) - ((upgradeType.hitPoints - originalType.hitPoints) * currentStep / totalSteps)

            if currentStep == 0 {
                var assetCommand: AssetCommand = actor.currentCommand
                assetCommand.action = AssetAction.construct
                actor.popCommand()
                actor.pushCommand(assetCommand)
                actor.changeType(to: self.upgradeType)
                actor.resetStep()
            }

            actor.incrementHitPoints(addHitPoints)

            if actor.hitPoints > actor.maxHitPoints {
                actor.hitPoints = actor.maxHitPoints
            }

            currentStep += 1
            actor.incrementStep()
            if currentStep >= totalSteps {
                let tempEvent = GameEvent(type: .workComplete, asset: actor)

                playerData.addGameEvent(tempEvent)

                actor.popCommand()
                if actor.range != 0 {
                    let command = AssetCommand(action: .standGround) //capability and other values not initialized in original code
                    
                    actor.pushCommand(command)
                }
                return true
            }
            return false
        }
        func cancel() -> Bool {
            playerData.incrementLumber(by: lumber)
            playerData.incrementGold(by: gold)
            actor.changeType(to: originalType)
            actor.popCommand()
        }
    }

    private var buildingName: String

    init(buildingName: String) {
        super.init(name: "Build" + buildingName, targetType: .none)
        self.buildingName = buildingName
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

        if let assetType = playerData.assetTypes[buildingName] {
           
            let newCommand = AssetCommand(action: .capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: self.ActivatedCapability(actor, playerData, target, actor.assetType, assetType, assetType.lumberCost, assetType.goldCost, PlayerAsset.updateFrequency * assetType.buildTime))

            actor.clearCommand()

            actor.pushCommand(newCommand)

            return true
        }
        return false
    }
}
