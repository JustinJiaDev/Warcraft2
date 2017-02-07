import Foundation


// Build normal buildings capability
class PlayerCapabilityBuildNormal: PlayerCapability{
    class Registrant: PlayerCapability{
        init() {
            PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "TownHall"))
            PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "Farm"))
            PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "Barracks"))
            PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "LumberMill"))
            PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "Blacksmith"))
            PlayerCapability.register(capability: PlayerCapabilityBuildNormal(buildingName: "ScoutTower"))
        }
    }
    private let registrant: Registrant

    class ActivatedCapability: ActivatedPlayerCapability{

        private var currentStep: Int
        private var totalSteps: Int
        private var lumber: Int
        private var gold: Int


        init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset, lumber: Int, gold: Int, steps: Int){
            ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)
            var assetCommand: AssetCommand

            self.currentStep = 0
            self.totalSteps = steps
            self.lumber = lumber
            self.gold = gold
            //self.playerData.decrementLumber(self.lumber)
            self.playerData.decrementGold(by: gold)
            assetCommand.action = AssetAction.construct
            assetCommand.assetTarget = actor
            target.pushCommand(command: assetCommand)

        }


        func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        func incrementStep() -> Bool {
            var addHitPoints = (target.maxHitPoints * (self.currentStep + 1) / self.totalSteps) - (target.maxHitPoints * self.currentStep / self.totalSteps);

            self.target.incrementHitPoints(addHitPoints);
            if self.target.hitPoints > self.target.maxHitPoints {
                self.target.hitPoints = self.target.maxHitPoints;
            }
            self.currentStep += 1;
            self.actor.incrementStep();
            self.target.incrementStep();
            if self.currentStep >= self.totalSteps {
                var tempEvent: GameEvent

                tempEvent.type = EventType.workComplete;
                tempEvent.asset = self.actor;
                self.playerData.addGameEvent(event: tempEvent);

                self.target.popCommand();
                self.actor.popCommand();
                self.actor.tilePosition.setToTile (self.playerData.playerMap.findAssetPlacement(placeAsset: self.actor, fromAsset: self.target, nextTileTarget: Position(x: self.playerData.playerMap.width - 1, y: self.playerData.playerMap.height-1)))
                self.actor.resetStep();
                self.target.resetStep();

                return true;
            }
            return false;

        }

        override func cancel(){
                self.playerData.incrementLumber(by: self.lumber)
                self.playerData.incrementGold(by: self.gold)
                self.playerData.deleteAsset(asset: self.target)
                self.actor.popCommand()

        }
    }

    private var buildingName: String

    init(buildingName: String) {
        PlayerCapability(name: "Build" + buildingName, targetType: .terrainOrAsset)
        self.buildingName = buildingName

    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        let iterator = playerData.assetTypes.findDefault()

        if iterator != playerData.assetTypes().end(){
            let assetType = iterator.second
            if assetType.lumberCost > playerData.lumber {
                return false
            }
            if assetType.goldCost > playerData.gold {
                return false
            }
        }

        return true;
    }
    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool{
        let iterator = playerData.assetTypes.findDefault(buildingName)

        if (actor != target)&&(AssetType.none != target.type ){
            return false;
        }
        if iterator != playerData.assetTypes().end() {
            let assetType = iterator.second

            if assetType.lumberCost > playerData.lumber {
                return false;
            }
            if assetType.goldCost > playerData.gold {
                return false;
            }
            if !playerData.playerMap().canPlaceAsset(target.tilePosition(), assetType.Size(), actor) {
                return false;
            }
        }
        return true;

    }
    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let iterator = playerData.assetTypes.(buildingName)

        if iterator != playerData.assetTypes().end() {
            var newCommand: AssetCommand

            actor.clearCommand();
            if actor.tilePosition == target.tilePosition {
                let AssetType = iterator.second
                let newAsset = playerData.createAsset(assetTypeName: buildingName)
                var tilePosition: Position
                tilePosition.setToTile(target.position)
                newAsset.tilePosition.setToTile(tilePosition)
                newAsset.hitPoints = 1

                newCommand.action = AssetAction.capability
                newCommand.capability = AssetCapabilityType.none
                newCommand.assetTarget = newAsset
                newCommand.activatedCapability = PlayerCapabilityBuildNormal.ActivatedCapability(actor, playerData, newAsset, AssetType.lumberCost, AssetType.goldCost, PlayerAsset.updateFrequency * AssetType.buildTime)
                actor.pushCommand(command: newCommand)
            }
            else{
                newCommand.action = AssetAction.capability
                newCommand.capability = AssetCapabilityType.none
                newCommand.assetTarget = target
                actor.pushCommand(command: newCommand)

                newCommand.action = AssetAction.walk
                actor.pushCommand(command: newCommand)
            }
            return true;

        }
    }
}
