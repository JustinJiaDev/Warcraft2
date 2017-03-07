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
            let assetCommand = AssetCommand(action: .construct, capability: nil, assetTarget: actor, activatedCapability: nil)
            target.pushCommand(assetCommand)
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        override func incrementStep() -> Bool {
            let addHitPoints = (target.maxHitPoints * (self.currentStep + 1) / self.totalSteps) - (target.maxHitPoints * self.currentStep / self.totalSteps)

            self.target.incrementHitPoints(addHitPoints)
            if self.target.hitPoints > self.target.maxHitPoints {
                self.target.hitPoints = self.target.maxHitPoints
            }
            self.currentStep += 1
            self.actor.incrementStep()
            self.target.incrementStep()
            if self.currentStep >= self.totalSteps {
                let tempEvent = GameEvent(type: .workComplete, asset: actor)
                self.playerData.addGameEvent(tempEvent)

                self.target.popCommand()
                self.actor.popCommand()
                self.actor.tilePosition = Position.tile(fromAbsolute: self.playerData.playerMap.findAssetPlacement(placeAsset: self.actor, fromAsset: self.target, nextTileTarget: Position(x: self.playerData.playerMap.width - 1, y: self.playerData.playerMap.height - 1)))
                self.actor.resetStep()
                self.target.resetStep()

                return true
            }
            return false
        }

        override func cancel() {
            self.playerData.incrementLumber(by: self.lumber)
            self.playerData.incrementGold(by: self.gold)
            self.playerData.deleteAsset(self.target)
            self.actor.popCommand()
        }
    }

    private var buildingName: String

    init(buildingName: String) {
        self.buildingName = buildingName
        super.init(name: "Build" + buildingName, targetType: .terrainOrAsset)
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        //        let iterator = playerData.assetTypes.findDefault()
        //
        //        if iterator != playerData.assetTypes().end() {
        //            let assetType = iterator.second
        //            if assetType.lumberCost > playerData.lumber {
        //                return false
        //            }
        //            if assetType.goldCost > playerData.gold {
        //                return false
        //            }
        //        }
        //
        return true
    }
    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        //        let iterator = playerData.assetTypes.find(buildingName)
        //
        //        if (actor != target) && (AssetType.none != target.type) {
        //            return false
        //        }
        //        if iterator != playerData.assetTypes().end() {
        //            let assetType = iterator.second
        //
        //            if assetType.lumberCost > playerData.lumber {
        //                return false
        //            }
        //            if assetType.goldCost > playerData.gold {
        //                return false
        //            }
        //            if !playerData.playerMap().canPlaceAsset(target.tilePosition(), assetType.Size(), actor) {
        //                return false
        //            }
        //        }
        return true
    }
    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let iterator = playerData.assetTypes[buildingName]
        if iterator != nil {
            actor.clearCommand()
            if actor.tilePosition == target.tilePosition {
                let AssetType = iterator!
                let newAsset = playerData.createAsset(buildingName)
                let tilePosition = Position.tile(fromAbsolute: target.position)
                newAsset.tilePosition = Position.absolute(fromTile: tilePosition)
                newAsset.hitPoints = 1

                let newCommand = AssetCommand(action: .capability, capability: .none, assetTarget: newAsset, activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: newAsset, lumber: AssetType.lumberCost, gold: AssetType.goldCost, steps: PlayerAsset.updateFrequency * AssetType.buildTime))
                actor.pushCommand(newCommand)
            } else {
                var newCommand = AssetCommand(action: .capability, capability: .none, assetTarget: target, activatedCapability: nil)
                actor.pushCommand(newCommand)
                newCommand.action = AssetAction.walk
                actor.pushCommand(newCommand)
            }
            return true
        }
        return false
    }
}
