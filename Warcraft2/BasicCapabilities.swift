//started importing from line 59 of the original file

 import Foundation

 class PlayerCapabilityMove: PlayerCapability{ // CPlayerCapability need to be implemented.

    class Registrant{
        init(){}
    }

    class ActivatedCapability: ActivatedPlayerCapability{ //CActivatedPlayerCapability
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
        var newCommand = AssetCommand()

        newCommand.action = AssetAction.aaCapability //need to re-check this line!
        newCommand.capabilty = AssetCapabilityType()
        newCommand.assetTarget = target
        newCommand.activatedCapability// need to check how to complete this line
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
            var assetCommand = AssetCommand()
            var tempEvent = GameEvent()

            tempEvent.DType = EventType.acknowledge
            tempEvent.asset = actor()//
            PlayerData.addGameEvent(tempEvent)

            assetCommand.DAssetTarget = PlayerData.CreateMaker(actor.position(), false)
            assetCommand.DAction = AssetAction.aaStandGround//

            actor.clearCommand()
            actor.pushCommand(assetCommand)

            if !actor.tileAligned {
                assetCommand.DAction = AssetAction.aaWalk
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
        var newCommand = AssetCommand()

        newCommand.DAction = AssetAction.aaCapability
        newCommand.DCapability = AssetCapabilityType()
        newCommand.DAssetTarget = target
        newCommand.DActivatedCapability // need complete this line
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
 }


 class PlayerCapabilityCancel: PlayerCapability{

    class CRegistrant{
    }

    class CActivatedCapability: ActivatedPlayerCapability{

    }

    override func canInitiate(actor:PlayerAsset, playerData:PlayerData)->Bool{
        return true
    }

    override func canApply(actor:PlayerAsset, playerData:PlayerData, target:PlayerAsset)->Bool{
        return true
    }

    override func applyCapability(actor:PlayerAsset, playerData:PlayerData, target:PlayerAsset)->Bool{
        var newCommand = AssetCommand()

        newCommand.DAction = AssetAction.capability
        newCommand.DCapability = AssetCapabilityType()
        newCommand.DAssetTarget = target
        newCommand.DActivatedCapability //need finish this line

        actor.pushCommand(newCommand)

        return true
    }
 }
