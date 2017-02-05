//
//  UnitActionRenderer.swift
//  Warcraft2
//
//  Created by Michelle Lee on 2/3/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class UnitActionRenderer{
    private var iconTileset: GraphicTileset
    private var bevel: Bevel
    private var playerData: PlayerData
    private var commandIndices: [Int]
    private var displayedCommands: [AssetCapabilityType]
    private var playerColor: PlayerColor
    private var fullIconWidth: Int
    private var fullIconHeight: Int
    private var disabledIndex: Int
    
    init(bevelParam: Bevel, icons: GraphicTileset, color: PlayerColor, player: PlayerData){
        iconTileset = icons
        bevel = bevelParam
        playerData = player
        playerColor = color
        
        commandIndices = Array(repeating: AssetCapabilityType.none.rawValue, count: AssetCapabilityType.max.rawValue)
        fullIconWidth = iconTileset.tileWidth + bevel.width * 2
        fullIconHeight = iconTileset.tileHeight + bevel.width * 2
        displayedCommands = Array(repeating: AssetCapabilityType.none, count: 9)
        
        commandIndices[AssetCapabilityType.none.rawValue] = -1
        commandIndices[AssetCapabilityType.buildPeasant.rawValue] = iconTileset.findTile(with: "peasant")
        commandIndices[AssetCapabilityType.buildFootman.rawValue] = iconTileset.findTile(with: "footman")
        commandIndices[AssetCapabilityType.buildArcher.rawValue] = iconTileset.findTile(with: "archer")
        commandIndices[AssetCapabilityType.buildRanger.rawValue] = iconTileset.findTile(with: "ranger")
        commandIndices[AssetCapabilityType.buildFarm.rawValue] = iconTileset.findTile(with: "chicken-farm")
        commandIndices[AssetCapabilityType.buildTownHall.rawValue] = iconTileset.findTile(with: "town-hall")
        commandIndices[AssetCapabilityType.buildBarracks.rawValue] = iconTileset.findTile(with: "human-barracks")
        commandIndices[AssetCapabilityType.buildLumberMill.rawValue] = iconTileset.findTile(with: "human-lumber-mill")
        commandIndices[AssetCapabilityType.buildBlacksmith.rawValue] = iconTileset.findTile(with: "human-blacksmith")
        commandIndices[AssetCapabilityType.buildKeep.rawValue] = iconTileset.findTile(with: "keep")
        commandIndices[AssetCapabilityType.buildCastle.rawValue] = iconTileset.findTile(with: "castle")
        commandIndices[AssetCapabilityType.buildScoutTower.rawValue] = iconTileset.findTile(with: "scout-tower")
        commandIndices[AssetCapabilityType.buildGuardTower.rawValue] = iconTileset.findTile(with: "human-guard-tower")
        commandIndices[AssetCapabilityType.buildCannonTower.rawValue] = iconTileset.findTile(with: "human-cannon-tower")
        commandIndices[AssetCapabilityType.move.rawValue] = iconTileset.findTile(with: "human-move")
        commandIndices[AssetCapabilityType.repair.rawValue] = iconTileset.findTile(with: "repair")
        commandIndices[AssetCapabilityType.mine.rawValue] = iconTileset.findTile(with: "mine")
        commandIndices[AssetCapabilityType.buildSimple.rawValue] = iconTileset.findTile(with: "build-simple")
        commandIndices[AssetCapabilityType.buildAdvanced.rawValue] = iconTileset.findTile(with: "build-advanced")
        commandIndices[AssetCapabilityType.convey.rawValue] = iconTileset.findTile(with: "human-convey")
        commandIndices[AssetCapabilityType.cancel.rawValue] = iconTileset.findTile(with: "cancel")
        commandIndices[AssetCapabilityType.buildWall.rawValue] = iconTileset.findTile(with: "human-wall")
        commandIndices[AssetCapabilityType.attack.rawValue] = iconTileset.findTile(with: "human-weapon-1")
        commandIndices[AssetCapabilityType.standGround.rawValue] = iconTileset.findTile(with: "human-armor-1")
        commandIndices[AssetCapabilityType.patrol.rawValue] = iconTileset.findTile(with: "human-patrol")
        commandIndices[AssetCapabilityType.weaponUpgrade1.rawValue] = iconTileset.findTile(with: "human-weapon-1")
        commandIndices[AssetCapabilityType.weaponUpgrade2.rawValue] = iconTileset.findTile(with: "human-weapon-2")
        commandIndices[AssetCapabilityType.weaponUpgrade3.rawValue] = iconTileset.findTile(with: "human-weapon-3")
        commandIndices[AssetCapabilityType.arrowUpgrade1.rawValue] = iconTileset.findTile(with: "human-arrow-1")
        commandIndices[AssetCapabilityType.arrowUpgrade2.rawValue] = iconTileset.findTile(with: "human-arrow-2")
        commandIndices[AssetCapabilityType.arrowUpgrade3.rawValue] = iconTileset.findTile(with: "human-arrow-3")
        commandIndices[AssetCapabilityType.armorUpgrade1.rawValue] = iconTileset.findTile(with: "human-armor-1")
        commandIndices[AssetCapabilityType.armorUpgrade2.rawValue] = iconTileset.findTile(with: "human-armor-2")
        commandIndices[AssetCapabilityType.armorUpgrade3.rawValue] = iconTileset.findTile(with: "human-armor-3")
        commandIndices[AssetCapabilityType.longbow.rawValue] = iconTileset.findTile(with: "longbow")
        commandIndices[AssetCapabilityType.rangerScouting.rawValue] = iconTileset.findTile(with: "ranger-scouting")
        commandIndices[AssetCapabilityType.marksmanship.rawValue] = iconTileset.findTile(with: "marksmanship")
        
        disabledIndex = iconTileset.findTile(with: "disabled")
    }
    
    
    func minimumWidth() -> Int {
        return fullIconWidth * 3 + bevel.width * 2
    }
    
    func minimumHeight() -> Int {
        return fullIconHeight * 3 + bevel.width * 2
    }
    
    func selection(position: Position) -> AssetCapabilityType{
        if(((position.x % (fullIconWidth + bevel.width)) < fullIconWidth) && ((position.y % (fullIconWidth + bevel.width)) < fullIconHeight)){
            let index = (position.x / (fullIconWidth + bevel.width)) + (position.y / (fullIconHeight + bevel.width)) * 3
            return displayedCommands[index]
        }
        return AssetCapabilityType.none
    }
    
    func drawUnitAction(surface: GraphicSurface,  selectionlist: [PlayerAsset], currentaction: AssetCapabilityType){
        var allSame = true
        var isFirst = true
        var moveable = true
        var hasCargo = false
        var unitType = AssetType.none
        
        displayedCommands = Array(repeating: AssetCapabilityType.none, count: 9)
        
        if(selectionlist.count == 0){
            return
        }
        
        for asset in selectionlist{
            if(playerColor != asset.color){
                return
            }
            if(isFirst){
                unitType = asset.type
                isFirst = false
                moveable = 0 < asset.speed
            }
            else if(unitType != asset.type){
                allSame = false
            }
            if((asset.lumber != 0) || (asset.gold != 0)){
                hasCargo = true
            }

        } //for loop
        
        if(AssetCapabilityType.none == currentaction){
            if(moveable){
                displayedCommands[0] = hasCargo ? AssetCapabilityType.convey : AssetCapabilityType.move
                displayedCommands[1] = AssetCapabilityType.standGround
                displayedCommands[2] = AssetCapabilityType.attack
                
                let asset = selectionlist.first
                if(asset?.hasCapability(AssetCapabilityType.repair))!{
                    displayedCommands[3] = AssetCapabilityType.repair
                }
                if(asset?.hasCapability(AssetCapabilityType.patrol))!{
                    displayedCommands[3] = AssetCapabilityType.patrol
                }
                if(asset?.hasCapability(AssetCapabilityType.mine))!{
                    displayedCommands[4] = AssetCapabilityType.mine
                }
                if((asset?.hasCapability(AssetCapabilityType.buildSimple))! && (1 == selectionlist.count)){
                    displayedCommands[6] = AssetCapabilityType.buildSimple
                }
            }
            else {
                let asset = selectionlist.first
                if((AssetAction.construct == asset?.action) || (AssetAction.capability == asset?.action)){
                    displayedCommands[displayedCommands.count - 1] = AssetCapabilityType.cancel
                }
                else{
                    var index = 0
                    for capability in (asset?.capabilities)!{
                        displayedCommands[index] = capability
                        index += 1
                        if(displayedCommands.count <= index){
                            break
                        }
                    }
                }
            }
        }
        else if(AssetCapabilityType.buildSimple == currentaction){
            let asset = selectionlist.first
            var index = 0
            for capability in [AssetCapabilityType.buildFarm, AssetCapabilityType.buildTownHall, AssetCapabilityType.buildBarracks, AssetCapabilityType.buildLumberMill, AssetCapabilityType.buildBlacksmith, AssetCapabilityType.buildKeep, AssetCapabilityType.buildCastle, AssetCapabilityType.buildScoutTower, AssetCapabilityType.buildGuardTower, AssetCapabilityType.buildCannonTower]{
                
                if(asset?.hasCapability(capability))!{
                    displayedCommands[index] = capability
                    index += 1
                    if(displayedCommands.count <= index){
                        break
                    }
                }
            }
            displayedCommands[displayedCommands.count - 1] = AssetCapabilityType.cancel
        }
        else{
            displayedCommands[displayedCommands.count - 1] = AssetCapabilityType.cancel
        }
        
        var xOffset = bevel.width
        var yOffset = bevel.width
        var index = 0
        //var playerCapability:PlayerCapability
        
        for iconType in displayedCommands{
            if(AssetCapabilityType.none != iconType){
                let playerCapability = PlayerCapability.findCapability(type: iconType)
                do{
                    try bevel.drawBevel(on: surface, x: xOffset, y: yOffset, width: iconTileset.tileWidth, height: iconTileset.tileHeight)
                    try iconTileset.drawTile(on: surface, x: xOffset, y: yOffset, index: commandIndices[iconType.rawValue])
                } catch {
                    print(error)
                }
                
                if(playerCapability.targetType != PlayerCapability.TargetType.none){    //not too sure
                    if(!playerCapability.canInitiate(actor: selectionlist.first!, playerData: playerData)){
                        do{
                            try iconTileset.drawTile(on: surface, x: xOffset, y: yOffset, index: disabledIndex)
                        } catch{
                            print(error)
                        }
                    }
                }
            }
            
            xOffset += fullIconWidth + bevel.width
            index += 1
            if(0 == (index % 3)){
                xOffset = bevel.width
                yOffset += fullIconHeight + bevel.width
            }
        }
        
    }
}
