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
            return self.currentStep * max / self.totalSteps
        }

        func incrementStep() -> Bool {
            var addHitPoints = ((self.upgradeType.hitPoints - self.originalType.hitPoints) * (self.currentStep + 1) / self.totalSteps) - ((self.upgradeType.hitPoints - self.originalType.hitPoints) * self.currentStep / self.totalSteps)

            if self.currentStep == 0 {
                var assetCommand: AssetCommand = actor.currentCommand
                assetCommand.action = AssetAction.construct
                self.actor.popCommand()
                self.actor.pushCommand(assetCommand)
                self.actor.changeType(to: self.upgradeType)
                self.actor.resetStep()
            }

            actor.incrementHitPoints(addHitPoints)

            if self.actor.hitPoints > self.actor.maxHitPoints {
                self.actor.hitPoints = self.actor.maxHitPoints
            }

            self.currentStep += 1
            actor.incrementStep()
            if self.currentStep >= self.totalSteps {
                let tempEvent = GameEvent(type: .workComplete, asset: actor)

                playerData.addGameEvent(tempEvent)

                self.actor.popCommand()
                if self.actor.range != 0 {
                    let command = AssetCommand(action: .standGround) //capability and other values not initialized in original code
                    
                    self.actor.pushCommand(command)
                }
                return true
            }
            return false
        }
        func cancel() -> Bool {
            self.playerData.incrementLumber(by: self.lumber)
            self.playerData.incrementGold(by: self.gold)
            self.actor.changeType(to: self.originalType)
            self.actor.popCommand()
        }
    }

    private var buildingName: String

    init(buildingName: String) {
        super.init(name: "Build" + buildingName, targetType: .none)
        self.buildingName = buildingName
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        var iterator = playerData.assetTypes.makeIterator() // original: playerData.assetTypes.find(buildingName) not sure if this is right

        if iterator != playerData.assetTypes.last() { //how to get last element of dictionary
            let assetType = iterator.value //iterator.second?
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
        let iterator = playerData.assetTypes[buildingName]

        if iterator != playerData.assetTypes().end() {
            let newCommand: AssetCommand
            let assetType = iterator.second

            actor.clearCommand()
            newCommand.action = AssetAction.capability
            newCommand.capability = assetCapabilityType
            newCommand.assetTarget = target
            newCommand.activatedCapability = PlayerCapabilityBuildingUpgrade.ActivatedCapability(actor, playerData, target, actor.assetType(), assetType, assetType.lumberCost, assetType.goldCost, PlayerAsset.updateFrequency() * assetType.buildTime)
            actor.pushCommand(newCommand)

            return true
        }
        return false
    }
}
