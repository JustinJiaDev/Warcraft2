//
//  BasicCapabilities.swift
//  Warcraft2
//
//  Created by Selestine  Mtei on 2/2/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

//started importing from line 59 of the original file

import Foundation

class CPlayerCapabilityMove: CPlayerCapability{ // CPlayerCapability need to be implemented.
    
    class CRegistrant{
        init(){}
    }
    
    class CActivatedCapability: CActivatedPlayerCapability{ //CActivatedPlayerCapability
        init(){}
        
        func percentComplete(max:Int)-> Int{
            return 0;
        }
        
        func incrementStep()->Bool{
            var assetCommand = SAssetCommand()
            var tempEvent = SGameEvent()
            
            tempEvent.DType = etAcknowledge
            tempEvent.DAsset = DActor() //check if its a class or not.
            playerData.addGameEvent(tempEvent) // re-check if I did this line correctly!
            assetCommand.DAction = aaWalk
            assetCommand.DAssetTarget = DTarget //is DTarget a class or variable?
            
            if !DActor.tileAligned() {
                DActor.direction(directionOpposite(DActor.position().tileOctant))
            }
            
            DActor.clearCommand()
            DActor.pushCommand(assetCommand)
            
            return true
        }
        
        func cancel(){
            DActor.popCommand()
        }
    }
    
    func canInitiate(actor:CPlayerAsset, playerData:CPlayerData)-> Bool{ //CPlayerAsset
        return actor.speed() > 0;
    }
    
    func canApply(actor:CPlayerAsset, playerData:CPlayerData, target: CPlayerAsset)-> Bool{
        return actor.speed() > 0;
    }
    
    func applyCapability(actor:CPlayerAsset, playerData:CPlayerData, target:CPlayerAsset)->Bool {
        if actor.tilePosition() != target.tilePosition() {
            var newCommand = SAssetCommand() //SAssetCommand need to locate this
            newCommand.DAction = aaCapability
            newCommand.DCapability = AssetCapabilityType()
            newCommand.DAssetTarget = target
            newCommand.DActivatedCapability // need to fix this line!
            actor.clearCommand()
            actor.pushCommand(newCommand)
            return true
        }
        return false
    }
}


class CPlayerCapabilityMineHarvest: CPlayerCapability{
    
    private class CRegistrant{
        
    }
    
    class CActivateCapability: CActivatedPlayerCapability{
        init(){}
        
        func percentComplete(max:Int)-> Int{
            return 0;
        }
        
        func incrementStep()->Bool{
            var assetCommand = SAssetCommand()
            var tempEvent = SGameEvent()
            
            tempEvent.DType = EEventType.etAcknowledge
            tempEvent.DAsset = DActor() // DActor is a class right? need to check this again. 
            DPlayerData.addGameEvent(tempEvent) //DPlayerData? or just obj.addGameEvent()?
            assetCommand.DAssetTarget = DTarget() //DTarget class?
            
            if EAssetType.atGoldMine == DTarget.Type() {
                assetCommand.DAction = EAssetAction.aaMineGold
            }else{
                assetCommand.DAction = EAsset.aaHarvestLumber
            }
            DActor.clearCommand()
            DActor.pushCommand(assetCommand)
            assetCommand.DAction = EAssetAction.aaWalk
            if !DActor.tileAligned() {
                DActor.direction(directionOpposite(DActor.position().tileOctant()))
            }
            DActor.pushCommand(assetCommand)
            return true
        }
        
        func cancel(){
            DActor.popCommand()
        }
    }
    
    func canInitiate(actor:CPlayerAsset, playerData:CPlayerData)->Bool{
        return actor.hasCapability(EAssetCapabilityType.actMine) //re-check this line again
    }
    
    func canApply(actor:CplayerAsset, playerdata:CPlayerData, target:CPlayerAsset)->Bool{
        if !actor.hasCapability(EAssetCapabilityType.actMine) {
            return false
        }
        if actor.lumber() || actor.gold() {
            return false
        }
        if EAssetType.atGoldMine == target.type() {
            return true
        }
        if EAssetType.atNone != target.type() {
            return false
        }
        return CTerrainMap.ETileType.ttTree == playerdata.playerMap().tileType(target.tilePosition())
    }
    
    func applyCapability(actor:CPlayerAsset, playerData:CPlayerData, target:CPlayerAsset)-> Bool{
        var newCommand = SAssetCommand()
        
        newCommand.DAction = EAssetAction.aaCapability //need to re-check this line!
        newCommand.DCapabilty = AssetCapabilityType()
        newCommand.DAssetTarget = target
        newCommand.DActivatedCapability// need to check how to complete this line
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}



class CPlayerCapabityStandGround: CPlayerCapability{
    
    class CRegistrant{
    }
    
    class CActivatedCapability: CActivatedPlayerCapability{
        
        func percentCompelte(max:Int)->Int{
            return 0
        }
        
        func incrementStep()->Bool{
            var assetCommand = SAssetCommand()
            var tempEvent = SGameEvent()
            
            tempEvent.DType = EEventType.etacknowledge
            tempEvent.DAsset = DActor()//
            DPlayerData.addGameEvent(tempEvent)
            
            assetCommand.DAssetTarget = DPlayerData.CreateMaker(DActor.position(), false)
            assetCommand.DAction = EAssetAction.aaStandGround//
            
            DActor.clearCommand()
            DActor.pushCommand(assetCommand)
            
            if !DActor.tileAligned() {
                assetCommand.DAction = EAssetAction.aaWalk
                DActor.direction(directionOpposite(DActor.position().tileOctant()))
                DActor.pushCommand(assetCommand)
            }
            return true
        }
        
        func cancel(){
            DActor.popCommand()
        }
    }
    
    func canInitiate(actor:CPlayerAsset, playerData:CPlayerData)->Bool{
        return true;
    }
    
    func canApply(actor:CPlayerAsset, playerData:CPlayerData, target:CPlayerAsset)->Bool{
        return true
    }
    
    func applyCapability(actor:CPlayerAsset, playerData:CPlayerData, target:CPlayerAsset)->Bool{
        var newCommand = SAssetCommand()
        
        newCommand.DAction = EAssetAction.aaCapability
        newCommand.DCapability = AssetCapabilityType()
        newCommand.DAssetTarget = target
        newCommand.DActivatedCapability // need complete this line
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}


class CPlayerCapabilityCancel: CPlayerCapability{
    
    class CRegistrant{
    }
    
    class CActivatedCapability: CActivatedPlayerCapability{
        
    }
    
    func canInitiate(actor:CPlayerAsset, playerData:CPlayerData)->Bool{
        return true
    }
    
    func canApply(actor:CPlayerAsset, playerData:CPlayerDta, target:CPlayerAsset)->Bool{
        return true
    }
    
    func applyCapability(actor:CPlayerAsset, playerData:CPlayerData, target:CPlayerAsset)->Bool{
        var newCommand = SAssetCommand()
        
        newCommand.DAction = EAssetAction.aaCapability//
        newCommand.DCapability = AssetCapabilityType()
        newCommand.DAssetTarget = target
        newCommand.DActivatedCapability //need finish this line
        
        actor.pushCommand(newCommand)
        
        return true
    }
}
