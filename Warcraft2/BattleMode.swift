// import Foundation
//
// class BattleMode: ApplicationMode{
//    func initiliazeChange(context:ApplicationData){
//        context->loadGameMap(context->selectedMapIndex)
//        context->soundLibraryMixer->playSong(context->soundLibraryMixer->findSong("game1"), context->musicVolume)
//    }
//
//    func input(context:ApplicationData){
//        var currentX:Int
//        var currentY:Int
//        let panning = false
//        let shiftPressed = false
//        var panningDirection = Direction.max
//
//        currentX = context->x
//        currentY = context->y
//
//        context->GameModel->clearGameEvents()
//        for key in context->pressedKeys {
//            if(GUIKeyType.upArrow == key){
//                panningDirection = Direction.north
//                panning = true
//            }else if(GUIKeyType.downArrow == key){
//                panningDirection = Direction.south
//                panning = true
//            }else if(GUIKeyType.leftArrow == key){
//                panningDirection = Direction.west
//                panning = true
//            }else if(GUIKeyType.leftShift == key || GUIKeyType.rightShift == key){
//                shiftPressed = true
//            }
//        }
//
//        for key in context->releasedKeys {
//            if context->selectedPlayerAssets.size {
//                let canMove = true
//                for asset in context->selectedPlayerAssets{
//                    if lockedAsset = asset.lock{
//                        if 0 == lockedAsset->speed{
//                            canMove = false
//                            break
//                        }
//                    }
//                }
//
//                if GUIKeyType.escape == key {
//                    context->currentAssetCapability = AssetCapabilityType.actNone
//                }
//                if AssetCapabilityType.actBuildSimple == context->currentAssetCapability{
//                    let keyLookUp = context->buildHotKeyMap.find(key)
//                    if keyLookUp != context->buildHotKeyMap.end() {
//                        let PlayerCapability = PlayerCapability.findCapability(keyLookUp->second)
//
//                        if PlayerCapability{
//                            let actorTarget = context->selectedPlayerAssets.front().lock()
//                            if PlayerCapability->canInitiate(actorTarget,context->GameModel->Player(context->PlayerColor)){
//                                var tempEvent:GameEvent
//                                tempEvent.type = EventType.buttonTick
//                                context->GameModel->Player(context->PlayerColor)->addGameEvent(tempEvent)
//                                context->currentAssetCapability = keyLookUp->second
//                            }
//                        }
//
//                    }
//                }else if canMove{
//                    keyLookUp = context->unitHotKeyMap.find(key)
//
//                    if keyLookUp != context->unitHotKeyMap.end(){
//                        let hasCapability = true
//                        for asset in context->selectedPlayerAssets{
//                            if lockedAsset = asset.lock(){
//                                if lockedAsset->hasCapability(keyLookUp->second) != nil{
//                                    hasCapability = false
//                                    break
//                                }
//                            }
//                        }
//                        if hasCapability{
//                            let playerCapability = PlayerCapability.findCapability(keyLookUp->second)
//                            var tempEvent:GameEvent
//                            tempEvent.type = EventType.buttonTick
//                            context->GameModel->Player(context->PlayerColor)->addGameEvent(tempEvent)
//
//                            if playerCapability {
//                                if PlayerCapability.TargetType.none == PlayerCapability->targetType || PlayerCapability.TargetType.player == PlayerCapability->targetType{
//                                    let actorTarget = context->selectedPlayerAssets.front.lock
//                                    if PlayerCapability->canApply(actorTarget, context->gameModel->player(context->playerColor),actorTarget){
//                                        context->playerCommands.playerColor.action = keyLookUp->second
//                                        context->playerCommands->playerColor.actors = context->selectedPlayerAssets
//                                        context->playerCommands.playerColor.targetColor = Eplayer.pcNone
//                                        context->playerCommands->playerColor.targetType = AssetType.none
//                                        context->playerCommands->playerColor.targetLocation = actorTarget->tilePosition
//                                        context->currentAssetCapability = AssetCapabilityType.actNone
//                                    }
//                                }else {
//                                    context->currentAssetCapability = keyLookUp->second
//                                }
//                            }else {
//                                context->currentAssetCapability = keyLookUp->second
//                            }
//                        }
//                    }
//                }else {
//                    let keyLookUp = context->trainHotkeyMap.find(key)
//
//                    if keyLookUp != context->trainHotKeyMap.end(){
//                        let hasCapability = true
//                        for asset in context->selectedPlayerAssets{
//                            if lockedAsset = asset.lock{
//                                if lockedAsset->hasCapability(keyLookUp->second)!=nil{
//                                    hasCapability = false
//                                    break
//                                }
//                            }
//                        }
//                        if hasCapability {
//                            let playerCapablity = PlayerCapability.findCapability(with:keyLookUp->second)
//                            var tempEvent:GameEvent
//                            tempEvent.type = EventType.buttonTick
//                            context->gameModel->player(context->playerColor)->addGameEvent(tempEvent)
//
//                            if playerCapability{
//                                if PlayerCapability.TargetType.none == playerCapablity->targetType || PlayerCapability.TargetType.player == playerCapability->targetType{
//
//                                    let actorTarget = context->selectedPlayerAssets.front().lock
//
//                                    if playerCapablity>canApply(actorTarget,context->gameModel->Player(context->playerColor),actorTarget){
//                                        context->playerCommands[context->playerColor].ction = keyLookUpSecond
//                                        context->playerCommands[context->playerColor].actors = context->selectedPlayerAssets
//                                        context->playerCommands[context->playerColor].targetColor = PlayerColor.none
//                                        context->playerCommands[context->playerColor].targetType = AssetType.none
//                                        context->playerCommands[context->playerColor].targetLocation = actorTarget->tilePosition
//                                        context->currentAssetCapability = AssetCapabilityType.none
//                                    }
//                                }else {
//                                    context->currentAssetCapability = keyLookUp->second
//                                }
//                            }else{
//                                context->currentAssetCapability = keyLookUp->second
//                            }
//                        }
//                    }
//                }
//
//            }
//        }
//        context->releasedKeys.clear()
//        context->menuButtonState = .none
//        //fix this line
//        let componentType = context->findUIComponentType(Position(x,y))
//
//        if ApplicationData.viewPort == componentType{
//            let tempPosition = context->screenToDetaildMap(Position(x,y))
//            let viewPortPosition = context->screenToViewPort(Position(x,y))
//            let pixelType = getPixelType(context->viewPortTypeSurface,viewPortPosition)
//            if context->rightClick && context->rightDown!=nil && context->selectedPlayerAssets.size(){
//                let canMove = true
//
//                for asset in context->selectedPlayerAssets{
//                    if lockedAsset = asset.lock{
//                        if 0 == lockedAsset->speed{
//                            canMove = false
//                            break
//                        }
//                    }
//                }
//                if canMove{
//                    if PlayerColor.none != pixelType.color(){
//                        context->playerCommands[context->playerColor].action = AssetCapabilityType.actMove
//                        context->playerCommands[context->playerColor].targetColor = pixelType.color()
//                        context->playerCommands[context->playerColor].targetType = pixelType.assetType()
//                        context->playerCommands[context->playerColor].actors = context->selectedPlayerAssets
//                        context->playerCommands[context->playerColor].targetLocation = tempPosition
//
//                        if pixelType.color == contextPlayerColor{
//                            let haveLumber = false
//                            let haveGold = false
//
//                            for asset in context->selectedPlayerAssets{
//                                if lockedAsset = asset.lock{
//                                    if lockedAsset->lumber(){
//                                        haveLumber = true
//                                    }
//                                    if lockedAsset->gold(){
//                                        haveGold = true
//                                    }
//                                }
//                            }
//                            if haveGold{
//                                if AssetType.townHall == context->playerCommands[context->playerColor].targetType || AssetType.keep == context->playerCommands[context->playerColor].targetType || AssetType.castle == context->playerCommands[context->playerColor].targetType{
//                                    context->playerCommands[context->playerColor].action = AssetCapabilityType.convey
//                                }
//                            }else if haveLumber{
//                                if AssetType.townHall == context->playerCommands[context->playerColor].targetType || AssetType.keep == context->playerCommands[context->playerColor].targetType || AssetType.castle == context->playerCommands[context->playerColor].targetType || AssetType.lumberMill == context->playerCommands[context->playerColor].targetType{
//                                    context->playerCommands[context->playerColor].action = AssetCapabilityType.convey
//                                }
//                            }else{
//                                let targetAsset = context->gameModel->Player(context->playerColor)->selectAsset(tempPosition,pixelType.AssetType().lock)
//                                if 0 == targetAsset->speed() && (targetAsset->maxHitPoints() > targetAsset->hitPoints()){
//                                    context->playerCommands[(context->playerColor)].action = AssetCapabilityType.repair
//                                }
//                            }
//                        }else{
//                            context->playerCommands[context->playerColor].action = AssetCapabilityType.attack
//                        }
//                        context->currentAssetCapability = AssetCapabilityType.none
//                    }else{
//                        let tempPosition = 0 //need to port this line
//                        let canHarvest = true
//                        context->playerCommands[context->playerColor].action = AssetCapabillityType.move
//                        context->playerCommands[context->playerColor].targetColor = PlayerColor.none
//                        context->playerCommands[context->playerColor].targetType = AssetType.none
//                        context->playerCommands[context->playerColor].actors = context->selectedPlayerAssets
//                        context->playerCommands[context->playerColor].targetLocation = tempPosition
//
//                        for asset: context->selectedPlayerAssets{
//                            if lockedAsset = asset.lock{
//                                if lockedAsset->hasCapability(AssetCapabilityType.mine){
//                                    canHarvest = false
//                                    break
//                                }
//                            }
//                        }
//                        if canHarvest{
//                            if PixelType.AssetTerrainType.tree == PixelType.type{
//                                let tempTilePosition: Position
//                                context->playerCommands[context->playerColor].action = AssetCapabilityType.mine
//                                tempTilePosition.setToTile(context->playerCommands[context->playerColor].targetLocation)
//                                if TerrainMap.TileType.tree != context->gameModel->Player(context->PlayerColor)->PlayerMap()->Tiletype(tempTilePosition){
//                                    tempTilePosition.increamentY(1)
//                                    ifTerrain.Tiletype.tree == context->gameModel->Player(context->PlayerColor)->playerMap()->TileType(tempTilePosition){
//                                        context->PlayerCommands[context->PlayerColor].TargetLocation.setFromTile(tempTilePosition)
//                                    }
//                                }
//                            }else if PixelType.AssetTerrainType.goldMine == PixelType.Type(){
//                                context->PlayerCommands[context->playerColor].action = AssetCapabilityType.mine
//                                context->PlayerCommands[context->PlayerColor].targetType = AssetType.goldMine
//                            }
//                        }
//                        context->currentAssetCapability = AssetCapabilityType.none
//                    }
//                }
//            }else if context->leftClick{
//                if AssetCapabilityType.none == context->currentAssetCapability || AssetCapabilityType.buildSimple == context->currentAssetCapability{
//                    if context->leftDown{
//                        context->mouseDown = tempPosition
//                    }else {
//                        let tempRectangle:Rectangle
//                        let searchColor: PlayerColor = context->PlayerColor
//
//                        for weakAsset: context->selectedPlayerAssets{
//                            if lockedAsset = weakAsset.lock{
//                                previousSelection.push_back(lockedAsset)
//                            }
//                        }
//                        tempRectangle.xPosition = context->mouseDown
//                        tempRectangle.yPosition = context->mouseDown
//                        tempRectangle.width = context->mouseDown
//                        tempRectangle.height = context->mouseDown
//
//                        if tempRectangle.width < Position.tileWidth || tempRectangle.height < Position.tileHeight || 2 == context->leftClick {
//                            tempRectangle.xPosition = tempPosition.x
//                            tempRectangle.yPosition = tempPosition.y
//                            tempRectangle.width = 0
//                            tempRectangle.height = 0
//                            searchColor = PixelType.color
//                        }
//                        if searchColor != context->playerColor{
//                            context->selectedPlayerAssets.clear
//                        }
//                        if shiftPressed {
//                            if !context->selectedPlayerAssets.empty{
//                                if tempAsset = context->selectedPlayerAssets.front.lock{
//                                    if tempAsset->color != context->playerColor{
//                                        context->selectedPlayerAssets.clear
//                                    }
//                                }
//                            }
//                            context->selectedPlayerAssets.splice(context->selectedPlayerAssets.end, context->gameModel->Player(searchColor)->selectAssets(tempRectangle, PixelType.assetType, 2 == context->leftClick))
//                            context->selectedPlayerAssets.sort(PlayerAssets)
//                            context->selectedPlayerAssets.unique(PlayerAssets)
//                        }else {
//                            previousSelections.clear()
//                            context->selectedPlayerAssets = context->gameModel->Player(searchColor)->selectAssets(tempRectangle, PixelType.AssetType(), 2 == context->leftClick)
//                        }
//                        for weakAsset: context->selectedPlayerAssets{
//                            if lockedAsset = weakAsset.lock{
//                                let foundPrevious = false
//                                for prevAsst: previousSelections{
//                                    if prevAsset == lockedAsset{
//                                        foundPrevious = true
//                                        break
//                                    }
//                                }if !foundPrevious{
//                                    let tempEvent:GameEvent
//                                    tempEvent.type = EventType.selection
//                                    tempEvent.asset = lockedAsset
//                                    context->GameModel->Player(context->player)->addGameEvent(tempEvent)
//                                }
//                            }
//                        }
//                        context->mouseDown = Position(-1,-1)
//                    }
//                    context->currentAssetCapability = AssetCapabilityType.none
//                }else {
//                    let PlayerCapability = PlayerCapability.findCapability(context->currentAssetCapability)
//                    if PlayerCapability && !context->leftDown{
//                        if PlayerCapability.TargetType.asset == PlayerCapability->TargetType || PlayerCapability.TargetType.TerrainOrAsset == PlayerCapability->TargetType && AssetType.none != PixelType.AssetType{
//                            let newTarget = context->gameModel->Player(PixelType.Color())->SelectAsset(tempPosition, PixelType.AssetType().lock()
//
//                            if PlayerCapability->canApply(context->DSelectedPlayerAssets.front().lock(), context->gameModel->Player(context->playerColor), newTarget){
//                                let tempEvent: GameEvent
//                                tempEvent.type = EventType.placeAction;
//                                tempEvent.asset = newTarget
//                                context->gameModel->Player(context->PlayerColor)->addGameEvent(tempEvent)
//
//                                context->playerCommands[context->PlayerColor].action = context->currentAssetCapability
//                                context->playerCommands[context->playerColor].actors = context->selectedPlayerAssets
//                                context->playerCommands[context->playerColor].TargetColor = PixelType.Color()
//                                context->playerCommands[context->playerColor].targetType = PixelType.AssetType()
//                                context->playerCommands[context->playerColor].targetLocation = tempPosition
//                                context->currentAssetCapability = AssetCapabilityType.none
//                            }
//                        }//edit these lines
//                        else if PlayerCapability.TargetType.Terrain == PlayerCapability->TargetType||PlayerCapability.TargetType.TerrainOrAsset == PlayerCapability->TargetType() && AssetType.none == PixelType.AssetType() && PlayerColor.none == PixelType.Color(){
//                            let newTarget = context->gameModel->Player(context->PlayerColor)->createMarker(tempPosition, false)
//
//                        if PlayerCapability->canApply(context->selectedPlayerAssets.front().lock(), context->gameModel->Player(context->playerColor), newTarget){
//                            let tempEvent: GameEvent
//                                tempEvent.type = EventType.placeAction;
//                                tempEvent.asset = newTarget
//                                context->DGameModel->Player(context->DPlayerColor)->addGameEvent(tempEvent)
//
//                                context->playerCommands[context->PlayerColor].action = context->currentAssetCapability
//                                context->playerCommands[context->PlayerColor].actors = context->selectedPlayerAssets
//                                context->playerCommands[context->DPlayerColor].TargetColor = PlayerColor.none
//                                context->playerCommands[context->playerColor)].targetType = AssetType.none
//                                context->playerCommands[context->playerColor].targetLocation = tempPosition;
//                                context->currentAssetCapability = AssetCapabilityType.none
//                                }
//                        }else {
//
//                        }
//                    }
//                }
//            }
//        } else if ApplicationData.userAction == ComponentType{
//            if context->leftClick && !context->leftDown{
//                AssetCapabilityType.capabilityType = context->unitActionRenderer->selection(context->screenToUnitAction(Position(currentX, currentY))
//                let playerCapability = PlayerCapability.findCapability(capabilityType)
//
//                if AssetCapabilityType.none != CapabilityType{
//                    let tempEvent: GameEvent
//                    tempEvent.type = EventType.buttonTick
//                    context->gameModel->Player(context->PlayerColor)->addGameEvent(tempEvent)
//                }
//                if playerCapability {
//                    if PlayerCapability.targetType.none == PlayerCapability->targetType() || PlayerCapability.targetType.player == PlayerCapability->targetType(){
//                        let ActorTarget = context->DSelectedPlayerAssets.front().lock();
//
//                        if playerCapability->canApply(actorTarget, context->gameModel->Player(context->playerColor), actorTarget){
//
//                            context->playerCommands[context->PlayerColor].action = capabilityType
//                            context->playerCommands[context->playerColor].actors = context->selectedPlayerAssets
//                            context->playerCommands[context->DPlayerColor].targetColor = playerColor.none
//                            context->playerCommands[context->playerColor].targetType = AssetType.none
//                            context->layerCommands[context->playerColor].targetLocation = actorTarget->Position()
//                            context->currentAssetCapability = AssetCapabilityType.none
//                        }
//                    }
//                    else{
//                        context->currentAssetCapability = capabilityType
//                    }
//                }
//                else{
//                    context->currentAssetCapability = capabilityType
//                }
//            }
//        }else if ApplicationData.menuButton == componentType{
//            context->menuButtonState = context->leftDown ? ButtonRenderer.ButtonState.pressed : ButtonRenderer.ButtonState.hover
//        }
//        if panning{
//            context->panningSpeed = 0
//        }
//        else{
//            if Direction.north == panningDirection{
//                context->viewportRenderer->panNorth(context->panningSpeed)
//            }
//            else if Direction.east == panningDirection {//re-port
//                context->viewportRenderer->panEast(context->panningSpeed)
//            }
//            else if Direction.south == panningDirection {
//                context->viewportRenderer->panSouth(context->panningSpeed)
//            }
//            else if Direction.west == panningDirection {
//                context->viewportRenderer->panWest(context->panningSpeed
//            }
//            if context->panningSpeed{
//                context->panningSpeed = context->panningSpeed + 1
//                if context->panningSpeed { //re-port this line?
//                    context->panningSpeed = PAN_SPEED_MAX
//                }
//            }
//            else{
//                context->panningSpeed = 1 << PAN_SPEED_SHIFT
//            }
//        }
//
//    }
//
//    func calculate(context: ApplicationData){
//        for index:Int = 1 index < PlayerColor.max index++ {
//            if context->gameModel->player(index->isAlive() && context->gameModel->Player(index)->isAI(){
//                context->aIPlayers[index]->calculateCommand(context->playerCommands[index])
//            }
//        }
//
//        for(index:Int = 1 index < PlayerColor.max index++{
//            if AssetCapabilityType.none != context->playerCommands[index].action {
//                let playerCapability = PlayerCapability.findCapability(context->playerCommands[index].DAction)
//                if playerCapability {
//                    let newTarget:PlayerAsset
//
//                    if PlayerCapability.TargetType.none != PlayerCapability->TargetType() && PlayerCapability.TargetType.player != PlayerCapability->TargetType(){
//                        if AssetType.none == context->PlayerCommands[index].TargetType{
//                            newTarget = context->gameModel->Player(index)->createMarker(context->playerCommands[index].targetLocation, true)
//                        }
//                        else{
//                            newTarget = context->gameModel->player(context->playerCommands[index].targetColor)->selectAsset(context->playerCommands[index].targetLocation, context->playerCommands[index].targetType).lock()
//                        }
//                    }
//
//                            for weakActor: context->PlayerCommands[index].actors{
//                                if actor = weakActor.lock() {
//                                    if playerCapability->CanApply(actor, context->gameModel->Player(index), newTarget) && (actor->Interruptible() || (AssetCapabilityType.cancel == context->PlayerCommands[index].action)){
//                                        playerCapability->applyCapability(actor, context->gameModel->player(index), newTarget)
//                                    }
//                                }
//                            }
//                    }
//                    context->playerCommands[index].action = AssetCapabilityType.none
//                }
//        }
//        context->gameModel->timestep()
//        let weakAsset = context->selectedPlayerAssets.begin()
//        while weakAsset != context->selectedPlayerAssets.end(){
//            if let asset = weakAsset->lock(){
//                if context->gameModel->validAsset(asset) && asset->alive(){
//                    if asset->Speed() && (AssetAction.capability == Asset->action()){
//                        let command = asset->currentCommand()
//
//                        if(command.assetTarget && (AssetAction.construct == command.AssetTarget->action()){
//                            let tempEvent: GameEvent
//
//                            context->selectedPlayerAssets.clear()
//                            context->selectedPlayerAssets.push_back(command.AssetTarget)
//
//                            tempEvent.Type = EventType.selection
//                            tempEvent.asset = command.assetTarget
//                            context->DGameModel->Player(context->playerColor)->addGameEvent(tempEvent)
//
//                            break
//                        }
//                    }
//                    weakAsset++
//                } else{
//                    weakAsset = context->selectedPlayerAssets.erase(weakAsset)
//                }
//            }else{
//                weakAsset = context->selectedPlayerAssets.erase(weakAsset)
//            }
//        }
//    }
//
// }
