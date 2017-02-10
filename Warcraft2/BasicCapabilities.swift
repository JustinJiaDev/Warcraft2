//started importing from line 59 of the original file

 import Foundation

 class PlayerCapabilityMove: PlayerCapability{ // PlayerCapability need to be implemented.

    class Registrant{
        init(){}
    }

    class ActivatedCapability: ActivatedPlayerCapability{ //ActivatedPlayerCapability
        init(){}

        override func percentComplete(max:Int)-> Int{
            return 0;
        }

        func incrementStep()->Bool{
            var assetCommand = AssetCommand()
            var tempEvent = GameEvent()

            tempEvent.type = .acknowledge
            tempEvent.DAsset = actor() //check if its a class or not.
            playerData.addGameEvent(tempEvent) // re-check if I did this line correctly!
            assetCommand.DAction = .walk
            assetCommand.assetTarget = target //is DTarget a class or variable?

            if !actor.tileAligned {
                actor.direction(directionOpposite(actor.position().tileOctant))
            }

            actor.clearCommand()
            actor.pushCommand(assetCommand)

            return true
        }

        override func cancel(){
            actor.popCommand()
        }
    }

    override func canInitiate(actor:PlayerAsset, playerData:PlayerData)-> Bool{ //PlayerAsset
        return actor.speed > 0;
    }

    override func canApply(actor:PlayerAsset, playerData:PlayerData, target: PlayerAsset)-> Bool{
        return actor.speed > 0;
    }

    func applyCapability(actor:PlayerAsset, playerData:PlayerData, target:PlayerAsset)->Bool {
        if actor.tilePosition != target.tilePosition {
            var newCommand = AssetCommand() //AssetCommand need to locate this
            newCommand.action = .capability
            newCommand.capability = AssetCapabilityType()
            newCommand.assetTarget = target
            newCommand.activatedCapability // need to fix this line!
            actor.clearCommand()
            actor.pushCommand(newCommand)
            return true
        }
        return false
    }
 }


 class PlayerCapabilityMineHarvest: PlayerCapability{

    private class Registrant{

    }

    class ActivateCapability: ActivatedPlayerCapability{
        init(){}

        override func percentComplete(max:Int)-> Int{
            return 0;
        }

        func incrementStep()->Bool{
            var assetCommand = AssetCommand()
            var tempEvent = GameEvent()

            tempEvent.DType = EventType.acknowledge
            tempEvent.DAsset = actor() // actor is a class right? need to check this again.
            PlayerData.addGameEvent(tempEvent) //DPlayerData? or just obj.addGameEvent()?
            assetCommand.DAssetTarget = target

            if AssetType.goldMine == target.type {
                assetCommand.DAction = AssetAction.mineGold
            }else{
                assetCommand.DAction = AssetAction.harvestLumber
            }
            actor.clearCommand()
            actor.pushCommand(assetCommand)
            assetCommand.DAction = AssetAction.walk
            if !actor.tileAligned {
                actor.direction(directionOpposite(actor.position().tileOctant()))
            }
            actor.pushCommand(assetCommand)
            return true
        }

        override func cancel(){
            actor.popCommand()
        }
    }

    override func canInitiate(actor:PlayerAsset, playerData:PlayerData)->Bool{
        return actor.hasCapability(AssetCapabilityType.mine) //re-check this line again
    }

    func canApply(actor:PlayerAsset, playerdata:PlayerData, target:PlayerAsset)->Bool{
        if !actor.hasCapability(AssetCapabilityType.mine) {
            return false
        }
        if actor.lumber != 0 || actor.gold != 0 {
            return false
        }
        if AssetType.goldMine == target.type {
            return true
        }
        if AssetType.none != target.type {
            return false
        }
        return TerrainMap.TileType.tree == playerdata.playerMap.tileType(target.tilePosition())
    }

    override func applyCapability(actor:PlayerAsset, playerData:PlayerData, target:PlayerAsset)-> Bool{
        var newCommand: AssetCommand
        
        newCommand.action = AssetAction.capability
        newCommand.capability = assetCapabilityType
        newCommand.assetTarget = target
        //fix it!
        newCommand.activatedCapability = ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
 }



 class PlayerCapabityStandGround: PlayerCapability{

    class Registrant{
    }

    class ActivatedCapability: ActivatedPlayerCapability{

        func percentCompelte(max:Int)->Int{
            return 0
        }

        func incrementStep()->Bool{
            var assetCommand: AssetCommand
            var tempEvent: GameEvent
            
            tempEvent.type = EventType.acknowledge
            tempEvent.asset = actor
            playerData.addGameEvent(tempEvent) //fix it or got it?
            //fix it or nah?
            assetCommand.assetTarget = playerData.createMarker(at: actor.position,addToMap: false)
            assetCommand.action = AssetAction.standGround
            
            actor.clearCommand()
            actor.pushCommand(assetCommand)
            
            if !actor.tileAligned {
                assetCommand.action = AssetAction.walk
                //fix line beneath
                actor.direction(directionOpposite(actor.position.tileOctant()))
                actor.pushCommand(assetCommand)
            }
            return true
        }

        override func cancel(){
            actor.popCommand()
        }
    }

    override func canInitiate(actor:PlayerAsset, playerData:PlayerData)->Bool{
        return true;
    }

    override func canApply(actor:PlayerAsset, playerData:PlayerData, target:PlayerAsset)->Bool{
        return true
    }

    override func applyCapability(actor:PlayerAsset, playerData:PlayerData, target:PlayerAsset)->Bool{
        var newCommand: AssetCommand
        newCommand.action = AssetAction.capability
        newCommand.capability = assetCapabilityType
        newCommand.assetTarget = target
        //re-check the line beneath.
        newCommand.activatedCapability = ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
 }


 class PlayerCapabilityCancel: PlayerCapability{

    class Registrant{
    }

    class ActivatedCapability: ActivatedPlayerCapability{
        override func percentComplete(max: Int)->Int{
            return 0;
        }
        
        func incrementStep()->Bool{
            actor.popCommand()
            
            if AssetAction.none != actor.action {
                var assetCommand: AssetCommand
                assetCommand = actor.currentCommand()
                
                if AssetAction.construct == assetCommand.action {
                    if assetCommand.assetTarget != nil {
                        assetCommand.assetTarget?.currentCommand().activatedCapability?.cancel()
                    }else if assetCommand.activatedCapability != nil {
                        assetCommand.activatedCapability?.cancel()
                    }
                }else if assetCommand.activatedCapability != nil {
                    assetCommand.activatedCapability?.cancel()
                }
            }
            return true;
        }
        
        override func cancel(){
            actor.popCommand()
        }
    }

    override func canInitiate(actor:PlayerAsset, playerData:PlayerData)->Bool{
        return true
    }

    override func canApply(actor:PlayerAsset, playerData:PlayerData, target:PlayerAsset)->Bool{
        return true
    }

    override func applyCapability(actor:PlayerAsset, playerData:PlayerData, target:PlayerAsset)->Bool{
        var newCommand: AssetCommand

        newCommand.action = AssetAction.capability
        newCommand.capability = assetCapabilityType
        newCommand.assetTarget = target
        //the line beneath, is it correctly written? need re-check this again.
        newCommand.activatedCapability = ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)
        actor.pushCommand(newCommand)
        return true
    }
 }
