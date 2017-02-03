class AssetRenderer {
    private var playerData: PlayerData
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

    static func updateFrequency(_frequency: Int) -> Int {
        fatalError("This method is not yet implemented")
    }

    func drawAssets(on surface: GraphicSurface, typeSurface: GraphicSurface, rect: Rectangle) {
        fatalError("This method is not yet implemented")
    }

    func drawSelections(on surface: GraphicSurface, rect: Rectangle, selectionList: [PlayerAsset], selectRect: Rectangle, highlightBuilding: Bool) {
        fatalError("This method is not yet implemented")
    }

    func drawOverlays(on surface: GraphicSurface, rect: Rectangle) {
        fatalError("This method is not yet implemented")
    }

    func drawPlacement(on surface: GraphicSurface, rect: Rectangle, position: Position, type: AssetType, builder: PlayerAsset) {
        fatalError("This method is not yet implemented")
    }

    func drawMiniAssets(on surface: GraphicSurface) {
        fatalError("This method is not yet implemented")
    }
}
