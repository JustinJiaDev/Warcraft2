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
        
        for(auto WeakAsset : DPlayerData->Assets()){
            if let asset = weakAsset.lock {
                if(Asset->HasCapability(BuildAction) && Asset->Interruptible()){
                    if(!BuilderAsset || (!AssetIsIdle && (EAssetAction::aaNone == Asset->Action()))){
                        BuilderAsset = Asset
                        AssetIsIdle = EAssetAction::aaNone == Asset->Action()
                    }
                }
                if(Asset->HasCapability(EAssetCapabilityType::actBuildPeasant)){
                    TownHallAsset = Asset
                }
                if(Asset->HasActiveCapability(BuildAction)){
                    return false
                }
                if((neartype == Asset->Type())&&(EAssetAction::aaConstruct != Asset->Action())){
                    NearAsset = Asset
                }
                if(buildingtype == Asset->Type()){
                    if(EAssetAction::aaConstruct == Asset->Action()){
                        return false
                    }
                }
            }
        }
        if((buildingtype != neartype) && !NearAsset){
            return false
        }
        if(BuilderAsset){
            auto PlayerCapability = CPlayerCapability::FindCapability(BuildAction)
            CPosition SourcePosition = TownHallAsset->TilePosition()
            CPosition MapCenter(DPlayerData->PlayerMap()->Width()/2, DPlayerData->PlayerMap()->Height()/2)
            
            
            if(NearAsset){
                SourcePosition = NearAsset->TilePosition()
            }
            if(MapCenter.X() < SourcePosition.X()){
                SourcePosition.DecrementX(TownHallAsset->Size()/2)
            }
            else if(MapCenter.X() > SourcePosition.X()){
                SourcePosition.IncrementX(TownHallAsset->Size()/2)
            }
            if(MapCenter.Y() < SourcePosition.Y()){
                SourcePosition.DecrementY(TownHallAsset->Size()/2)
            }
            else if(MapCenter.Y() > SourcePosition.Y()){
                SourcePosition.IncrementY(TownHallAsset->Size()/2)
            }
            
            CPosition Placement = DPlayerData->FindBestAssetPlacement(SourcePosition, BuilderAsset, buildingtype, 1)
            if(0 > Placement.X()){
                return SearchMap(command)
            }
            if(PlayerCapability){
                if(PlayerCapability->CanInitiate(BuilderAsset, DPlayerData)){
                    if(0 <= Placement.X()){
                        command.DAction = BuildAction
                        command.DActors.push_back(BuilderAsset)
                        command.DTargetLocation.SetFromTile(Placement)
                        return true
                    }
                }
            }
        }
        
        return false
        
    }
    private func activatePeasants(command: PlayerCommandRequest, trainMore: Bool) -> Bool {
        
    }
    private func activateFighters(command: PlayerCommandRequest) -> Bool {
        
    }
    private func trainFootman(command: PlayerCommandRequest) -> Bool {
        
    }
    private func trainArcher(command: PlayerCommandRequest) -> Bool {
        
    }
    
    init(playerData: PlayerData, downSample: Int){
        self.playerData = playerData
        self.cycle = 0
        self.downSample = downSample
    }
    
    func calculateCommand(command: PlayerCommandRequest) -> Void {
    
    }
}

bool CAIPlayer::ActivatePeasants(SPlayerCommandRequest &command, bool trainmore){
    // Mine and build peasants
    //auto IdleAssets = DPlayerData->IdleAssets()
    std::shared_ptr< CPlayerAsset > MiningAsset
    std::shared_ptr< CPlayerAsset > InterruptibleAsset
    std::shared_ptr< CPlayerAsset > TownHallAsset
    int GoldMiners = 0
    int LumberHarvesters = 0
    bool SwitchToGold = false
    bool SwitchToLumber = false
    
    for(auto WeakAsset : DPlayerData->Assets()){
        if(auto Asset = WeakAsset.lock()){
            if(Asset->HasCapability(EAssetCapabilityType::actMine)){
                if(!MiningAsset && (EAssetAction::aaNone == Asset->Action())){
                    MiningAsset = Asset
                }
                
                if(Asset->HasAction(EAssetAction::aaMineGold)){
                    GoldMiners++
                    if(Asset->Interruptible() && (EAssetAction::aaNone != Asset->Action())){
                        InterruptibleAsset = Asset
                    }
                }
                else if(Asset->HasAction(EAssetAction::aaHarvestLumber)){
                    LumberHarvesters++
                    if(Asset->Interruptible() && (EAssetAction::aaNone != Asset->Action())){
                        InterruptibleAsset = Asset
                    }
                }
            }
            if(Asset->HasCapability(EAssetCapabilityType::actBuildPeasant) && (EAssetAction::aaNone == Asset->Action())){
                TownHallAsset = Asset
            }
        }
    }
    if((2 <= GoldMiners)&&(0 == LumberHarvesters)){
        SwitchToLumber = true
    }
    else if((2 <= LumberHarvesters)&&(0 == GoldMiners)){
        SwitchToGold = true
    }
    if(MiningAsset || (InterruptibleAsset && (SwitchToLumber || SwitchToGold))){
        if(MiningAsset && (MiningAsset->Lumber() || MiningAsset->Gold())){
            command.DAction = EAssetCapabilityType::actConvey
            command.DTargetColor = TownHallAsset->Color()
            command.DActors.push_back(MiningAsset)
            command.DTargetType = TownHallAsset->Type()
            command.DTargetLocation = TownHallAsset->Position()
        }
        else{
            if(!MiningAsset){
                MiningAsset = InterruptibleAsset
            }
            auto GoldMineAsset = DPlayerData->FindNearestAsset(MiningAsset->Position(), EAssetType::atGoldMine)
            if(GoldMiners && ((DPlayerData->Gold() > DPlayerData->Lumber() * 3) || SwitchToLumber)){
                CPosition LumberLocation = DPlayerData->PlayerMap()->FindNearestReachableTileType(MiningAsset->TilePosition(), CTerrainMap::ETileType::ttTree)
                if(0 <= LumberLocation.X()){
                    command.DAction = EAssetCapabilityType::actMine
                    command.DActors.push_back(MiningAsset)
                    command.DTargetLocation.SetFromTile(LumberLocation)
                }
                else{
                    return SearchMap(command)
                }
            }
            else{
                command.DAction = EAssetCapabilityType::actMine
                command.DActors.push_back(MiningAsset)
                command.DTargetType = EAssetType::atGoldMine
                command.DTargetLocation = GoldMineAsset->Position()
            }
        }
        return true
    }
    else if(TownHallAsset && trainmore){
        auto PlayerCapability = CPlayerCapability::FindCapability(EAssetCapabilityType::actBuildPeasant)
        
        if(PlayerCapability){
            if(PlayerCapability->CanApply(TownHallAsset, DPlayerData, TownHallAsset)){
                command.DAction = EAssetCapabilityType::actBuildPeasant
                command.DActors.push_back(TownHallAsset)
                command.DTargetLocation = TownHallAsset->Position()
                return true
            }
        }
    }
    return false
}

bool CAIPlayer::ActivateFighters(SPlayerCommandRequest &command){
    auto IdleAssets = DPlayerData->IdleAssets()
    
    for(auto WeakAsset : IdleAssets){
        if(auto Asset = WeakAsset.lock()){
            if(Asset->Speed() && (EAssetType::atPeasant != Asset->Type())){
                if(!Asset->HasAction(EAssetAction::aaStandGround) && !Asset->HasActiveCapability(EAssetCapabilityType::actStandGround)){
                    command.DActors.push_back(Asset)
                }
            }
        }
    }
    if(command.DActors.size()){
        command.DAction = EAssetCapabilityType::actStandGround
        return true
    }
    return false
}

bool CAIPlayer::TrainFootman(SPlayerCommandRequest &command){
    auto IdleAssets = DPlayerData->IdleAssets()
    std::shared_ptr< CPlayerAsset > TrainingAsset
    
    for(auto WeakAsset : IdleAssets){
        if(auto Asset = WeakAsset.lock()){
            if(Asset->HasCapability(EAssetCapabilityType::actBuildFootman)){
                TrainingAsset = Asset
                break
            }
        }
    }
    if(TrainingAsset){
        auto PlayerCapability = CPlayerCapability::FindCapability(EAssetCapabilityType::actBuildFootman)
        
        if(PlayerCapability){
            if(PlayerCapability->CanApply(TrainingAsset, DPlayerData, TrainingAsset)){
                command.DAction = EAssetCapabilityType::actBuildFootman
                command.DActors.push_back(TrainingAsset)
                command.DTargetLocation = TrainingAsset->Position()
                return true
            }
        }
    }
    return false
}

bool CAIPlayer::TrainArcher(SPlayerCommandRequest &command){
    auto IdleAssets = DPlayerData->IdleAssets()
    std::shared_ptr< CPlayerAsset > TrainingAsset
    EAssetCapabilityType BuildType = EAssetCapabilityType::actBuildArcher
    for(auto WeakAsset : IdleAssets){
        if(auto Asset = WeakAsset.lock()){
            if(Asset->HasCapability(EAssetCapabilityType::actBuildArcher)){
                TrainingAsset = Asset
                BuildType = EAssetCapabilityType::actBuildArcher
                break
            }
            if(Asset->HasCapability(EAssetCapabilityType::actBuildRanger)){
                TrainingAsset = Asset
                BuildType = EAssetCapabilityType::actBuildRanger
                break
            }
            
        }
    }
    if(TrainingAsset){
        auto PlayerCapability = CPlayerCapability::FindCapability(BuildType)
        if(PlayerCapability){
            if(PlayerCapability->CanApply(TrainingAsset, DPlayerData, TrainingAsset)){
                command.DAction = BuildType
                command.DActors.push_back(TrainingAsset)
                command.DTargetLocation = TrainingAsset->Position()
                return true
            }
        }
    }
    return false
}


void CAIPlayer::CalculateCommand(SPlayerCommandRequest &command){
    command.DAction = EAssetCapabilityType::actNone
    command.DActors.clear()
    command.DTargetColor = EPlayerColor::pcNone
    command.DTargetType = EAssetType::atNone
    if((DCycle % DDownSample) == 0){
        // Do decision
        
        if(0 == DPlayerData->FoundAssetCount(EAssetType::atGoldMine)){
            // Search for gold mine
            SearchMap(command)
        }
        else if((0 == DPlayerData->PlayerAssetCount(EAssetType::atTownHall))&&(0 == DPlayerData->PlayerAssetCount(EAssetType::atKeep))&&(0 == DPlayerData->PlayerAssetCount(EAssetType::atCastle))){
            BuildTownHall(command)
        }
        else if(5 > DPlayerData->PlayerAssetCount(EAssetType::atPeasant)){
            ActivatePeasants(command, true)
        }
        else if(12 > DPlayerData->VisibilityMap()->SeenPercent(100)){
            SearchMap(command)
        }
        else{
            bool CompletedAction = false
            int BarracksCount = 0
            int FootmanCount = DPlayerData->PlayerAssetCount(EAssetType::atFootman)
            int ArcherCount = DPlayerData->PlayerAssetCount(EAssetType::atArcher)+DPlayerData->PlayerAssetCount(EAssetType::atRanger)
            
            if(!CompletedAction && (DPlayerData->FoodConsumption() >= DPlayerData->FoodProduction())){
                CompletedAction = BuildBuilding(command, EAssetType::atFarm, EAssetType::atFarm)
            }
            if(!CompletedAction){
                CompletedAction = ActivatePeasants(command, false)
            }
            if(!CompletedAction && (0 == (BarracksCount = DPlayerData->PlayerAssetCount(EAssetType::atBarracks)))){
                CompletedAction = BuildBuilding(command, EAssetType::atBarracks, EAssetType::atFarm)
            }
            if(!CompletedAction && (5 > FootmanCount)){
                CompletedAction = TrainFootman(command)
            }
            if(!CompletedAction && (0 == DPlayerData->PlayerAssetCount(EAssetType::atLumberMill))){
                CompletedAction = BuildBuilding(command, EAssetType::atLumberMill, EAssetType::atBarracks)
            }
            if(!CompletedAction &&  (5 > ArcherCount)){
                CompletedAction = TrainArcher(command)
            }
            if(!CompletedAction && DPlayerData->PlayerAssetCount(EAssetType::atFootman)){
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
    DCycle++
}

