struct TrainCapabilities {
    static let registrant = TrainCapabilities()
    
    init() {
        PlayerCapability.register(capability: PlayerCapabilityTrainNormal(unitName: "Peasant"))
        PlayerCapability.register(capability: PlayerCapabilityTrainNormal(unitName: "Footman"))
        PlayerCapability.register(capability: PlayerCapabilityTrainNormal(unitName: "Archer"))
    }
    
    // Does this need to be here since it's empty ?
    func register() {}
}

class PlayerCapabilityTrainNormal: PlayerCapability {
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
            self.target.pushCommand(AssetCommand(action: .construct, capability: .none, assetTarget: actor, activatedCapability: nil))
        }
        
        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }
        
        override func incrementStep() -> Bool {
            currentStep += 1
            actor.incrementStep()
            target.incrementStep()
            
            target.incrementHitPoints((target.maxHitPoints * (currentStep + 1) / totalSteps) - (target.maxHitPoints * currentStep / totalSteps))
            
            guard currentStep >= totalSteps else {
                return false
            }
            
            playerData.addGameEvent(GameEvent(type: .ready, asset: target))
            actor.popCommand()
            target.popCommand()
            target.tilePosition = playerData.playerMap.findAssetPlacement(
                placeAsset: target,
                fromAsset: actor,
                nextTileTarget: Position(x: playerData.playerMap.width - 1, y: playerData.playerMap.height - 1)
            )
            return true
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
        // C++ line 63: CPlayerCapabilityTrainNormal::CPlayerCapabilityTrainNormal(const std::string &unitname) :CPlayerCapability(std::string("Build") + unitname, ETargetType::ttNone)
        // original Swift: super.init(name: "Build", targetType: .none)
        super.init(name: "Build" + unitName, targetType: .none)
    }
    
    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        guard let assetType = playerData.assetTypes[unitName] else {
            return false
        }
        guard assetType.lumberCost <= playerData.lumber else {
            return false
        }
        guard assetType.goldCost <= playerData.gold else {
            return false
        }
        guard (assetType.foodConsumption + playerData.foodConsumption) <= playerData.foodProduction else {
            return false
        }
        guard playerData.assetRequirementsIsMet(name: unitName) else {
            return false
        }
        return true
    }
    
    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return canInitiate(actor: actor, playerData: playerData)
    }
    
    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard let assetType = playerData.assetTypes[unitName] else {
            return false
        }
        
        let newAsset = playerData.createAsset(unitName)
        newAsset.tilePosition = Position.tile(fromAbsolute: actor.position)
        newAsset.hitPoints = 1
        
        
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: newAsset,
            activatedCapability: ActivatedCapability(
                actor: actor,
                playerData: playerData,
                target: newAsset,
                lumber: assetType.lumberCost,
                gold: assetType.goldCost,
                // C++ line 108: CPlayerAsset::UpdateFrequency() * AssetType->BuildTime());
                // original Swift: steps: assetType.buildTime
                steps: PlayerAsset.updateFrequency * assetType.buildTime
            )
        )
        actor.pushCommand(newCommand)
        actor.resetStep()
        // C++ line 112: original code always return false, not sure if that's a wrong implementation?
        return true
    }
}
