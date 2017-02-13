class PlayerCapabilityBuildingUpgrade: PlayerCapability {

    private class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "Keep"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "Castle"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "GuardTower"))
            PlayerCapability.register(capability: PlayerCapabilityBuildingUpgrade(buildingName: "CannonTower"))
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
            super.init(actor: actor, playerData: playerData, target: target)
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

            if 0 == self.currentStep {
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
                let tempEvent: GameEvent

                tempEvent.type = EventType.workComplete
                tempEvent.asset = actor
                playerData.addGameEvent(tempEvent)

                self.actor.popCommand()
                if self.actor.range != 0 {
                    let command: AssetCommand
                    command.action = AssetAction.standGround
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
        PlayerCapability(name: "Build" + buildingName, targetType: .none)
        self.buildingName = buildingName
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        let iterator = playerData.assetTypes.find(buildingName)

        if iterator != playerData.assetTypes().end() {
            let assetType = iterator.second
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
        let iterator = playerData.assetTypes.find(buildingName)

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
