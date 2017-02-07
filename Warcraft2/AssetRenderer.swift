class AssetRenderer {

    enum GameError: Error {
        case missingPlayerData
    }

    struct Data {
        var type = AssetType.none
        var x = -1
        var y = -1
        var bottomY = -1
        var tileIndex = -1
        var colorIndex = -1
        var pixelColor: UInt32 = 0
    }

    private var playerData: PlayerData?
    private var playerMap: AssetDecoratedMap
    private var tilesets: [GraphicMulticolorTileset] = []
    private var markerTileset: GraphicTileset
    private var fireTilesets: [GraphicTileset] = []
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
    private var pixelColors: [PlayerColor: UInt32]
    private var selfPixelColor: UInt32
    private var enemyPixelColor: UInt32
    private var buildingPixelColor: UInt32
    private var animationDownsample: Int = 1
    private var targetFrequency = 10

    init(colors: GraphicRecolorMap, tilesets: [GraphicMulticolorTileset], markerTileset: GraphicTileset, corpseTileset: GraphicTileset, fireTilesets: [GraphicTileset], buildingDeathTileset: GraphicTileset, arrowTileset: GraphicTileset, player: PlayerData?, map: AssetDecoratedMap) {
        var typeIndex = 0
        var markerIndex = 0

        self.tilesets = tilesets
        self.markerTileset = markerTileset
        self.fireTilesets = fireTilesets
        self.buildingDeathTileset = buildingDeathTileset
        self.corpseTileset = corpseTileset
        self.arrowTileset = arrowTileset
        self.playerData = player
        self.playerMap = map
        self.pixelColors = [
            .none: colors.colorValue(gIndex: colors.findColor(with: "none"), cIndex: 0),
            .blue: colors.colorValue(gIndex: colors.findColor(with: "blue"), cIndex: 0),
            .red: colors.colorValue(gIndex: colors.findColor(with: "red"), cIndex: 0),
            .green: colors.colorValue(gIndex: colors.findColor(with: "green"), cIndex: 0),
            .purple: colors.colorValue(gIndex: colors.findColor(with: "purple"), cIndex: 0),
            .orange: colors.colorValue(gIndex: colors.findColor(with: "orange"), cIndex: 0),
            .yellow: colors.colorValue(gIndex: colors.findColor(with: "yellow"), cIndex: 0),
            .black: colors.colorValue(gIndex: colors.findColor(with: "black"), cIndex: 0),
            .white: colors.colorValue(gIndex: colors.findColor(with: "white"), cIndex: 0)
        ]
        self.selfPixelColor = colors.colorValue(gIndex: colors.findColor(with: "self"), cIndex: 0)
        self.enemyPixelColor = colors.colorValue(gIndex: colors.findColor(with: "enemy"), cIndex: 0)
        self.buildingPixelColor = colors.colorValue(gIndex: colors.findColor(with: "building"), cIndex: 0)

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
                    noneIndices[typeIndex].append(walkIndices[typeIndex][noneIndices[typeIndex].count * (walkIndices[typeIndex].count / Direction.numberOfDirections)])
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

    func compareRenderData(first: Data, second: Data) -> Bool {
        if first.bottomY < second.bottomY {
            return true
        }
        if first.bottomY > second.bottomY {
            return false
        }
        return first.x <= second.x
    }

    func drawAssets(on surface: GraphicSurface, typeSurface: GraphicSurface, in rect: Rectangle) throws {
        let screenRightX = rect.xPosition + rect.width - 1
        let screenBottomY = rect.yPosition + rect.height - 1
        var finalRenderList = Array<Data>()

        for asset in playerMap.assets {
            guard asset.type != .none else {
                continue
            }
            guard asset.type.rawValue >= 0 && asset.type.rawValue < tilesets.count else {
                continue
            }

            var renderData = Data()
            renderData.type = asset.type
            renderData.x = asset.positionX + (asset.size - 1) * Position.halfTileWidth - tilesets[asset.type.rawValue].tileHalfWidth
            renderData.y = asset.positionY + (asset.size - 1) * Position.halfTileHeight - tilesets[asset.type.rawValue].tileHalfHeight
            renderData.bottomY = renderData.y + tilesets[asset.type.rawValue].tileHeight - 1
            renderData.pixelColor = PixelType(playerAsset: asset).pixelColor

            let rightX = renderData.x + tilesets[renderData.type.rawValue].tileWidth - 1

            var isOnScreen = true
            if rightX < rect.xPosition || renderData.x > screenRightX {
                isOnScreen = false
            } else if renderData.bottomY < rect.yPosition || renderData.y > screenBottomY {
                isOnScreen = false
            }

            guard isOnScreen else {
                continue
            }

            renderData.x -= rect.xPosition
            renderData.y -= rect.yPosition
            renderData.colorIndex = asset.color != .none ? asset.color.index - 1 : 0
            renderData.tileIndex = -1

            switch asset.action {
            case .build:
                let actionSteps = buildIndices[renderData.type.rawValue].count / Direction.numberOfDirections
                if actionSteps > 0 {
                    let tileIndex = asset.direction.index * actionSteps + ((asset.step / animationDownsample) % actionSteps)
                    renderData.tileIndex = buildIndices[asset.type.rawValue][tileIndex]
                }
            case .construct:
                let actionSteps = constructIndices[renderData.type.rawValue].count
                if actionSteps > 0 {
                    let totalSteps = asset.buildTime * PlayerAsset.updateFrequency
                    let currentStep = min(asset.step * actionSteps / totalSteps, constructIndices[asset.type.rawValue].count - 1)
                    renderData.tileIndex = constructIndices[asset.type.rawValue][currentStep]
                }
            case .walk:
                let currentIndices: [[Int]] = {
                    if asset.lumber > 0 {
                        return carryLumberIndices
                    } else if asset.gold > 0 {
                        return carryGoldIndices
                    } else {
                        return walkIndices
                    }
                }()
                let actionSteps = currentIndices[asset.type.rawValue].count / Direction.numberOfDirections
                let tileIndex = asset.direction.index * actionSteps + ((asset.step / animationDownsample) % actionSteps)
                renderData.tileIndex = currentIndices[asset.type.rawValue][tileIndex]
            case .attack:
                let currentStep = asset.step % asset.attackSteps + asset.reloadSteps
                if currentStep < asset.attackSteps {
                    let actionSteps = attackIndices[asset.type.rawValue].count / Direction.numberOfDirections
                    let tileIndex = asset.direction.index * actionSteps + (currentStep * actionSteps) / asset.attackSteps
                    renderData.tileIndex = attackIndices[asset.type.rawValue][tileIndex]
                }
            case .harvestLumber:
                let actionSteps = attackIndices[renderData.type.hashValue].count / Direction.numberOfDirections
                let tileIndex = asset.direction.index * actionSteps + ((asset.step / animationDownsample) % actionSteps)
                renderData.tileIndex = attackIndices[asset.type.rawValue][tileIndex]
            case .standGround, .none:
                renderData.tileIndex = noneIndices[asset.type.rawValue][asset.direction.index]
                guard asset.speed > 0 else {
                    break
                }
                guard let currentIndices: [[Int]] = {
                    if asset.lumber > 0 {
                        return carryLumberIndices
                    } else if asset.gold > 0 {
                        return carryGoldIndices
                    } else {
                        return nil
                    }
                }() else {
                    break
                }
                let actionSteps = currentIndices[asset.type.rawValue].count / Direction.numberOfDirections
                renderData.tileIndex = currentIndices[asset.type.rawValue][asset.direction.index * actionSteps]
            case .capability:
                if asset.speed > 0 {
                    if asset.currentCommand().capability == .patrol || asset.currentCommand().capability == .standGround {
                        renderData.tileIndex = noneIndices[asset.type.rawValue][asset.direction.index]
                    }
                } else {
                    renderData.tileIndex = noneIndices[asset.type.rawValue][asset.direction.index]
                }
            case .death:
                let actionSteps = asset.speed > 0 ? deathIndices[asset.type.rawValue].count : deathIndices[asset.type.rawValue].count / Direction.numberOfDirections
                if asset.speed > 0 {
                    guard actionSteps > 0 else {
                        break
                    }
                    let currentStep = min(asset.step / animationDownsample, actionSteps - 1)
                    renderData.tileIndex = deathIndices[asset.type.rawValue][asset.direction.index * actionSteps + currentStep]
                } else if asset.step < buildingDeathTileset.tileCount {
                    renderData.tileIndex = tilesets[asset.type.rawValue].tileCount + asset.step
                    renderData.x = tilesets[asset.type.rawValue].tileHalfWidth - buildingDeathTileset.tileHalfWidth
                    renderData.y = tilesets[asset.type.rawValue].tileHalfHeight - buildingDeathTileset.tileHalfHeight
                }
            default:
                break
            }

            if renderData.tileIndex >= 0 {
                finalRenderList.append(renderData)
            }

            finalRenderList.sort { first, second -> Bool in
                return compareRenderData(first: first, second: second)
            }

            for renderData in finalRenderList {
                if renderData.tileIndex < tilesets[renderData.type.rawValue].tileCount {
                    try tilesets[renderData.type.rawValue].drawTile(on: surface, x: renderData.x, y: renderData.y, tileIndex: renderData.tileIndex, colorIndex: renderData.colorIndex)
                    try tilesets[renderData.type.rawValue].drawClippedTile(on: typeSurface, x: renderData.x, y: renderData.y, index: renderData.tileIndex, rgb: renderData.pixelColor)
                } else {
                    try buildingDeathTileset.drawTile(on: surface, x: renderData.x, y: renderData.y, index: renderData.tileIndex)
                }
            }
        }
    }

    func drawSelections(on surface: GraphicSurface, in rect: Rectangle, selectionList: [PlayerAsset], selectRect: Rectangle, highlightBuilding: Bool) throws {
        guard let playerData = playerData else {
            throw GameError.missingPlayerData
        }

        let resourceContext = surface.resourceContext
        let screenRightX = rect.xPosition + rect.width - 1
        let screenBottomY = rect.yPosition + rect.height - 1
        var rectangleColor = selfPixelColor

        if highlightBuilding {
            rectangleColor = buildingPixelColor
            resourceContext.setSourceRGB(rectangleColor)
            for asset in playerMap.assets {
                var renderData = Data()
                renderData.type = asset.type
                if renderData.type == AssetType.none {
                    continue
                }
                if 0 <= renderData.type.rawValue && renderData.type.rawValue < tilesets.count {
                    if asset.speed == 0 {
                        let offset = AssetType.goldMine == renderData.type ? 1 : 0

                        renderData.x = asset.positionX + (asset.size - 1) * Position.halfTileWidth - tilesets[renderData.type.rawValue].tileHalfWidth
                        renderData.y = asset.positionY + (asset.size - 1) * Position.halfTileHeight - tilesets[renderData.type.rawValue].tileHalfHeight
                        renderData.x -= offset * Position.tileWidth
                        renderData.y -= offset * Position.tileHeight

                        let rightX = renderData.x + tilesets[renderData.type.rawValue].tileWidth + (2 * offset * Position.tileWidth) - 1
                        renderData.bottomY = renderData.y + tilesets[renderData.type.rawValue].tileHeight + (2 * offset * Position.tileHeight) - 1
                        var onScreen = true
                        if (rightX < rect.xPosition) || (renderData.x > screenRightX) {
                            onScreen = false
                        } else if (renderData.bottomY < rect.yPosition) || (renderData.y > screenBottomY) {
                            onScreen = false
                        }
                        renderData.x -= rect.xPosition
                        renderData.y -= rect.yPosition
                        if onScreen {
                            resourceContext.rectangle(
                                x: renderData.x,
                                y: renderData.y,
                                width: tilesets[renderData.type.rawValue].tileWidth + (2 * offset * Position.tileWidth),
                                height: tilesets[renderData.type.rawValue].tileHeight + (2 * offset * Position.tileHeight)
                            )
                            resourceContext.stroke()
                        }
                    }
                }
            }
            rectangleColor = selfPixelColor
        }

        resourceContext.setSourceRGB(rectangleColor)
        if selectRect.width != 0 && selectRect.height != 0 {
            let selectionX = selectRect.xPosition - rect.xPosition
            let selectionY = selectRect.yPosition - rect.yPosition
            resourceContext.rectangle(x: selectionX, y: selectionY, width: selectRect.width, height: selectRect.height)
            resourceContext.stroke()
        }

        // FIXME: C++ implementation called lock()
        if let asset = selectionList.first {
            if asset.color == .none {
                rectangleColor = pixelColors[.none]!
            } else if asset.color != playerData.color {
                rectangleColor = enemyPixelColor
            }
            resourceContext.setSourceRGB(rectangleColor)
        }

        for asset in selectionList {
            var renderData = Data()
            renderData.type = asset.type
            if renderData.type == AssetType.none {
                if asset.action == AssetAction.decay {
                    var onScreen = true
                    renderData.x = asset.positionX - corpseTileset.tileWidth / 2
                    renderData.y = asset.positionY - corpseTileset.tileHeight / 2
                    let rightX = renderData.x + corpseTileset.tileWidth
                    renderData.bottomY = renderData.y + corpseTileset.tileHeight

                    if rightX < rect.xPosition || renderData.x > screenRightX {
                        onScreen = false
                    } else if renderData.bottomY < rect.yPosition || renderData.y > screenBottomY {
                        onScreen = false
                    }

                    renderData.x -= rect.xPosition
                    renderData.y -= rect.yPosition

                    if onScreen {
                        let actionSteps = corpseIndices.count / Direction.numberOfDirections
                        if actionSteps != 0 {
                            var currentStep = asset.step / (animationDownsample * targetFrequency)
                            if currentStep >= actionSteps {
                                currentStep = actionSteps - 1
                            }
                            renderData.tileIndex = corpseIndices[asset.direction.index * actionSteps + currentStep]
                        }
                        try corpseTileset.drawTile(on: surface, x: renderData.x, y: renderData.y, index: renderData.tileIndex)
                    }
                } else if asset.action == AssetAction.attack {
                    var onScreen = true
                    renderData.x = asset.positionX - markerTileset.tileWidth / 2
                    renderData.y = asset.positionY - markerTileset.tileHeight / 2
                    let rightX = renderData.x + markerTileset.tileWidth
                    renderData.bottomY = renderData.y + markerTileset.tileHeight

                    if rightX < rect.xPosition || renderData.x > screenRightX {
                        onScreen = false
                    } else if (renderData.bottomY < rect.yPosition) || (renderData.y > screenBottomY) {
                        onScreen = false
                    }

                    renderData.x -= rect.xPosition
                    renderData.y -= rect.yPosition

                    if onScreen {
                        let markerIndex = asset.step / animationDownsample
                        if markerIndex < markerIndices.count {
                            try markerTileset.drawTile(on: surface, x: renderData.x, y: renderData.y, index: markerIndices[markerIndex])
                        }
                    }
                }
            } else if renderData.type.rawValue >= 0 && renderData.type.rawValue < tilesets.count {
                var onScreen = true
                renderData.x = asset.positionX - Position.halfTileWidth
                renderData.y = asset.positionY - Position.halfTileHeight
                let rectWidth = Position.tileWidth * asset.size
                let rectHeight = Position.tileHeight * asset.size
                let rightX = renderData.x + rectWidth
                renderData.bottomY = renderData.y + rectHeight

                if rightX < rect.xPosition || renderData.x > screenRightX {
                    onScreen = false
                } else if renderData.bottomY < rect.yPosition || renderData.y > screenBottomY {
                    onScreen = false
                } else if asset.action == AssetAction.mineGold || asset.action == AssetAction.conveyLumber || asset.action == AssetAction.conveyGold {
                    onScreen = false
                }
                renderData.x -= rect.xPosition
                renderData.y -= rect.yPosition
                if onScreen {
                    resourceContext.rectangle(x: renderData.x, y: renderData.y, width: rectWidth, height: rectHeight)
                    resourceContext.stroke()
                }
            }
        }
    }

    func drawOverlays(on surface: GraphicSurface, in rect: Rectangle) throws {
        guard let playerData = playerData else {
            throw GameError.missingPlayerData
        }

        let screenRightX = rect.xPosition + rect.width - 1
        let screenBottomY = rect.yPosition + rect.height - 1

        for asset in playerMap.assets {
            var renderData = Data()
            renderData.type = asset.type

            if renderData.type == .none {
                if asset.action == .attack {
                    var onScreen = true
                    renderData.x = asset.positionX - arrowTileset.tileWidth / 2
                    renderData.y = asset.positionY - arrowTileset.tileHeight / 2
                    let rightX = renderData.x + arrowTileset.tileWidth
                    renderData.bottomY = renderData.y + arrowTileset.tileHeight

                    if rightX < rect.xPosition || renderData.x > screenRightX {
                        onScreen = false
                    } else if renderData.bottomY < rect.yPosition || renderData.y > screenBottomY {
                        onScreen = false
                    }
                    renderData.x -= rect.xPosition
                    renderData.y -= rect.yPosition
                    if onScreen {
                        let actionSteps = arrowIndices.count / Direction.numberOfDirections
                        try arrowTileset.drawTile(
                            on: surface,
                            x: renderData.x,
                            y: renderData.y,
                            index: arrowIndices[asset.direction.index * actionSteps + ((playerData.gameCycle - asset.creationCycle) % actionSteps)]
                        )
                    }
                }
            } else if asset.speed == 0 {
                let currentAction = asset.action
                if currentAction != .death {
                    var hitRange = asset.hitPoints * fireTilesets.count * 2 / asset.maxHitPoints
                    if currentAction == .construct {
                        var command = asset.currentCommand()
                        if let assetTarget = command.assetTarget {
                            command = assetTarget.currentCommand()
                            if command.activatedCapability != nil {
                                var divisor = command.activatedCapability?.percentComplete(max: asset.maxHitPoints)
                                divisor = divisor != 0 ? divisor : 1
                                hitRange = asset.hitPoints * fireTilesets.count * 2 / divisor!
                            }
                        } else if let activatedCapability = command.activatedCapability {
                            var divisor = activatedCapability.percentComplete(max: asset.maxHitPoints)
                            divisor = divisor != 0 ? divisor : 1
                            hitRange = asset.hitPoints * fireTilesets.count * 2 / divisor
                        }
                    }

                    if hitRange < fireTilesets.count {
                        let tilesetIndex = fireTilesets.count - 1 - hitRange
                        renderData.tileIndex = (playerData.gameCycle - asset.creationCycle) % fireTilesets[tilesetIndex].tileCount
                        renderData.x = asset.positionX + (asset.size - 1) * Position.halfTileWidth - fireTilesets[tilesetIndex].tileHalfWidth
                        renderData.y = asset.positionY + (asset.size - 1) * Position.halfTileHeight - fireTilesets[tilesetIndex].tileHeight
                        let rightX = renderData.x + fireTilesets[tilesetIndex].tileWidth - 1
                        renderData.bottomY = renderData.y + fireTilesets[tilesetIndex].tileHeight - 1
                        var onScreen = true

                        if rightX < rect.xPosition || renderData.x > screenRightX {
                            onScreen = false
                        } else if renderData.bottomY < rect.yPosition || renderData.y > screenBottomY {
                            onScreen = false
                        }
                        renderData.x -= rect.xPosition
                        renderData.y -= rect.yPosition

                        if onScreen {
                            try fireTilesets[tilesetIndex].drawTile(on: surface, x: renderData.x, y: renderData.y, index: renderData.tileIndex)
                        }
                    }
                }
            }
        }
    }

    func drawPlacement(on surface: GraphicSurface, in rect: Rectangle, position: Position, type: AssetType, builder: PlayerAsset) throws {
        guard type != .none else {
            return
        }
        // FIXME: MAKE DRAW PLACEMENT GREAT AGAIN
        // HACK - BEGIN
        //
        // HACK - END
        // ORIGINAL - BEGIN
        // guard let playerData = playerData else {
        //     throw GameError.missingPlayerData
        // }
        // ORIGINAL - END

        let screenRightX = rect.xPosition + rect.width - 1
        let screenBottomY = rect.yPosition + rect.height - 1

        var onScreen = true
        let assetType = PlayerAssetType.findDefault(from: type)
        var placementTiles = Array(repeating: [0], count: assetType.size)

        let tempPosition = Position()
        let tilePosition = Position()
        tilePosition.setToTile(position)
        tempPosition.setFromTile(tilePosition)

        tempPosition.x += (assetType.size - 1) * Position.halfTileWidth - tilesets[type.rawValue].tileHalfWidth
        tempPosition.y += (assetType.size - 1) * Position.halfTileHeight - tilesets[type.rawValue].tileHalfHeight
        let placementRightX = tempPosition.x + tilesets[type.rawValue].tileWidth
        let placementBottomY = tempPosition.y + tilesets[type.rawValue].tileHeight

        tilePosition.setToTile(position)
        var xOffset = 0
        var yOffset = 0

        for rowIndex in 0 ..< placementTiles.count {
            placementTiles[rowIndex] = Array(repeating: -1, count: assetType.size)
            for cellIndex in 0 ..< placementTiles[rowIndex].count {
                let tileType = playerMap.tileTypeAt(x: tilePosition.x + xOffset, y: tilePosition.y + yOffset)
                placementTiles[rowIndex][cellIndex] = tileType == .grass ? 1 : 0
                xOffset += 1
            }
            xOffset = 0
            yOffset += 1
        }

        xOffset = tilePosition.x + assetType.size
        yOffset = tilePosition.y + assetType.size

        for playerAsset in playerMap.assets {
            let offset = playerAsset.type == .goldMine ? 1 : 0

            if playerAsset === builder {
                continue
            }
            if xOffset <= playerAsset.tilePositionX - offset {
                continue
            }
            if tilePosition.x >= (playerAsset.tilePositionX + playerAsset.size + offset) {
                continue
            }
            if yOffset <= (playerAsset.tilePositionY - offset) {
                continue
            }
            if tilePosition.y >= (playerAsset.tilePositionY + playerAsset.size + offset) {
                continue
            }
            let minX = max(tilePosition.x, playerAsset.tilePositionX - offset)
            let maxX = min(xOffset, playerAsset.tilePositionX + playerAsset.size + offset)
            let minY = max(tilePosition.y, playerAsset.tilePositionY - offset)
            let maxY = min(yOffset, playerAsset.tilePositionY + playerAsset.size + offset)
            for y in minY ..< maxY {
                for x in minX ..< maxX {
                    placementTiles[y - tilePosition.y][x - tilePosition.x] = 0
                }
            }

            if placementRightX <= rect.xPosition {
                onScreen = false
            } else if placementBottomY <= rect.yPosition {
                onScreen = false
            } else if position.x >= screenRightX {
                onScreen = false
            } else if position.y >= screenBottomY {
                onScreen = false
            }

            if onScreen {
                position.x -= rect.xPosition
                position.y -= position.y - rect.yPosition
                // FIXME: MAKE DRAW PLACEMENT GREAT AGAIN
                // HACK - BEGIN
                try tilesets[type.rawValue].drawTile(on: surface, x: position.x, y: position.y, tileIndex: placeIndices[type.rawValue][0], colorIndex: 1)
                // HACK - END
                // ORIGINAL - BEGIN
                // try tilesets[type.rawValue].drawTile(on: surface, x: position.x, y: position.y, tileIndex: placeIndices[type.rawValue][0], colorIndex: playerData.color.index - 1)
                // ORIGINAL - END
                var x = position.x
                var y = position.y
                for row in placementTiles {
                    for cell in row {
                        try markerTileset.drawTile(on: surface, x: x, y: y, index: cell != 0 ? placeGoodIndex : placeBadIndex)
                        x += markerTileset.tileWidth
                    }
                    y += markerTileset.tileHeight
                    x = position.x
                }
            }
        }
    }

    func drawMiniAssets(on surface: GraphicSurface) {
        let resourceContext = surface.resourceContext
        if let playerData = playerData {
            for asset in playerMap.assets {
                let size = asset.size
                let pixelColor = asset.color == playerData.color ? selfPixelColor : pixelColors[asset.color]!
                resourceContext.setSourceRGB(pixelColor)
                resourceContext.rectangle(x: asset.tilePositionX, y: asset.tilePositionY, width: size, height: size)
                resourceContext.fill()
            }
        } else {
            for asset in playerMap.assetInitializationList {
                let size = PlayerAssetType.findDefault(from: asset.type).size
                let pixelColor = pixelColors[asset.color]!
                resourceContext.setSourceRGB(pixelColor)
                resourceContext.rectangle(x: asset.tilePosition.x, y: asset.tilePosition.y, width: size, height: size)
                resourceContext.fill()
            }
        }
    }
}
