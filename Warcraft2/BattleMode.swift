import Foundation

class BattleMode: ApplicationMode{
    func initiliazeChange(context:ApplicationData){
        context->loadGameMap(context->selectedMapIndex)
        context->soundLibraryMixer->playSong(context->soundLibraryMixer->findSong("game1"), context->musicVolume)
    }
    
    func input(context:ApplicationData){
        var currentX:Int
        var currentY:Int
        let panning = false
        let shiftPressed = false
        var panningDirection = Direction.max
        
        currentX = context->x
        currentY = context->y
        
        context->GameModel->clearGameEvents()
        for key in context->pressedKeys {
            if(GUIKeyType.upArrow == key){
                panningDirection = Direction.north
                panning = true
            }else if(GUIKeyType.downArrow == key){
                panningDirection = Direction.south
                panning = true
            }else if(GUIKeyType.leftArrow == key){
                panningDirection = Direction.west
                panning = true
            }else if(GUIKeyType.leftShift == key || GUIKeyType.rightShift == key){
                shiftPressed = true
            }
        }
        
        for key in context->releasedKeys {
            if context->selectedPlayerAssets.size {
                let canMove = true
                for asset in context->selectedPlayerAssets{
                    if lockedAsset = asset.lock{
                        if 0 == lockedAsset->speed{
                            canMove = false
                            break
                        }
                    }
                }
                
                if GUIKeyType.escape == key {
                    context->currentAssetCapability = AssetCapabilityType.actNone
                }
                if AssetCapabilityType.actBuildSimple == context->currentAssetCapability{
                    let keyLookUp = context->buildHotKeyMap.find(key)
                    if keyLookUp != context->buildHotKeyMap.end() {
                        let PlayerCapability = PlayerCapability.findCapability(keyLookUp->second)
                        
                        if PlayerCapability{
                            let actorTarget = context->selectedPlayerAssets.front().lock()
                            if PlayerCapability->canInitiate(actorTarget,context->GameModel->Player(context->PlayerColor)){
                                var tempEvent:GameEvent
                                tempEvent.type = EventType.buttonTick
                                context->GameModel->Player(context->PlayerColor)->addGameEvent(tempEvent)
                                context->currentAssetCapability = keyLookUp->second
                            }
                        }
                        
                    }
                }else if canMove{
                    keyLookUp = context->unitHotKeyMap.find(key)
                    
                    if keyLookUp != context->unitHotKeyMap.end(){
                        let hasCapability = true
                        for asset in context->selectedPlayerAssets{
                            if lockedAsset = asset.lock(){
                                if lockedAsset->hasCapability(keyLookUp->second) != nil{
                                    hasCapability = false
                                    break
                                }
                            }
                        }
                        if hasCapability{
                            let PlayerCapability = PlayerCapability.findCapability(keyLookUp->second)
                            var tempEvent:GameEvent
                            tempEvent.type = EventType.buttonTick
                            context->GameModel->Player(context->PlayerColor)->addGameEvent(tempEvent)
                            
                            if playerCapability {
                                if PlayerCapability.TargetType.none == PlayerCapability->targetType || PlayerCapability.TargetType.player == PlayerCapability->targetType{
                                    let actorTarget = context->selectedPlayerAssets.front.lock
                                    if PlayerCapability->canApply(actorTarget, context->gameModel->player(context->playerColor),actorTarget){
                                        context->playerCommands.playerColor.action = keyLookUp->second
                                        context->playerCommands->playerColor.actors = context->selectedPlayerAssets
                                        context->playerCommands.playerColor.targetColor = Eplayer.pcNone
                                        context->playerCommands->playerColor.targetType = AssetType.none
                                        context->playerCommands->playerColor.targetLocation = actorTarget->tilePosition
                                        context->currentAssetCapability = AssetCapabilityType.actNone
                                    }
                                }else {
                                    context->currentAssetCapability = keyLookUp->second
                                }
                            }else {
                                context->currentAssetCapability = keyLookUp->second
                            }
                        }
                    }
                }else {
                    let keyLookUp = context->trainHotkeyMap.find(key)
                    
                    if keyLookUp != context->trainHotKeyMap.end(){
                        let hasCapability = true
                        for asset in context->selectedPlayerAssets{
                            if lockedAsset = asset.lock{
                                if lockedAsset->hasCapability(keyLookUp->second)!=nil{
                                    hasCapability = false
                                    break
                                }
                            }
                        }
                        if hasCapability {
                            let playerCapablity = PlayerCapability.findCapability(with:keyLookUp->second)
                            var tempEvent:GameEvent
                            tempEvent.type = EventType.buttonTick
                            context->gameModel->player(context->playerColor)->addGameEvent(tempEvent)
                            
                            if playerCapability{
                                if PlayerCapability.TargetType.none == playerCapablity->targetType || PlayerCapability.TargetType.player == playerCapability->targetType{
                                    
                                    let actorTarget = context->selectedPlayerAssets.front().lock
                                    
                                    if playerCapablity>canApply(actorTarget,context->gameModel->Player(context->playerColor),actorTarget){
                                        context->playerCommands[context->playerColor].ction = keyLookUpSecond
                                        context->playerCommands[context->playerColor].actors = context->selectedPlayerAssets
                                        context->playerCommands[context->playerColor].targetColor = PlayerColor.none
                                        context->playerCommands[context->playerColor].targetType = AssetType.none
                                        context->playerCommands[context->playerColor].targetLocation = actorTarget->tilePosition
                                        context->currentAssetCapability = AssetCapabilityType.none
                                    }
                                }else {
                                    context->currentAssetCapability = keyLookUp->second
                                }
                            }else{
                                context->currentAssetCapability = keyLookUp->second
                            }
                        }
                    }
                }
                
            }
        }
        context->releasedKeys.clear()
        context->menuButtonState = .none
        //fix this line
        let componentType = context->findUIComponentType(Position(x,y))
        
        if ApplicationData.viewPort == componentType{
            let tempPosition = context->screenToDetaildMap(Position(x,y))
            let viewPortPosition = context->screenToViewPort(Position(x,y))
            let pixelType = getPixelType(context->viewPortTypeSurface,viewPortPosition)
            if context->rightClick && context->rightDown!=nil && context->selectedPlayerAssets.size(){
                let canMove = true
                
                for asset in context->selectedPlayerAssets{
                    if lockedAsset = asset.lock{
                        if 0 == lockedAsset->speed{
                            canMove = false
                            break
                        }
                    }
                }
                if canMove{
                    if PlayerColor.none != pixelType.color(){
                        context->playerCommands[context->playerColor].action = AssetCapabilityType.actMove
                        context->playerCommands[context->playerColor].targetColor = pixelType.color()
                        context->playerCommands[context->playerColor].targetType = pixelType.assetType()
                        context->playerCommands[context->playerColor].actors = context->selectedPlayerAssets
                        context->playerCommands[context->playerColor].targetLocation = tempPosition
                        
                        if pixelType.color == contextPlayerColor{
                            let haveLumber = false
                            let haveGold = false
                            
                            for asset in context->selectedPlayerAssets{
                                if lockedAsset = asset.lock{
                                    if lockedAsset->lumber(){
                                        haveLumber = true
                                    }
                                    if lockedAsset->gold(){
                                        haveGold = true
                                    }
                                }
                            }
                            if haveGold{
                                if AssetType.townHall == context->playerCommands[context->playerColor].targetType || AssetType.keep == context->playerCommands[context->playerColor].targetType || AssetType.castle == context->playerCommands[context->playerColor].targetType{
                                    context->playerCommands[context->playerColor].action = AssetCapabilityType.convey
                                }
                            }else if haveLumber{
                                if AssetType.townHall == context->playerCommands[context->playerColor].targetType || AssetType.keep == context->playerCommands[context->playerColor].targetType || AssetType.castle == context->playerCommands[context->playerColor].targetType || AssetType.lumberMill == context->playerCommands[context->playerColor].targetType{
                                    context->playerCommands[context->playerColor].action = AssetCapabilityType.convey
                                }
                            }else{
                                let targetAsset = 0
                            }
                        }
                    }
                }
            }
        }
    }
    
}
