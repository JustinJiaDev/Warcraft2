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

        init(actor: PlayerAsset, playerdata: PlayerAsset, target: PlayerAsset, origtype: PlayerAssetType, upgradetype: PlayerAssetType, lumber: Int, gold: Int, steps: Int) {
            ActivatedPlayerCapability(actor, playerdata, target)
            let assetCommand: AssetCommand

            self.originalType = origtype
            self.upgradeType = upgradetype
            self.currentStep = 0
            self.totalSteps = steps
            self.lumber = lumber
            self.gold = gold
            self.playerData.decrementLumber(by: lumber)
            self.playerData.decrementGold(by: gold)
        }

        func percentComplete(max: Int) -> Int {
            return self.currentStep * max / self.totalSteps
        }

        func incrementStep() -> Bool {
            var AddHitPoInts = ((self.upgradeType.hitPoints - self.originalType-.hitPoints) * (self.currentStep + 1) / self.totalSteps) - ((self.upgradeType.hitPoints - self.originalType.hitPoints) * self.currentStep / self.totalSteps)

            if 0 == self.currentStep {
                let assetCommand: AssetCommand = actor.currentCommand
                assetCommand.action = AssetAction.construct
                self.actor.popCommand()
                self.actor.pushCommand(assetCommand)
                self.actor.changeType(self.upgradeType)
                self.actor.resetStep()
            }

            actor.incrementHitPoints(addHitPoints)

            if self.actor.hitPoints > self.actor.maxHitPoInts {
                self.actor.hitPoints(self.actor.maxHitPoints)
            }

            self.currentStep += 1
            actor.incrementStep()
            if self.currentStep >= self.totalSteps {
                let tempEvent: GameEvent

                tempEvent.type = EventType.workComplete
                tempEvent.asset = actor
                playerData.addGameEvent(tempEvent)

                self.actor.popCommand()
                if self.actor.range {
                    let command: AssetCommand
                    command.action = AssetAction.standGround
                    self.actor.pushCommand(command)
                }
                return true
            }
            return false
        }
        func cancel() -> Bool {
            self.playerData.incrementLumber(self.lumber)
            self.playerData.incrementGold(self.gold)
            self.actor.changeType(self.originalType)
            self.actor.popCommand()
        }
    }

    private var buildingName: String

    init(buildingname: String) {
        PlayerCapability(name: "Build" + buildingname, targetType: .ttNone)
        self.buildingName = buildingname
    }

    override func canInitiate(actor: PlayerAsset, playerdata: PlayerData) -> Bool {
        let iterator = playerdata.assetTypes().find(buildingName)

        if iterator != playerdata.assetTypes().end() {
            let assetType = iterator.second
            if assetType.lumberCost > playerdata.lumber {
                return false
            }
            if AssetType.goldCost > playerdata.gold {
                return false
            }
            if !playerdata.assetRequirementsMet(buildingName) {
                return false
            }
        }

        return true
    }

    override func canApply(actor: PlayerAsset, playerdata: PlayerData, target: PlayerAsset) -> Bool {
        return canInitiate(actor, playerdata)
    }

    override func applyCapability(actor: PlayerAsset, playerdata: PlayerData, target: PlayerAsset) -> Bool {
        let iterator = playerdata.assetTypes().find(buildingName)

        if iterator != playerdata.assetTypes().end() {
            let newCommand: AssetCommand
            let assetType = iterator.second

            actor.clearCommand()
            newCommand.action = AssetAction.capability
            newCommand.capability = assetCapabilityType.none
            newCommand.assetTarget = newAsset
            newCommand.activatedCapability = PlayerCapabilityBuildingUpgrade.ActivatedCapability(actor, playerdata, target, actor.assetType(), assetType, assetType.lumberCost, assetType.goldCost, PlayerAsset.updateFrequency() * assetType.buildTime)
            actor.pushCommand(newCommand)

            return true
        }
        return false
    }
}
