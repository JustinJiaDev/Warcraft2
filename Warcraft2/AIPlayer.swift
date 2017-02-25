//
//  AIPlayer.swift
//  Warcraft2
//
//  Created by Jeffrey Wang on 2/23/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation


class CAIPlayer{
    private var playerData: PlayerData
    private var cycle: Int
    private var downSample: Int
    
    private func searchMap(command: PlayerCommandRequest) -> Bool {
        let idleAssets = playerData.idleAssets
        var movableAsset: PlayerAsset
        
        for var weakAsset in idleAssets {
            if let asset = weakAsset.lock { //fix
                if asset.speed == true {
                    movableAsset = asset
                    break
                }
            }
        }
        if movableAsset != nil {
            let unknownPosition = playerData.playerMap.findNearestReachableTileType(movableAsset.tilePosition, TerrainMap.tileType.none)
            
            if unknownPosition.x >= 0 {
                command.action = AssetCapabilityType.move //fix
                command.actors.append(movableAsset) //fix
                command.targetLocation.setFromTile(unknownPosition)
                return true
            }
        }
        return false
    }
    private func findEnemies(command: PlayerCommandRequest) -> Bool {
        let townHallAsset: PlayerAsset
        
        for var weakAsset in playerData.assets {
            if let asset = weakAsset.lock { //fix
                if asset.hasCapability(AssetCapabilityType.buildPeasant) {
                    townHallAsset = asset
                    break
                }
            }
        }
        
        if playerData.findNearestEnemy(at: townHallAsset.position, inputRange: -1).expired { //fix
            return searchMap(command: command)
        }
        return false
    }
    private func attackEnemies(command: PlayerCommandRequest) -> Bool {
        let averageLocation = Position()
        
        for var weakAsset in playerData.assets {
            if let asset = weakAsset.lock { //fix
                if ( AssetType.footman == asset.type ) || (AssetType.archer == asset.type)||(AssetType.ranger == asset.type) {
                    if asset.hasAction(AssetAction.attack) != true { //fix
                        command.actors.append(asset)
                        averageLocation.incrementX(asset.positionX())
                        averageLocation.incrementY(asset.positionY())
                    }
                }
            }
        }
        if command.actors.count != 0 {
            averageLocation.x = averageLocation.x / command.actors.count
            averageLocation.y = averageLocation.y / command.actors.count
            
            let targetEnemy = playerData.findNearestEnemy(at: averageLocation, inputRange: -1).lock //fix
            if targetEnemy != nil {
                command.actors.removeAll()
                return searchMap(command: command)
            }
            command.action = AssetCapabilityType.attack //fix
            command.targetLocation = targetEnemy.position()
            command.targetColor = targetEnemy.color()
            command.targetType = targetEnemy.type()
            return true
        }
        return false
        
    }
    private func buildTownHall(command: PlayerCommandRequest) -> Bool {
        let idleAssets = playerData.idleAssets
        var builderAsset: PlayerAsset
        
        for var weakAsset in idleAssets {
            if var asset = weakAsset.lock { //fix
                if asset.hasCapability(AssetCapabilityType.buildTownHall) {
                    builderAsset = asset
                    break
                }
            }
        }
        if builderAsset != nil {
            let goldMineAsset = playerData.findNearestAsset(at: builderAsset.position(), assetType: AssetType.goldMine)
            let placement = playerData.findBestAssetPlacement(goldMineAsset.tilePosition(), builderAsset, AssetType.townHall, 1)
            if placement.X() >= 0 {
                command.action = AssetCapabilityType.buildTownHall
                command.actors.append(builderAsset)
                command.targetLocation.setFromTile(placement)
                return true
            }
            else{
                return searchMap(command: command)
            }
        }
        return false
    }
    private func buildBuilding(command: PlayerCommandRequest, buildingType: AssetType, nearType: AssetType) -> Bool {
        var builderAsset: PlayerAsset
        var townHallAsset: PlayerAsset
        var nearAsset: PlayerAsset
        var buildAction: AssetCapabilityType
        var assetIsIdle = false
        
        switch(buildingType){
        case AssetType.barracks:    buildAction = AssetCapabilityType.buildBarracks
            break
        case AssetType.lumberMill:  buildAction = AssetCapabilityType.buildLumberMill
            break
        case AssetType.blacksmith:  buildAction = AssetCapabilityType.buildBlacksmith
            break
        default:            buildAction = AssetCapabilityType.buildFarm
            break
        }
        
        for var weakAsset in playerData.assets {
            if let asset = weakAsset.lock {
                if(asset.hasCapability(buildAction) && asset.interruptible()){
                    if !builderAsset || (!assetIsIdle && (AssetAction.none == asset.action )) {
                        builderAsset = asset
                        assetIsIdle = AssetAction.one == asset.action
                    }
                }
                if asset.hasCapability(AssetCapabilityType.buildPeasant) {
                    townHallAsset = asset
                }
                if asset.hasActiveCapability(buildAction) {
                    return false
                }
                if (nearType == asset.type ) && (AssetAction.construct != asset.action ) {
                    nearAsset = asset
                }
                if buildingType == asset.type {
                    if AssetAction.construct == asset.action {
                        return false
                    }
                }
            }
        }
        if (buildingType != nearType) && nearAsset != nil {
            return false
        }
        if builderAsset != nil {
            var playerCapability = PlayerCapability.findCapability(buildAction) //fix
            var sourcePosition = townHallAsset.tilePosition
            var mapCenter = Position(x: playerData.playerMap.width/2, y: playerData.playerMap.height/2)
            
            
            if nearAsset != nil {
                sourcePosition = nearAsset.tilePosition
            }
            if mapCenter.x < sourcePosition.x {
                sourcePosition.decrementX(townHallAsset.size/2) //fix
            }
            else if mapCenter.x > sourcePosition.x {
                sourcePosition.incrementX(townHallAsset.size/2)
            }
            if mapCenter.y < sourcePosition.y {
                sourcePosition.decrementY(townHallAsset.size/2)
            }
            else if mapCenter.y > sourcePosition.y {
                sourcePosition.incrementY(townHallAsset.size/2)
            }
            
            var placement = playerData.findBestAssetPlacement(at: sourcePosition, builder: builderAsset, assetTypeInput: buildingType, buffer: 1)
            if placement.x > 0 {
                return searchMap(command: command)
            }
            if(playerCapability){
                if(playerCapability.canInitiate(builderAsset, playerData)){
                    if placement.x >= 0 {
                        command.action = buildAction
                        command.actors.append(builderAsset)
                        command.targetLocation.setFromTile(placement)
                        return true
                    }
                }
            }
        }
        
        return false
        
    }
    private func activatePeasants(command: PlayerCommandRequest, trainMore: Bool) -> Bool {
        var miningAsset: PlayerAsset
        var interruptibleAsset: PlayerAsset
        var townHallAsset: PlayerAsset
        var goldMiners = 0
        var lumberHarvesters = 0
        var switchToGold = false
        var switchToLumber = false
        
        for var weakAsset in playerData.assets {
            if let asset = weakAsset.lock() {
                if asset.hasCapability(AssetCapabilityType.mine) {
                    if miningAsset != nil && (AssetAction.none == asset.action ){
                        miningAsset = asset
                    }
                    
                    if asset.hasAction(AssetAction.mineGold) {
                        goldMiners += 1
                        if asset.interruptible && (AssetAction.none != asset.action ){
                            interruptibleAsset = asset
                        }
                    }
                    else if asset.hasAction(AssetAction.harvestLumber) {
                        lumberHarvesters += 1
                        if asset.interruptible && (AssetAction.none != assetaction ) {
                            interruptibleAsset = asset
                        }
                    }
                }
                if asset.hasCapability(AssetCapabilityType.buildPeasant) && (AssetAction.none == asset.action){
                    townHallAsset = asset
                }
            }
        }
        if goldMiners >= 2 && lumberHarvesters == 0 {
            switchToLumber = true
        }
        else if lumberHarvesters >= 2 && goldMiners == 0 {
            switchToGold = true
        }
        if miningAsset != nil || (interruptibleAsset && (switchToLumber != nil || switchToGold != nil)) {
            if miningAsset != nil && (miningAsset.lumber != 0 || miningAsset.gold != 0) {
                command.action = AssetCapabilityType.convey //fix
                command.targetColor = townHallAsset.color
                command.actors.append(miningAsset)
                command.targetType = townHallAsset.type
                command.targetLocation = townHallAsset.position
            }
            else {
                if miningAsset == nil {
                    miningAsset = interruptibleAsset
                }
                var goldMineAsset = playerData.findNearestAsset(at: miningAsset.position, assetType: AssetType.goldMine)
                if goldMiners != 0 && ((playerData.gold > playerData.lumber * 3) || switchToLumber != nil) {
                    var lumberLocation = playerData.playerMap.findNearestReachableTileType(at: miningAsset.tilePosition(), type: TerrainMap.tileType.tree)
                    if lumberLocation.x >= 0 {
                        command.action = AssetCapabilityType.mine
                        command.actors.append(miningAsset)
                        command.targetLocation.setFromTile(lumberLocation)
                    }
                    else{
                        return searchMap(command: command)
                    }
                }
                else{
                    command.action = AssetCapabilityType.mine
                    command.actors.append(miningAsset)
                    command.targetType = AssetType.goldMine
                    command.targetLocation = goldMineAsset?.position
                }
            }
            return true
        }
        else if townHallAsset != nil && trainmore != nil {
            var playerCapability = PlayerCapability.findCapability(AssetCapabilityType.buildPeasant)
            
            if playerCapability != nil {
                if playerCapability.canApply(townHallAsset, playerData, townHallAsset) {
                    command.action = AssetCapabilityType.buildPeasant
                    command.actors.append(townHallAsset)
                    command.targetLocation = townHallAsset.position
                    return true
                }
            }
        }
        return false
        
    }
    private func activateFighters(command: PlayerCommandRequest) -> Bool {
        var idleAssets = playerData.idleAssets
        
        for var weakAsset in idleAssets {
            if var asset = weakAsset.lock() {
                if asset.speed && (assetTypepeasant != asset.type) {
                    if !asset.hasAction(AssetAction.standGround) && !asset.hasActiveCapability(AssetCapabilityType.standGround)){
                        command.actors.append(asset)
                    }
                }
            }
        }
        if command.actors.count != 0 {
            command.action = AssetCapabilityType.standGround
            return true
        }
        return false
    }
    private func trainFootman(command: PlayerCommandRequest) -> Bool {
        auto IdleAssets = playerData->IdleAssets()
        std.shared_ptr< CPlayerAsset > TrainingAsset
        
        for(auto WeakAsset : IdleAssets){
            if(auto Asset = WeakAsset.lock()){
                if(Asset->HasCapability(AssetCapabililtyType.actBuildFootman)){
                    TrainingAsset = Asset
                    break
                }
            }
        }
        if(TrainingAsset){
            auto PlayerCapability = CPlayerCapability.FindCapability(AssetCapabililtyType.actBuildFootman)
            
            if(PlayerCapability){
                if(PlayerCapability->CanApply(TrainingAsset, playerData, TrainingAsset)){
                    command.action = AssetCapabililtyType.actBuildFootman
                    command.actors.push_back(TrainingAsset)
                    command.DTargetLocation = TrainingAsset->Position()
                    return true
                }
            }
        }
        return false
    }
    private func trainArcher(command: PlayerCommandRequest) -> Bool {
        auto IdleAssets = playerData->IdleAssets()
        std.shared_ptr< CPlayerAsset > TrainingAsset
        AssetCapabililtyType BuildType = AssetCapabililtyType.actBuildArcher
        for(auto WeakAsset : IdleAssets){
            if(auto Asset = WeakAsset.lock()){
                if(Asset->HasCapability(AssetCapabililtyType.actBuildArcher)){
                    TrainingAsset = Asset
                    BuildType = AssetCapabililtyType.actBuildArcher
                    break
                }
                if(Asset->HasCapability(AssetCapabililtyType.actBuildRanger)){
                    TrainingAsset = Asset
                    BuildType = AssetCapabililtyType.actBuildRanger
                    break
                }
                
            }
        }
        if(TrainingAsset){
            auto PlayerCapability = CPlayerCapability.FindCapability(BuildType)
            if(PlayerCapability){
                if(PlayerCapability->CanApply(TrainingAsset, playerData, TrainingAsset)){
                    command.action = BuildType
                    command.actors.push_back(TrainingAsset)
                    command.DTargetLocation = TrainingAsset->Position()
                    return true
                }
            }
        }
        return false
    }
    
    init(playerData: PlayerData, downSample: Int){
        self.playerData = playerData
        self.cycle = 0
        self.downSample = downSample
    }
    
    func calculateCommand(command: PlayerCommandRequest) -> Void {
        command.action = AssetCapabililtyType.actNone
        command.actors.clear()
        command.targetColor = EPlayerColor.pcNone
        command.targetType = AssetType.atNone
        if((DCycle % DDownSample) == 0){
            // Do decision
            
            if(0 == playerData->FoundAssetCount(AssetType.atGoldMine)){
                // Search for gold mine
                SearchMap(command)
            }
            else if((0 == playerData->PlayerAssetCount(AssetType.atTownHall))&&(0 == playerData->PlayerAssetCount(AssetType.atKeep))&&(0 == playerData->PlayerAssetCount(AssetType.atCastle))){
                BuildTownHall(command)
            }
            else if(5 > playerData->PlayerAssetCount(AssetType.atPeasant)){
                ActivatePeasants(command, true)
            }
            else if(12 > playerData->VisibilityMap()->SeenPercent(100)){
                SearchMap(command)
            }
            else{
                bool CompletedAction = false
                int BarracksCount = 0
                int FootmanCount = playerData->PlayerAssetCount(AssetType.atFootman)
                int ArcherCount = playerData->PlayerAssetCount(AssetType.atArcher)+playerData->PlayerAssetCount(AssetType.atRanger)
                
                if(!CompletedAction && (playerData->FoodConsumption() >= playerData->FoodProduction())){
                    CompletedAction = BuildBuilding(command, AssetType.atFarm, AssetType.atFarm)
                }
                if(!CompletedAction){
                    CompletedAction = ActivatePeasants(command, false)
                }
                if(!CompletedAction && (0 == (BarracksCount = playerData->PlayerAssetCount(AssetType.atBarracks)))){
                    CompletedAction = BuildBuilding(command, AssetType.atBarracks, AssetType.atFarm)
                }
                if(!CompletedAction && (5 > FootmanCount)){
                    CompletedAction = TrainFootman(command)
                }
                if(!CompletedAction && (0 == playerData->PlayerAssetCount(AssetType.atLumberMill))){
                    CompletedAction = BuildBuilding(command, AssetType.atLumberMill, AssetType.atBarracks)
                }
                if(!CompletedAction &&  (5 > ArcherCount)){
                    CompletedAction = TrainArcher(command)
                }
                if(!CompletedAction && playerData->PlayerAssetCount(AssetType.atFootman)){
                    CompletedAction = FindEnemies(command)
                }
                if(!CompletedAction){
                    CompletedAction = ActivateFighters(command)
                }
                if(!CompletedAction && ((5 <= FootmanCount) && (5 <= ArcherCount))){
                    CompletedAction = AttackEnemies(command)
                }
            }
        }
        cycle += 1
    }
}




