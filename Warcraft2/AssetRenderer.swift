class AssetRenderer {
    private var playerData: PlayerData?
    private var playerMap: AssetDecoratedMap
    private var tilesets: [GraphicMulticolorTileset] = []
    private var markerTileset: GraphicTileset
    private var fireTileset: [GraphicTileset] = []
    private var buildingDeathTileset: GraphicTileset
    private var corpseTileset: GraphicTileset
    private var arrowTileset: GraphicTileset
    private var markerIndices: [Int] = []
    private var corpseIndices: [Int] = []
    private var arrowIndices: [Int] = []
    private var placeGoodIndex: Int
    private var placeBadIndex: Int
    private var noneIndices: [[Int]] = []
    private var constructIndices: [[Int]] = []
    private var buildIndices: [[Int]] = []
    private var walkIndices: [[Int]] = []
    private var attackIndices: [[Int]] = []
    private var carryGoldIndices: [[Int]] = []
    private var carryLumberIndices: [[Int]] = []
    private var deathIndices: [[Int]] = []
    private var placeIndices: [[Int]] = []
    private var pixelColors: [UInt32]
    private var animationDownsample: Int = 1
    private var targetFrequency = 10

    init(colors: GraphicRecolorMap, tilesets: [GraphicMulticolorTileset], markerTileset: GraphicTileset, corpseTileset: GraphicTileset, fireTileset: [GraphicTileset], buildingDeath: GraphicTileset, arrowTileset: GraphicTileset, player: PlayerData, map: AssetDecoratedMap) {
        var typeIndex: Int = 0
        var markerIndex: Int = 0

        self.tilesets = tilesets
        self.markerTileset = markerTileset
        self.fireTileset = fireTileset
        self.buildingDeathTileset = buildingDeath
        self.corpseTileset = corpseTileset
        self.arrowTileset = arrowTileset
        self.playerData = player
        self.playerMap = map

        self.pixelColors = Array(repeating: 0, count: PlayerColor.max.rawValue + 3)
        pixelColors[PlayerColor.none.rawValue] = colors.colorValue(gindex: colors.findColor(with: "none"), cindex: 0)
        pixelColors[PlayerColor.blue.rawValue] = colors.colorValue(gindex: colors.findColor(with: "blue"), cindex: 0)
        pixelColors[PlayerColor.red.rawValue] = colors.colorValue(gindex: colors.findColor(with: "red"), cindex: 0)
        pixelColors[PlayerColor.green.rawValue] = colors.colorValue(gindex: colors.findColor(with: "green"), cindex: 0)
        pixelColors[PlayerColor.purple.rawValue] = colors.colorValue(gindex: colors.findColor(with: "purple"), cindex: 0)
        pixelColors[PlayerColor.orange.rawValue] = colors.colorValue(gindex: colors.findColor(with: "orange"), cindex: 0)
        pixelColors[PlayerColor.yellow.rawValue] = colors.colorValue(gindex: colors.findColor(with: "yellow"), cindex: 0)
        pixelColors[PlayerColor.black.rawValue] = colors.colorValue(gindex: colors.findColor(with: "black"), cindex: 0)
        pixelColors[PlayerColor.white.rawValue] = colors.colorValue(gindex: colors.findColor(with: "white"), cindex: 0)
        pixelColors[PlayerColor.max.rawValue] = colors.colorValue(gindex: colors.findColor(with: "self"), cindex: 0)
        pixelColors[PlayerColor.max.rawValue + 1] = colors.colorValue(gindex: colors.findColor(with: "enemy"), cindex: 0)
        pixelColors[PlayerColor.max.rawValue + 2] = colors.colorValue(gindex: colors.findColor(with: "building"), cindex: 0)

        while true {
            let index = markerTileset.findTile(with: "marker-" + String(markerIndex))
            if index < 0 {
                break
            }
            markerIndices.append(index)
            markerIndex += 1
        }

        placeGoodIndex = markerTileset.findTile(with: "place-good")
        placeBadIndex = markerTileset.findTile(with: "place-bad")

        var lastDirectionName = "decay-nw"
        for directionName in ["decay-n", "decay-ne", "decay-e", "decay-se", "decay-s", "decay-sw", "decay-w", "decay-nw"] {
            var stepIndex = 0
            while true {
                var tileIndex = corpseTileset.findTile(with: directionName + String(stepIndex))
                if tileIndex >= 0 {
                    corpseIndices.append(tileIndex)
                } else {
                    tileIndex = corpseTileset.findTile(with: lastDirectionName + String(stepIndex))
                    if tileIndex >= 0 {
                        corpseIndices.append(tileIndex)
                    } else {
                        break
                    }
                }
                stepIndex += 1
            }
            lastDirectionName = directionName
        }

        for directionName in ["attack-n", "attack-ne", "attack-e", "attack-se", "attack-s", "attack-sw", "attack-w", "attack-nw"] {
            var stepIndex = 0
            while true {
                let tileIndex = arrowTileset.findTile(with: directionName + String(stepIndex))
                if tileIndex >= 0 {
                    arrowIndices.append(tileIndex)
                } else {
                    break
                }
                stepIndex += 1
            }
        }

        constructIndices = Array(repeating: [], count: tilesets.count)
        buildIndices = Array(repeating: [], count: tilesets.count)
        walkIndices = Array(repeating: [], count: tilesets.count)
        noneIndices = Array(repeating: [], count: tilesets.count)
        carryGoldIndices = Array(repeating: [], count: tilesets.count)
        carryLumberIndices = Array(repeating: [], count: tilesets.count)
        attackIndices = Array(repeating: [], count: tilesets.count)
        deathIndices = Array(repeating: [], count: tilesets.count)
        placeIndices = Array(repeating: [], count: tilesets.count)

        for tileset in tilesets {
            printDebug("Checking Walk on \(typeIndex)", level: .low)
            for directionName in ["walk-n", "walk-ne", "walk-e", "walk-se", "walk-s", "walk-sw", "walk-w", "walk-nw"] {
                var stepIndex = 0
                while true {
                    let tileIndex = tileset.findTile(with: directionName + String(stepIndex))
                    if tileIndex >= 0 {
                        walkIndices[typeIndex].append(tileIndex)
                    } else {
                        break
                    }
                    stepIndex += 1
                }
            }
            printDebug("Checking Construct on \(typeIndex)", level: .low)
            var stepIndex = 0
            while true {
                let tileIndex = tileset.findTile(with: "construct-" + String(stepIndex))
                if tileIndex >= 0 {
                    constructIndices[typeIndex].append(tileIndex)
                } else {
                    if stepIndex == 0 {
                        constructIndices[typeIndex].append(-1)
                    }
                    break
                }
                stepIndex += 1
            }
            printDebug("Checking Gold on \(typeIndex)", level: .low)
            for directionName in ["gold-n", "gold-ne", "gold-e", "gold-se", "gold-s", "gold-sw", "gold-w", "gold-nw"] {
                var stepIndex = 0
                while true {
                    let tileIndex = tileset.findTile(with: directionName + String(stepIndex))
                    if tileIndex >= 0 {
                        carryGoldIndices[typeIndex].append(tileIndex)
                    } else {
                        break
                    }
                    stepIndex += 1
                }
            }
            printDebug("Checking Lumber on \(typeIndex)", level: .low)
            for directionName in ["lumber-n", "lumber-ne", "lumber-e", "lumber-se", "lumber-s", "lumber-sw", "lumber-w", "lumber-nw"] {
                var stepIndex = 0
                while true {
                    let tileIndex = tileset.findTile(with: directionName + String(stepIndex))
                    if tileIndex >= 0 {
                        carryLumberIndices[typeIndex].append(tileIndex)
                    } else {
                        break
                    }
                    stepIndex += 1
                }
            }
            printDebug("Checking Attack on \(typeIndex)", level: .low)
            for directionName in ["attack-n", "attack-ne", "attack-e", "attack-se", "attack-s", "attack-sw", "attack-w", "attack-nw"] {
                var stepIndex = 0
                while true {
                    let tileIndex = tileset.findTile(with: directionName + String(stepIndex))
                    if tileIndex >= 0 {
                        attackIndices[typeIndex].append(tileIndex)
                    } else {
                        break
                    }
                    stepIndex += 1
                }
            }
            if attackIndices[typeIndex].count == 0 {
                var tileIndex: Int
                for _ in 0 ..< Direction.numberOfDirections {
                    if tileset.findTile(with: "active") >= 0 {
                        tileIndex = tileset.findTile(with: "active")
                        attackIndices[typeIndex].append(tileIndex)
                    } else if tileset.findTile(with: "inactive") >= 0 {
                        tileIndex = tileset.findTile(with: "inactive")
                        attackIndices[typeIndex].append(tileIndex)
                    }
                }
            }
            printDebug("Checking Death on \(typeIndex)", level: .low)
            var lastDirectionName = "death-nw"
            for directionName in ["death-n", "death-ne", "death-e", "death-se", "death-s", "death-sw", "death-w", "death-nw"] {
                var stepIndex = 0
                while true {
                    var tileIndex = tileset.findTile(with: directionName + String(stepIndex))
                    if tileIndex >= 0 {
                        deathIndices[typeIndex].append(tileIndex)
                    } else {
                        tileIndex = tileset.findTile(with: lastDirectionName + String(stepIndex))
                        if tileIndex >= 0 {
                            deathIndices[typeIndex].append(tileIndex)
                        } else {
                            break
                        }
                    }
                    stepIndex += 1
                }
                lastDirectionName = directionName
            }
            printDebug("Checking None on \(typeIndex)", level: .low)
            for directionName in ["none-n", "none-ne", "none-e", "none-se", "none-s", "none-sw", "none-w", "none-nw"] {
                var tileIndex = tileset.findTile(with: directionName)
                if tileIndex >= 0 {
                    noneIndices[typeIndex].append(tileIndex)
                } else if walkIndices[typeIndex].count != 0 {
                    noneIndices[typeIndex].append(walkIndices[typeIndex][noneIndices[typeIndex].count * (walkIndices[typeIndex].count / Direction.max.rawValue)])
                } else if tileset.findTile(with: "inactive") >= 0 {
                    tileIndex = tileset.findTile(with: "inactive")
                    noneIndices[typeIndex].append(tileIndex)
                }
            }
            printDebug("Checking Build on \(typeIndex)", level: .low)
            for directionName in ["build-n", "build-ne", "build-e", "build-se", "build-s", "build-sw", "build-w", "build-nw"] {
                var stepIndex = 0
                while true {
                    var tileIndex = tileset.findTile(with: directionName + String(stepIndex))
                    if tileIndex >= 0 {
                        buildIndices[typeIndex].append(tileIndex)
                    } else {
                        if stepIndex != 0 {
                            if tileset.findTile(with: "active") >= 0 {
                                tileIndex = tileset.findTile(with: "active")
                                buildIndices[typeIndex].append(tileIndex)
                            } else if tileset.findTile(with: "inactive") >= 0 {
                                tileIndex = tileset.findTile(with: "inactive")
                                buildIndices[typeIndex].append(tileIndex)
                            }
                        }
                        break
                    }
                    stepIndex += 1
                }
            }
            printDebug("Checking Place on \(typeIndex)", level: .low)
            placeIndices[typeIndex].append(tileset.findTile(with: "place"))
            printDebug("Done checking type \(typeIndex)", level: .low)
            typeIndex += 1
        }
    }

    func updateFrequency(_ frequency: Int) -> Int {
        if targetFrequency >= frequency {
            animationDownsample = 1
            return targetFrequency
        }
        animationDownsample = frequency / targetFrequency
        return frequency
    }

    struct AssetRenderData {
        var type: AssetType
        var x: Int
        var y: Int
        var bottomY: Int
        var tileIndex: Int
        var colorIndex: Int
        var pixelColor: UInt32

        init() {
            type = AssetType.none
            x = -1
            y = -1
            bottomY = -1
            tileIndex = -1
            colorIndex = -1
            pixelColor = 0
        }
    }

    func compareRenderData(first: AssetRenderData, second: AssetRenderData) -> Bool {
        if first.bottomY < second.bottomY {
            return true
        }
        if first.bottomY > second.bottomY {
            return false
        }
        return first.x <= second.x
    }

    func drawAssets(on surface: GraphicSurface, typeSurface: GraphicSurface, rect: Rectangle) {
        var screenRightX = rect.xPosition + rect.width - 1
        var screenBottomY = rect.yPosition + rect.height - 1
        var finalRenderList = Array<AssetRenderData>()

        for data in finalRenderList {
            var tempRenderData = AssetRenderData()
            // NOTE: the below was this code. I'm not sure how to deal with these iterators, so someone look over this
            //            TempRenderData.DType = AssetIterator->Type();
            tempRenderData.type = data.type
            if AssetType.none == tempRenderData.type {
                continue
            }
            guard (0 <= tempRenderData.type.hashValue) && ((tempRenderData.type.hashValue) < tilesets.count) else {
                break
            }
            // NOTE: the below was this code. I have no idea if I dealt with this correctly, but I made another initializer in PixelType.swift. Double check?
            //            CPixelType PixelType(*AssetIterator);
            var pixelType = PixelType(pixelColor: data.pixelColor, t: data.type)
            var rightX: Int

            // FIXME: translate below to Swift
            //            TempRenderData.DX = AssetIterator->PositionX() + (AssetIterator->Size() - 1) * CPosition::HalfTileWidth() - DTilesets[static_cast<int>(TempRenderData.DType)]->TileHalfWidth();
            //            TempRenderData.DY = AssetIterator->PositionY() + (AssetIterator->Size() - 1) * CPosition::HalfTileHeight() - DTilesets[static_cast<int>(TempRenderData.DType)]->TileHalfHeight();

            // FIXME: implement toPixelColor from C++
            //            TempRenderData.DPixelColor = PixelType.ToPixelColor();
            //            tempRenderData.pixelColor = pixelType.toPixelColor()

            rightX = tempRenderData.x + tilesets[tempRenderData.type.hashValue].tileWidth - 1
            tempRenderData.bottomY = tempRenderData.y + tilesets[tempRenderData.type.hashValue].tileHeight - 1
            var onScreen = true
            if (rightX < rect.xPosition) || (tempRenderData.x > screenRightX) {
                onScreen = false
            } else if (tempRenderData.bottomY < rect.yPosition) || (tempRenderData.y > screenBottomY) {
                onScreen = false
            }
            tempRenderData.x -= rect.xPosition
            tempRenderData.y -= rect.yPosition

            // FIXME: translate below to Swift
            //            TempRenderData.DColorIndex = static_cast<int>(AssetIterator->Color()) ? static_cast<int>(AssetIterator->Color()) - 1 : static_cast<int>(AssetIterator->Color());

            tempRenderData.tileIndex = -1
            guard onScreen else {
                break
            }
            var actionSteps: Int
            var currentStep: Int
            var tileIndex: Int
            // FIXME: translate below to Swift
            //            switch(AssetIterator->Action()){
            // placeholder for above statement
            switch AssetAction.none {
            case AssetAction.build:
                actionSteps = buildIndices[tempRenderData.type.hashValue].count
                actionSteps /= Direction.max.hashValue
                if actionSteps > 0 {
                    // FIXME: translate below to Swift
                    //                    TileIndex = static_cast<int>(AssetIterator->Direction()) * ActionSteps + ((AssetIterator->Step() / DAnimationDownsample)% ActionSteps);

                    // FIXME: uncomment below after translating above
                    //                    tempRenderData.tileIndex = buildIndices[tempRenderData.type.hashValue][tileIndex]
                }
            case AssetAction.construct:
                actionSteps = constructIndices[tempRenderData.type.hashValue].count
                if actionSteps > 0 {
                    // FIXME: translate below to Swift
                    //                    int TotalSteps = AssetIterator->BuildTime() * CPlayerAsset::UpdateFrequency();
                    //                    int CurrentStep = AssetIterator->Step() * ActionSteps / TotalSteps;
                    //                    if(CurrentStep == DConstructIndices[static_cast<int>(TempRenderData.DType)].size()){
                    //                      CurrentStep--;
                    //                    }
                    //                    TempRenderData.DTileIndex = DConstructIndices[static_cast<int>(TempRenderData.DType)][CurrentStep];
                }
            case AssetAction.walk:
                // FIXME: translate below to Swift
                //                if(AssetIterator->Lumber()){
                actionSteps = carryLumberIndices[tempRenderData.type.hashValue].count
                actionSteps /= Direction.max.hashValue
                //                    TileIndex = static_cast<int>(AssetIterator->Direction()) * ActionSteps + ((AssetIterator->Step() / DAnimationDownsample)% ActionSteps);

                // FIXME: uncomment below after translating above
                //                    tempRenderData.tileIndex = carryLumberIndices[tempRenderData.type.hashValue][tileIndex]

                //                }
                //                else if(AssetIterator->Gold()){
                actionSteps = carryGoldIndices[tempRenderData.type.hashValue].count
                actionSteps /= Direction.max.hashValue
                //                    TileIndex = static_cast<int>(AssetIterator->Direction()) * ActionSteps + ((AssetIterator->Step() / DAnimationDownsample)% ActionSteps);

                // FIXME: uncomment below after translating above
                //                    tempRenderData.tileIndex = carryGoldIndices[tempRenderData.type.hashValue][tileIndex]

                //                }
                //                else{
                actionSteps = walkIndices[tempRenderData.type.hashValue].count
                actionSteps /= Direction.max.hashValue
                //                    TileIndex = static_cast<int>(AssetIterator->Direction()) * ActionSteps + ((AssetIterator->Step() / DAnimationDownsample)% ActionSteps);

                // FIXME: uncomment below after translating above
                //                    tempRenderData.tileIndex = walkIndices[tempRenderData.type.hashValue][tileIndex]

                //                }
            case AssetAction.attack:
                //                    CurrentStep = AssetIterator->Step() % (AssetIterator->AttackSteps() + AssetIterator->ReloadSteps());
                //                    if(CurrentStep < AssetIterator->AttackSteps()){
                actionSteps = attackIndices[tempRenderData.type.hashValue].count
                actionSteps /= Direction.max.hashValue
                //                    TileIndex = static_cast<int>(AssetIterator->Direction()) * ActionSteps + (CurrentStep * ActionSteps / AssetIterator->AttackSteps());

                // FIXME: uncomment below after translating above
                //                    tempRenderData.tileIndex = attackIndices[tempRenderData.type.hashValue][tileIndex]

                //                    }
                //                    else{
                //                    TempRenderData.DTileIndex = DNoneIndices[static_cast<int>(TempRenderData.DType)][static_cast<int>(AssetIterator->Direction())];
                //                }
            case AssetAction.repair:
                break
            case AssetAction.harvestLumber:
                actionSteps = attackIndices[tempRenderData.type.hashValue].count
                actionSteps /= Direction.max.hashValue
                //                TileIndex = static_cast<int>(AssetIterator->Direction()) * ActionSteps + ((AssetIterator->Step() / DAnimationDownsample)% ActionSteps);

                // FIXME: uncomment below after translating above
                //                tempRenderData.tileIndex = attackIndices[tempRenderData.type.hashValue][tileIndex]
            case AssetAction.mineGold:
                break
            case AssetAction.standGround:
                break
            case AssetAction.none:
                //                TempRenderData.DTileIndex = DNoneIndices[static_cast<int>(TempRenderData.DType)][static_cast<int>(AssetIterator->Direction())];
                //                if(AssetIterator->Speed()){
                //                    if(AssetIterator->Lumber()){
                actionSteps = carryLumberIndices[tempRenderData.type.hashValue].count
                actionSteps /= Direction.max.hashValue
                //                        TempRenderData.DTileIndex = DCarryLumberIndices[static_cast<int>(TempRenderData.DType)][static_cast<int>(AssetIterator->Direction()) * ActionSteps];
                //                    }
                //                    else if(AssetIterator->Gold()){
                actionSteps = carryGoldIndices[tempRenderData.type.hashValue].count
                actionSteps /= Direction.max.hashValue
                //                        TempRenderData.DTileIndex = DCarryGoldIndices[static_cast<int>(TempRenderData.DType)][static_cast<int>(AssetIterator->Direction()) * ActionSteps];
                //                    }
                //                }
            case AssetAction.capability:
                //                if(AssetIterator->Speed()){
                //                    if((EAssetCapabilityType::actPatrol == AssetIterator->CurrentCommand().DCapability)||(EAssetCapabilityType::actStandGround == AssetIterator->CurrentCommand().DCapability)){
                //                        TempRenderData.DTileIndex = DNoneIndices[static_cast<int>(TempRenderData.DType)][static_cast<int>(AssetIterator->Direction())];
                //                    }
                //                }
                //                else{
                //                    // Buildings
                //                    TempRenderData.DTileIndex = DNoneIndices[static_cast<int>(TempRenderData.DType)][static_cast<int>(AssetIterator->Direction())];
                //                }
                break
            case AssetAction.death:
                actionSteps = deathIndices[tempRenderData.type.hashValue].count
                //                if(AssetIterator->Speed()){
                actionSteps /= Direction.max.hashValue
                if actionSteps > 0 {
                    //                        CurrentStep = AssetIterator->Step() / DAnimationDownsample;

                    // FIXME: uncomment below after translating above
                    //                        if currentStep >= actionSteps {
                    //                            currentStep = actionSteps - 1
                    //                        }

                    //                        TempRenderData.DTileIndex = DDeathIndices[static_cast<int>(TempRenderData.DType)][static_cast<int>(AssetIterator->Direction()) * ActionSteps + CurrentStep];
                }

                //                }
                //                else{
                //                    if(AssetIterator->Step() < DBuildingDeathTileset->TileCount()){
                //                        TempRenderData.DTileIndex = DTilesets[static_cast<int>(TempRenderData.DType)]->TileCount() + AssetIterator->Step();
                tempRenderData.x += tilesets[tempRenderData.type.hashValue].tileHalfWidth - buildingDeathTileset.tileHalfWidth
                tempRenderData.y += tilesets[tempRenderData.type.hashValue].tileHalfHeight - buildingDeathTileset.tileHalfHeight
                //                    }
                //                }
            default:
                break
            }

            if 0 <= tempRenderData.tileIndex {
                finalRenderList.append(tempRenderData)
            }

            //        }
            //    }
            //    FinalRenderList.sort(CompareRenderData);
            //    for(auto &RenderIterator : FinalRenderList){
            //    if(RenderIterator.DTileIndex < DTilesets[static_cast<int>(RenderIterator.DType)]->TileCount()){
            //    DTilesets[static_cast<int>(RenderIterator.DType)]->DrawTile(surface, RenderIterator.DX, RenderIterator.DY, RenderIterator.DTileIndex, RenderIterator.DColorIndex);
            //    DTilesets[static_cast<int>(RenderIterator.DType)]->DrawClipped(typesurface, RenderIterator.DX, RenderIterator.DY, RenderIterator.DTileIndex, RenderIterator.DPixelColor);
            //    }
            //    else{
            //    DBuildingDeathTileset->DrawTile(surface, RenderIterator.DX, RenderIterator.DY, RenderIterator.DTileIndex);
            //    }
            //    }
        }
    }

    func drawSelections(on surface: GraphicSurface, rect: Rectangle, selectionList: [PlayerAsset], selectRect: Rectangle, highlightBuilding: Bool) throws {
        let resourceContext = surface.createResourceContext()
        var rectangleColor = pixelColors[PlayerColor.max.rawValue]
        let screenRightX = rect.xPosition + rect.width - 1
        let screenBottomY = rect.yPosition + rect.height - 1
        var selectionX: Int
        var selectionY: Int

        if highlightBuilding {
            rectangleColor = pixelColors[PlayerColor.max.rawValue + 2]
            resourceContext.setSourceRGB(rectangleColor)
            for asset in playerMap.assets {
                var tempRenderData = AssetRenderData()
                tempRenderData.type = asset.type
                if tempRenderData.type == AssetType.none {
                    continue
                }
                if 0 <= tempRenderData.type.rawValue && tempRenderData.type.rawValue < tilesets.count {
                    if asset.speed == 0 {
                        let offset = AssetType.goldMine == tempRenderData.type ? 1 : 0

                        tempRenderData.x = asset.positionX() + (asset.size - 1) * Position.halfTileWidth - tilesets[tempRenderData.type.rawValue].tileHalfWidth
                        tempRenderData.y = asset.positionY() + (asset.size - 1) * Position.halfTileHeight - tilesets[tempRenderData.type.rawValue].tileHalfHeight
                        tempRenderData.x -= offset * Position.tileWidth
                        tempRenderData.y -= offset * Position.tileHeight

                        let rightX = tempRenderData.x + tilesets[tempRenderData.type.rawValue].tileWidth + (2 * offset * Position.tileWidth) - 1
                        tempRenderData.bottomY = tempRenderData.y + tilesets[tempRenderData.type.rawValue].tileHeight + (2 * offset * Position.tileHeight) - 1
                        var onScreen = true
                        if (rightX < rect.xPosition) || (tempRenderData.x > screenRightX) {
                            onScreen = false
                        } else if (tempRenderData.bottomY < rect.yPosition) || (tempRenderData.y > screenBottomY) {
                            onScreen = false
                        }
                        tempRenderData.x -= rect.xPosition
                        tempRenderData.y -= rect.yPosition
                        if onScreen {
                            resourceContext.rectangle(xPosition: tempRenderData.x, yPosition: tempRenderData.y, width: tilesets[tempRenderData.type.rawValue].tileWidth + (2 * offset * Position.tileWidth), height: tilesets[tempRenderData.type.rawValue].tileHeight + (2 * offset * Position.tileHeight))
                            resourceContext.stroke()
                        }
                    }
                }
            }
            rectangleColor = pixelColors[PlayerColor.max.rawValue]
        }

        resourceContext.setSourceRGB(rectangleColor)
        if (selectRect.width != 0) && (selectRect.height != 0) {
            selectionX = selectRect.xPosition - rect.xPosition
            selectionY = selectRect.yPosition - rect.yPosition
            resourceContext.rectangle(xPosition: selectionX, yPosition: selectionY, width: selectRect.width, height: selectRect.height)
            resourceContext.stroke()
        }

        if selectionList.count != 0 {
            if let asset = selectionList.first {
                if asset.color == PlayerColor.none {
                    rectangleColor = pixelColors[PlayerColor.none.rawValue]
                } else if asset.color != playerData?.color {
                    rectangleColor = pixelColors[PlayerColor.max.rawValue + 1]
                }
                resourceContext.setSourceRGB(rectangleColor)
            }
        }

        for asset in selectionList {
            var tempRenderData = AssetRenderData()
            tempRenderData.type = asset.type
            if tempRenderData.type == AssetType.none {
                if asset.action == AssetAction.decay {
                    var onScreen = true
                    tempRenderData.x = asset.positionX() - corpseTileset.tileWidth / 2
                    tempRenderData.y = asset.positionY() - corpseTileset.tileHeight / 2
                    let rightX = tempRenderData.x + corpseTileset.tileWidth
                    tempRenderData.bottomY = tempRenderData.y + corpseTileset.tileHeight

                    if rightX < rect.xPosition || tempRenderData.x > screenRightX {
                        onScreen = false
                    } else if tempRenderData.bottomY < rect.yPosition || tempRenderData.y > screenBottomY {
                        onScreen = false
                    }

                    tempRenderData.x -= rect.xPosition
                    tempRenderData.y -= rect.yPosition

                    if onScreen {
                        let actionSteps = corpseIndices.count / Direction.max.rawValue
                        if actionSteps != 0 {
                            var currentStep = asset.step / (animationDownsample * targetFrequency)
                            if currentStep >= actionSteps {
                                currentStep = actionSteps - 1
                            }
                            tempRenderData.tileIndex = corpseIndices[asset.direction.rawValue * actionSteps + currentStep]
                        }
                        try corpseTileset.drawTile(on: surface, x: tempRenderData.x, y: tempRenderData.y, index: tempRenderData.tileIndex)
                    }
                } else if asset.action == AssetAction.attack {
                    var onScreen = true
                    tempRenderData.x = asset.positionX() - markerTileset.tileWidth / 2
                    tempRenderData.y = asset.positionY() - markerTileset.tileHeight / 2
                    let rightX = tempRenderData.x + markerTileset.tileWidth
                    tempRenderData.bottomY = tempRenderData.y + markerTileset.tileHeight

                    if rightX < rect.xPosition || tempRenderData.x > screenRightX {
                        onScreen = false
                    } else if (tempRenderData.bottomY < rect.yPosition) || (tempRenderData.y > screenBottomY) {
                        onScreen = false
                    }

                    tempRenderData.x -= rect.xPosition
                    tempRenderData.y -= rect.yPosition

                    if onScreen {
                        let markerIndex = asset.step / animationDownsample
                        if markerIndex < markerIndices.count {
                            try markerTileset.drawTile(on: surface, x: tempRenderData.x, y: tempRenderData.y, index: markerIndices[markerIndex])
                        }
                    }
                }
            } else if tempRenderData.type.rawValue >= 0 && tempRenderData.type.rawValue < tilesets.count {
                var onScreen = true
                tempRenderData.x = asset.positionX() - Position.halfTileWidth
                tempRenderData.y = asset.positionY() - Position.halfTileHeight
                let rectWidth = Position.tileWidth * asset.size
                let rectHeight = Position.tileHeight * asset.size
                let rightX = tempRenderData.x + rectWidth
                tempRenderData.bottomY = tempRenderData.y + rectHeight

                if rightX < rect.xPosition || tempRenderData.x > screenRightX {
                    onScreen = false
                } else if tempRenderData.bottomY < rect.yPosition || tempRenderData.y > screenBottomY {
                    onScreen = false
                } else if asset.action == AssetAction.mineGold || asset.action == AssetAction.conveyLumber || asset.action == AssetAction.conveyGold {
                    onScreen = false
                }
                tempRenderData.x -= rect.xPosition
                tempRenderData.y -= rect.yPosition
                if onScreen {
                    resourceContext.rectangle(xPosition: tempRenderData.x, yPosition: tempRenderData.y, width: rectWidth, height: rectHeight)
                    resourceContext.stroke()
                }
            }
        }
    }

    func drawOverlays(on surface: GraphicSurface, rect: Rectangle) throws {
        let screenRightX = rect.xPosition + rect.width - 1
        let screenBottomY = rect.yPosition + rect.height - 1

        for asset in playerMap.assets {
            var tempRenderData = AssetRenderData()
            tempRenderData.type = asset.type

            if tempRenderData.type == .none {
                if asset.action == .attack {
                    var onScreen = true
                    tempRenderData.x = asset.positionX() - arrowTileset.tileWidth / 2
                    tempRenderData.y = asset.positionY() - arrowTileset.tileHeight / 2
                    let rightX = tempRenderData.x + arrowTileset.tileWidth
                    tempRenderData.bottomY = tempRenderData.y + arrowTileset.tileHeight

                    if rightX < rect.xPosition || tempRenderData.x > screenRightX {
                        onScreen = false
                    } else if tempRenderData.bottomY < rect.yPosition || tempRenderData.y > screenBottomY {
                        onScreen = false
                    }
                    tempRenderData.x -= rect.xPosition
                    tempRenderData.y -= rect.yPosition
                    if onScreen {
                        let actionSteps = arrowIndices.count / Direction.max.rawValue
                        try arrowTileset.drawTile(on: surface, x: tempRenderData.x, y: tempRenderData.y, index: arrowIndices[asset.direction.rawValue * actionSteps + (((playerData?.gameCycle)! - asset.creationCycle) % actionSteps)])
                    }
                }
            } else if asset.speed == 0 {
                let currentAction = asset.action
                if currentAction != .death {
                    var hitRange = asset.hitPoints * fireTileset.count * 2 / asset.maxHitPoints
                    if currentAction == .construct {
                        var command = asset.currentCommand()
                        if command.assetTarget != nil {
                            command = (command.assetTarget?.currentCommand())!
                            if command.activatedCapability != nil {
                                var divisor = command.activatedCapability?.percentComplete(max: asset.maxHitPoints)
                                divisor = divisor != 0 ? divisor : 1
                                hitRange = asset.hitPoints * fireTileset.count * 2 / divisor!
                            }
                        } else if command.activatedCapability != nil {
                            var divisor = command.activatedCapability?.percentComplete(max: asset.maxHitPoints)
                            divisor = divisor != 0 ? divisor : 1
                            hitRange = asset.hitPoints * fireTileset.count * 2 / divisor!
                        }
                    }

                    if hitRange < fireTileset.count {
                        let tilesetIndex = fireTileset.count - 1 - hitRange
                        tempRenderData.tileIndex = ((playerData?.gameCycle)! - asset.creationCycle) % fireTileset[tilesetIndex].tileCount
                        tempRenderData.x = asset.positionX() + (asset.size - 1) * Position.halfTileWidth - fireTileset[tilesetIndex].tileHalfWidth
                        tempRenderData.y = asset.positionY() + (asset.size - 1) * Position.halfTileHeight - fireTileset[tilesetIndex].tileHeight
                        let rightX = tempRenderData.x + fireTileset[tilesetIndex].tileWidth - 1
                        tempRenderData.bottomY = tempRenderData.y + fireTileset[tilesetIndex].tileHeight - 1
                        var onScreen = true

                        if rightX < rect.xPosition || tempRenderData.x > screenRightX {
                            onScreen = false
                        } else if tempRenderData.bottomY < rect.yPosition || tempRenderData.y > screenBottomY {
                            onScreen = false
                        }
                        tempRenderData.x -= rect.xPosition
                        tempRenderData.y -= rect.yPosition

                        if onScreen {
                            try fireTileset[tilesetIndex].drawTile(on: surface, x: tempRenderData.x, y: tempRenderData.y, index: tempRenderData.tileIndex)
                        }
                    }
                }
            }
        }
    }

    func drawPlacement(on surface: GraphicSurface, rect: Rectangle, position: Position, type: AssetType, builder: PlayerAsset) throws {
        let screenRightX = rect.xPosition + rect.width - 1
        let screenBottomY = rect.yPosition + rect.height - 1

        if type != .none {
            let tempPosition = Position()
            let tempTilePosition = Position()
            var onScreen = true
            let assetType = PlayerAssetType.findDefault(from: type)
            var placementTiles: [[Int]] = []

            tempTilePosition.setToTile(position)
            tempPosition.setFromTile(tempTilePosition)

            tempPosition.x += (assetType.size - 1) * Position.halfTileWidth - tilesets[type.rawValue].tileHalfWidth
            tempPosition.y += (assetType.size - 1) * Position.halfTileHeight - tilesets[type.rawValue].tileHalfHeight
            let placementRightX = tempPosition.x + tilesets[type.rawValue].tileWidth
            let placementBottomY = tempPosition.y + tilesets[type.rawValue].tileHeight

            tempTilePosition.setToTile(tempPosition)
            var xOff = 0
            var yOff = 0
            placementTiles = Array(repeating: [], count: assetType.size)

            for rowIndex in 0 ..< placementTiles.count {
                placementTiles[rowIndex] = Array(repeating: -1, count: assetType.size)
                for cellIndex in 0 ..< placementTiles[rowIndex].count {
                    let tileType = playerMap.tileTypeAt(x: tempTilePosition.x + xOff, y: tempTilePosition.y + yOff)
                    placementTiles[rowIndex][cellIndex] = tileType == .grass ? 1 : 0
                    xOff += 1
                }
                xOff = 0
                yOff += 1
            }

            xOff = tempTilePosition.x + assetType.size
            yOff = tempTilePosition.y + assetType.size

            for playerAsset in playerMap.assets {
                let offset = playerAsset.type == .goldMine ? 1 : 0

                if playerAsset == builder {
                    continue
                }
                if xOff <= playerAsset.tilePositionX() - offset {
                    continue
                }
                if tempTilePosition.x >= (playerAsset.tilePositionX() + playerAsset.size + offset) {
                    continue
                }
                if yOff <= (playerAsset.tilePositionY() - offset) {
                    continue
                }
                if tempTilePosition.y >= (playerAsset.tilePositionY() + playerAsset.size + offset) {
                    continue
                }
                let minX = max(tempTilePosition.x, playerAsset.tilePositionX() - offset)
                let maxX = min(xOff, playerAsset.tilePositionX() + playerAsset.size + offset)
                let minY = max(tempTilePosition.y, playerAsset.tilePositionY() - offset)
                let maxY = min(yOff, playerAsset.tilePositionY() + playerAsset.size + offset)
                for y in minY ..< maxY {
                    for x in
                    minX ..< maxX {
                        placementTiles[y - tempTilePosition.y][x - tempTilePosition.x] = 0
                    }
                }

                if placementRightX <= rect.xPosition {
                    onScreen = false
                } else if placementBottomY <= rect.yPosition {
                    onScreen = false
                } else if tempPosition.x >= screenRightX {
                    onScreen = false
                } else if tempPosition.y >= screenBottomY {
                    onScreen = false
                }

                if onScreen {
                    tempPosition.x -= rect.xPosition
                    tempPosition.y -= tempPosition.y - rect.yPosition
                    tilesets[type.rawValue].drawTile(on: surface, xposition: tempPosition.x, yposition: tempPosition.y, tileindex: placeIndices[type.rawValue][0], colorindex: (playerData?.color.rawValue)! - 1)
                    var xPos = tempPosition.x
                    var yPos = tempPosition.y
                    for row in placementTiles {
                        for cell in row {
                            try markerTileset.drawTile(on: surface, x: xPos, y: yPos, index: cell != 0 ? placeGoodIndex : placeBadIndex)
                            xPos += markerTileset.tileWidth
                        }
                        yPos += markerTileset.tileHeight
                        xPos = tempPosition.x
                    }
                }
            }
        }
    }

    func drawMiniAssets(on surface: GraphicSurface) {
        let resourceContext = surface.createResourceContext()
        if let playerData = playerData {
            for asset in playerMap.assets {
                var assetColor = asset.color
                let size = asset.size
                if assetColor == playerData.color {
                    assetColor = PlayerColor.max
                }
                resourceContext.setSourceRGB(pixelColors[assetColor.rawValue])
                resourceContext.rectangle(xPosition: asset.tilePositionX(), yPosition: asset.tilePositionY(), width: size, height: size)
                resourceContext.fill()
            }
        } else {
            for asset in playerMap.assetInitializationList {
                let assetColor = asset.color
                let size = PlayerAssetType.findDefault(from: asset.type).size
                resourceContext.setSourceRGB(pixelColors[assetColor.rawValue])
                resourceContext.rectangle(xPosition: asset.tilePosition.x, yPosition: asset.tilePosition.y, width: size, height: size)
                resourceContext.fill()
            }
        }
    }
}
