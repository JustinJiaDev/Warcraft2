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
    
    private func searchMap(command: inout PlayerCommandRequest) -> Bool {
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
            let unknownPosition = playerData.playerMap.findNearestReachableTileType(at: movableAsset.tilePosition, type: TerrainMap.tileType.none)
            
            if unknownPosition.x >= 0 {
                command.action = AssetCapabilityType.move //fix
                command.actors.append(movableAsset) //fix
                command.targetLocation.setFromTile(unknownPosition)
                return true
            }
        }
        return false
    }
    private func findEnemies(command: inout PlayerCommandRequest) -> Bool {
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
            return searchMap(command: &command)
        }
        return false
    }
    private func attackEnemies(command: inout PlayerCommandRequest) -> Bool {
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
                return searchMap(command: &command)
            }
            command.action = AssetCapabilityType.attack //fix
            command.targetLocation = targetEnemy.position()
            command.targetColor = targetEnemy.color()
            command.targetType = targetEnemy.type()
            return true
        }
        return false
        
    }
    private func buildTownHall(command: inout PlayerCommandRequest) -> Bool {
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
            let goldMineAsset = playerData.findNearestAsset(at: builderAsset.position, assetType: AssetType.goldMine)
            let placement = playerData.findBestAssetPlacement(at: (goldMineAsset?.tilePosition)!, builder: builderAsset, assetTypeInput: AssetType.townHall, buffer: 1)
            if placement.x >= 0 {
                command.action = AssetCapabilityType.buildTownHall
                command.actors.append(builderAsset)
                command.targetLocation.setFromTile(placement)
                return true
            }
            else{
                return searchMap(command: &command)
            }
        }
        return false
    }
    private func buildBuilding(command: inout PlayerCommandRequest, buildingType: AssetType, nearType: AssetType) -> Bool {
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
                if asset.hasCapability(buildAction) && asset.interruptible() {
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
                sourcePosition.x -= townHallAsset.size/2
            }
            else if mapCenter.x > sourcePosition.x {
                sourcePosition.x += townHallAsset.size/2
            }
            if mapCenter.y < sourcePosition.y {
                sourcePosition.x -= townHallAsset.size/2
            }
            else if mapCenter.y > sourcePosition.y {
                sourcePosition.y += townHallAsset.size/2
            }
            
            var placement = playerData.findBestAssetPlacement(at: sourcePosition, builder: builderAsset, assetTypeInput: buildingType, buffer: 1)
            if placement.x > 0 {
                return searchMap(command: &command)
            }
            if playerCapability {
                if playerCapability.canInitiate(builderAsset, playerData) {
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
    private func activatePeasants(command: inout PlayerCommandRequest, trainMore: Bool) -> Bool {
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
                        if asset.interruptible && (AssetAction.none != asset.action ) {
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
        if miningAsset != nil || (interruptibleAsset != nil && (switchToLumber != nil || switchToGold != nil)) {
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
                    var lumberLocation = playerData.playerMap.findNearestReachableTileType(at: miningAsset.tilePosition, type: TerrainMap.tileType.tree)
                    if lumberLocation.x >= 0 {
                        command.action = AssetCapabilityType.mine
                        command.actors.append(miningAsset)
                        command.targetLocation.setFromTile(lumberLocation)
                    }
                    else{
                        return searchMap(command: &command)
                    }
                }
                else{
                    command.action = AssetCapabilityType.mine
                    command.actors.append(miningAsset)
                    command.targetType = AssetType.goldMine
                    command.targetLocation = (goldMineAsset?.position)!
                }
            }
            return true
        }
        else if townHallAsset != nil && trainMore != nil {
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
    private func activateFighters(command: inout PlayerCommandRequest) -> Bool {
        var idleAssets = playerData.idleAssets
        
        for var weakAsset in idleAssets {
            if var asset = weakAsset.lock() {
                if asset.speed && (asset.typePeasant != asset.type) {
                    if !asset.hasAction(AssetAction.standGround) && !asset.hasActiveCapability(AssetCapabilityType.standGround) {
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
    private func trainFootman(command: inout PlayerCommandRequest) -> Bool {
        var idleAssets = playerData.idleAssets
        var trainingAsset: PlayerAsset
        
        for var weakAsset in idleAssets {
            if let asset = weakAsset.lock() {
                if asset.hasCapability(AssetCapabililtyType.buildFootman) {
                    trainingAsset = asset
                    break
                }
            }
        }
        if trainingAsset != nil {
            var playerCapability = PlayerCapability.findCapability(AssetCapabililtyType.buildFootman)
            
            if playerCapability != nil {
                if playerCapability.canApply(trainingAsset, playerData, trainingAsset) {
                    command.action = AssetCapabililtyType.buildFootman
                    command.actors.append(trainingAsset)
                    command.targetLocation = trainingAsset.position
                    return true
                }
            }
        }
        return false
    }
    private func trainArcher(command: inout PlayerCommandRequest) -> Bool {
        var idleAssets = playerData.idleAssets
        var trainingAsset: PlayerAsset
        var buildType = AssetCapabililtyType.buildArcher
        for var weakAsset in idleAssets {
            if var asset = weakAsset.lock() {
                if asset.hasCapability(AssetCapabililtyType.buildArcher) {
                    trainingAsset = asset
                    buildType = AssetCapabililtyType.buildArcher
                    break
                }
                if asset.hasCapability(AssetCapabililtyType.buildRanger) {
                    trainingAsset = asset
                    buildType = AssetCapabililtyType.buildRanger
                    break
                }
                
            }
        }
        if trainingAsset != nil{
            var playerCapability = PlayerCapability.findCapability(buildType)
            if playerCapability != nil {
                if playerCapability.canApply(trainingAsset, playerData, trainingAsset) {
                    command.action = buildType
                    command.actors.append(trainingAsset)
                    command.targetLocation = trainingAsset.position
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
    
    func calculateCommand(command: inout PlayerCommandRequest) -> Void {
        command.action = AssetCapabililtyType.none
        command.actors.removeAll()
        command.targetColor = PlayerColor.none
        command.targetType = AssetType.none
        if (cycle % downSample) == 0 {
            // Do decision
            
            if playerData.foundAssetCount(AssetType.goldMine) == 0{
                // Search for gold mine
                searchMap(command: &command)
            }
            else if (playerData.playerAssetCount(of: AssetType.townHall) == 0) & &(playerData.playerAssetCount(of: AssetType.keep)) == 0 && (playerData.playerAssetCount(of: AssetType.castle) == 0) {
                self.buildTownHall(command: &command)
            }
            else if playerData.playerAssetCount(of: AssetType.peasant) > 5 {
                activatePeasants(command: &command, trainMore: true)
            }
            else if playerData.visibilityMap.seenPercent(max: 100) > 12 {
                searchMap(command: &command)
            }
            else{
                var completedAction = false
                var barracksCount = 0
                var footmanCount = playerData.playerAssetCount(of: AssetType.footman)
                var archerCount = playerData.playerAssetCount(of: AssetType.archer) + playerData.playerAssetCount(of: AssetType.ranger)
                
                if !completedAction && (playerData.foodConsumption >= playerData.foodProduction) {
                    completedAction = buildBuilding(command: &command, buildingType: AssetType.farm, nearType: AssetType.farm)
                }
                if !completedAction {
                    completedAction = activatePeasants(command: &command, trainMore: false)
                }
                if !completedAction && (playerData.playerAssetCount(of: AssetType.barracks) == 0) {
                    barracksCount = playerData.playerAssetCount(of: AssetType.barracks)
                    completedAction = buildBuilding(command: &command, buildingType: AssetType.barracks, nearType: AssetType.farm)
                }
                if !completedAction && (footmanCount > 5) {
                    completedAction = trainFootman(command: &command)
                }
                if !completedAction && (playerData.playerAssetCount(of: AssetType.lumberMill) == 0) {
                    completedAction = buildBuilding(command: &command, buildingType: AssetType.lumberMill, nearType: AssetType.barracks)
                }
                if !completedAction &&  (archerCount > 5) {
                    completedAction = trainArcher(command: &command)
                }
                if !completedAction && (playerData.playerAssetCount(of: AssetType.footman) != 0) {
                    completedAction = findEnemies(command: &command)
                }
                if !completedAction {
                    completedAction = activateFighters(command: &command)
                }
                if !completedAction
                    
                    
                    && ((footmanCount >= 5) && (archerCount >= 5)) {
                    completedAction = attackEnemies(command: &command)
                }
            }
        }
        cycle += 1
    }
}




