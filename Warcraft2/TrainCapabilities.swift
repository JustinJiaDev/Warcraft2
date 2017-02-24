import Foundation

class PlayerCapabilityTrainNormal: PlayerCapability {
    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityTrainNormal(unitName: "Peasant"))
            PlayerCapability.register(capability: PlayerCapabilityTrainNormal(unitName: "Footman"))
            PlayerCapability.register(capability: PlayerCapabilityTrainNormal(unitName: "Archer"))
        }
    }

    static let registrant: Registrant = Registrant()

    class ActivatedCapability: ActivatedPlayerCapability {
        private var currentStep: Int
        private var totalSteps: Int
        private var lumber: Int
        private var gold: Int

        init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset, lumber: Int, gold: Int, steps: Int) {
            let assetCommand = AssetCommand(action: .construct, capability: nil, assetTarget: actor, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target))

            currentStep = 0
            totalSteps = steps
            self.lumber = lumber
            self.gold = gold
            playerData.decrementLumber(by: lumber)
            playerData.decrementGold(by: gold)
            target.pushCommand(assetCommand)

            super.init(actor: actor, playerData: playerData, target: target)
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        override func incrementStep() -> Bool {
            let addHitPoints = (target.maxHitPoints * (currentStep + 1) / totalSteps) - (target.maxHitPoints * currentStep / totalSteps)

            target.incrementHitPoints(addHitPoints)
            if target.hitPoints > target.maxHitPoints {
                target.hitPoints = target.maxHitPoints
            }

            currentStep += 1
            actor.incrementStep()
            target.incrementStep()

            if currentStep >= totalSteps {
                let tempEvent = GameEvent(type: .ready, asset: target)
                playerData.addGameEvent(tempEvent)

                target.popCommand()
                actor.popCommand()
                target.tilePosition = playerData.playerMap.findAssetPlacement(placeAsset: target, fromAsset: actor, nextTileTarget: Position(x: playerData.playerMap.width - 1, y: playerData.playerMap.height - 1))
                return true
            }

            return false
        }

        override func cancel() {
            playerData.incrementLumber(by: lumber)
            playerData.incrementGold(by: gold)
            playerData.deleteAsset(target)
            actor.popCommand()
        }
    }

    private var unitName: String

    init(unitName: String) {
        self.unitName = unitName
        super.init(name: "Build", targetType: TargetType.none)
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        if let assetType = playerData.assetTypes[unitName] {
            if assetType.lumberCost > playerData.lumber {
                return false
            }
            if assetType.goldCost > playerData.gold {
                return false
            }
            if (assetType.foodConsumption + playerData.foodConsumption) > playerData.foodProduction {
                return false
            }
            if !playerData.assetRequirementsIsMet(name: unitName) {
                return false
            }
        }

        return true
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return canInitiate(actor: actor, playerData: playerData)
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        if let assetType = playerData.assetTypes[unitName] {
            let newAsset = playerData.createAsset(with: unitName)

            let newCommand = AssetCommand(action: .capability, capability: assetCapabilityType, assetTarget: newAsset, activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: newAsset, lumber: assetType.lumberCost, gold: assetType.goldCost, steps: assetType.buildTime))

            let tilePosition = Position()
            tilePosition.setToTile(actor.position)
            newAsset.tilePosition = tilePosition
            newAsset.hitPoints = 1

            actor.pushCommand(newCommand)
            actor.resetStep()
        }

        return false
    }
}
