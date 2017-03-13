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

    private static var animationDownsample = 1
    private static var targetFrequency = 10
    private static var _updateFrequency = 1
    static var updateFrequency: Int {
        set {
            animationDownsample = targetFrequency >= newValue ? 1 : newValue / targetFrequency
        }
        get {
            return targetFrequency * animationDownsample
        }
    }

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
            .none: colors.colorValue(gIndex: colors.findColor("none"), cIndex: 0),
            .blue: colors.colorValue(gIndex: colors.findColor("blue"), cIndex: 0),
            .red: colors.colorValue(gIndex: colors.findColor("red"), cIndex: 0),
            .green: colors.colorValue(gIndex: colors.findColor("green"), cIndex: 0),
            .purple: colors.colorValue(gIndex: colors.findColor("purple"), cIndex: 0),
            .orange: colors.colorValue(gIndex: colors.findColor("orange"), cIndex: 0),
            .yellow: colors.colorValue(gIndex: colors.findColor("yellow"), cIndex: 0),
            .black: colors.colorValue(gIndex: colors.findColor("black"), cIndex: 0),
            .white: colors.colorValue(gIndex: colors.findColor("white"), cIndex: 0)
        ]
        self.selfPixelColor = colors.colorValue(gIndex: colors.findColor("self"), cIndex: 0)

        while true {
            let index = markerTileset.findTile("marker-" + String(markerIndex))
            if index < 0 {
                break
            }
            markerIndices.append(index)
            markerIndex += 1
        }

        placeGoodIndex = markerTileset.findTile("place-good")
        placeBadIndex = markerTileset.findTile("place-bad")

        var lastDirectionName = "decay-nw"
        for directionName in ["decay-n", "decay-ne", "decay-e", "decay-se", "decay-s", "decay-sw", "decay-w", "decay-nw"] {
            var stepIndex = 0
            while true {
                var tileIndex = corpseTileset.findTile(directionName + String(stepIndex))
                if tileIndex >= 0 {
                    corpseIndices.append(tileIndex)
                } else {
                    tileIndex = corpseTileset.findTile(lastDirectionName + String(stepIndex))
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
                let tileIndex = arrowTileset.findTile(directionName + String(stepIndex))
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
                    let tileIndex = tileset.findTile(directionName + String(stepIndex))
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
                let tileIndex = tileset.findTile("construct-" + String(stepIndex))
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
                    let tileIndex = tileset.findTile(directionName + String(stepIndex))
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
                    let tileIndex = tileset.findTile(directionName + String(stepIndex))
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
                    let tileIndex = tileset.findTile(directionName + String(stepIndex))
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
                    if tileset.findTile("active") >= 0 {
                        tileIndex = tileset.findTile("active")
                        attackIndices[typeIndex].append(tileIndex)
                    } else if tileset.findTile("inactive") >= 0 {
                        tileIndex = tileset.findTile("inactive")
                        attackIndices[typeIndex].append(tileIndex)
                    }
                }
            }
            printDebug("Checking Death on \(typeIndex)", level: .low)
            var lastDirectionName = "death-nw"
            for directionName in ["death-n", "death-ne", "death-e", "death-se", "death-s", "death-sw", "death-w", "death-nw"] {
                var stepIndex = 0
                while true {
                    var tileIndex = tileset.findTile(directionName + String(stepIndex))
                    if tileIndex >= 0 {
                        deathIndices[typeIndex].append(tileIndex)
                    } else {
                        tileIndex = tileset.findTile(lastDirectionName + String(stepIndex))
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
                var tileIndex = tileset.findTile(directionName)
                if tileIndex >= 0 {
                    noneIndices[typeIndex].append(tileIndex)
                } else if walkIndices[typeIndex].count != 0 {
                    noneIndices[typeIndex].append(walkIndices[typeIndex][noneIndices[typeIndex].count * (walkIndices[typeIndex].count / Direction.numberOfDirections)])
                } else if tileset.findTile("inactive") >= 0 {
                    tileIndex = tileset.findTile("inactive")
                    noneIndices[typeIndex].append(tileIndex)
                }
            }
            printDebug("Checking Build on \(typeIndex)", level: .low)
            for directionName in ["build-n", "build-ne", "build-e", "build-se", "build-s", "build-sw", "build-w", "build-nw"] {
                var stepIndex = 0
                while true {
                    var tileIndex = tileset.findTile(directionName + String(stepIndex))
                    if tileIndex >= 0 {
                        buildIndices[typeIndex].append(tileIndex)
                    } else {
                        if stepIndex == 0 {
                            if tileset.findTile("active") >= 0 {
                                tileIndex = tileset.findTile("active")
                                buildIndices[typeIndex].append(tileIndex)
                            } else if tileset.findTile("inactive") >= 0 {
                                tileIndex = tileset.findTile("inactive")
                                buildIndices[typeIndex].append(tileIndex)
                            }
                        }
                        break
                    }
                    stepIndex += 1
                }
            }
            printDebug("Checking Place on \(typeIndex)", level: .low)
            placeIndices[typeIndex].append(tileset.findTile("place"))
            printDebug("Done checking type \(typeIndex)", level: .low)
            typeIndex += 1
        }
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

    func drawAssets(on surface: GraphicSurface, typeSurface: GraphicSurface, in rect: Rectangle) {
        let screenRightX = rect.x + rect.width - 1
        let screenBottomY = rect.y + rect.height - 1
        var finalRenderList: [Data] = []

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
            if rightX < rect.x || renderData.x > screenRightX {
                isOnScreen = false
            } else if renderData.bottomY < rect.y || renderData.y > screenBottomY {
                isOnScreen = false
            }

            guard isOnScreen else {
                continue
            }

            renderData.x -= rect.x
            renderData.y -= rect.y
            renderData.colorIndex = asset.color != .none ? asset.color.index - 1 : 0
            renderData.tileIndex = -1

            switch asset.action {
            case .build:
                let actionSteps = buildIndices[renderData.type.rawValue].count / Direction.numberOfDirections
                if actionSteps > 0 {
                    let tileIndex = asset.direction.index * actionSteps + ((asset.step / AssetRenderer.animationDownsample) % actionSteps)
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
                let tileIndex = asset.direction.index * actionSteps + ((asset.step / AssetRenderer.animationDownsample) % actionSteps)
                renderData.tileIndex = currentIndices[asset.type.rawValue][tileIndex]
            case .attack:
                let currentStep = asset.step % asset.attackSteps + asset.reloadSteps
                if currentStep < asset.attackSteps {
                    let actionSteps = attackIndices[asset.type.rawValue].count / Direction.numberOfDirections
                    let tileIndex = asset.direction.index * actionSteps + (currentStep * actionSteps) / asset.attackSteps
                    renderData.tileIndex = attackIndices[asset.type.rawValue][tileIndex]
                }
            case .repair, .harvestLumber:
                let actionSteps = attackIndices[renderData.type.hashValue].count / Direction.numberOfDirections
                let tileIndex = asset.direction.index * actionSteps + ((asset.step / AssetRenderer.animationDownsample) % actionSteps)
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
                    if asset.currentCommand.capability == .patrol || asset.currentCommand.capability == .standGround {
                        renderData.tileIndex = noneIndices[asset.type.rawValue][asset.direction.index]
                    }
                } else {
                    renderData.tileIndex = noneIndices[asset.type.rawValue][asset.direction.index]
                }
            case .death:
                let actionSteps = asset.speed > 0 ? deathIndices[asset.type.rawValue].count / Direction.numberOfDirections : deathIndices[asset.type.rawValue].count
                if asset.speed > 0 {
                    guard actionSteps > 0 else {
                        break
                    }
                    let currentStep = min(asset.step / AssetRenderer.animationDownsample, actionSteps - 1)
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
        }
        finalRenderList.sort { first, second in
            return compareRenderData(first: first, second: second)
        }

        for renderData in finalRenderList {
            if renderData.tileIndex < tilesets[renderData.type.rawValue].tileCount {
                tilesets[renderData.type.rawValue].drawTile(on: surface, x: renderData.x, y: renderData.y, tileIndex: renderData.tileIndex, colorIndex: renderData.colorIndex)
                tilesets[renderData.type.rawValue].drawClippedTile(on: typeSurface, x: renderData.x, y: renderData.y, index: renderData.tileIndex, rgb: renderData.pixelColor)
            } else {
                buildingDeathTileset.drawTile(on: surface, x: renderData.x, y: renderData.y, index: renderData.tileIndex)
            }
        }
    }

    func drawOverlays(on surface: GraphicSurface, in rect: Rectangle) {
        let screenRightX = rect.x + rect.width - 1
        let screenBottomY = rect.y + rect.height - 1

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

                    if rightX < rect.x || renderData.x > screenRightX {
                        onScreen = false
                    } else if renderData.bottomY < rect.y || renderData.y > screenBottomY {
                        onScreen = false
                    }
                    renderData.x -= rect.x
                    renderData.y -= rect.y
                    if onScreen {
                        let actionSteps = arrowIndices.count / Direction.numberOfDirections
                        arrowTileset.drawTile(
                            on: surface,
                            x: renderData.x,
                            y: renderData.y,
                            index: arrowIndices[asset.direction.index * actionSteps + ((playerData!.gameCycle - asset.creationCycle) % actionSteps)]
                        )
                    }
                }
            } else if asset.speed == 0 {
                let currentAction = asset.action
                if currentAction != .death {
                    var hitRange = asset.hitPoints * fireTilesets.count * 2 / asset.maxHitPoints
                    if currentAction == .construct {
                        var command = asset.currentCommand
                        if let assetTarget = command.assetTarget {
                            command = assetTarget.currentCommand
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
                        renderData.tileIndex = (playerData!.gameCycle - asset.creationCycle) % fireTilesets[tilesetIndex].tileCount
                        renderData.x = asset.positionX + (asset.size - 1) * Position.halfTileWidth - fireTilesets[tilesetIndex].tileHalfWidth
                        renderData.y = asset.positionY + (asset.size - 1) * Position.halfTileHeight - fireTilesets[tilesetIndex].tileHeight
                        let rightX = renderData.x + fireTilesets[tilesetIndex].tileWidth - 1
                        renderData.bottomY = renderData.y + fireTilesets[tilesetIndex].tileHeight - 1
                        var onScreen = true

                        if rightX < rect.x || renderData.x > screenRightX {
                            onScreen = false
                        } else if renderData.bottomY < rect.y || renderData.y > screenBottomY {
                            onScreen = false
                        }
                        renderData.x -= rect.x
                        renderData.y -= rect.y

                        if onScreen {
                            fireTilesets[tilesetIndex].drawTile(on: surface, x: renderData.x, y: renderData.y, index: renderData.tileIndex)
                        }
                    }
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
                let size = PlayerAssetType.findDefault(asset.type).size
                let pixelColor = pixelColors[asset.color]!
                resourceContext.setSourceRGB(pixelColor)
                resourceContext.rectangle(x: asset.tilePosition.x, y: asset.tilePosition.y, width: size, height: size)
                resourceContext.fill()
            }
        }
    }
}
