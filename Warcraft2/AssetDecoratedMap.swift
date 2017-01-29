/*
 Copyright (c) 2015, Christopher Nitta
 All rights reserved.

 All source material (source code, images, sounds, etc.) have been provided to
 University of California, Davis students of course ECS 160 for educational
 purposes. It may not be distributed beyond those enrolled in the course without
 prior permission from the copyright holder.

 All sound files, sound fonts, midi files, and images that have been included
 that were extracted from original Warcraft II by Blizzard Entertainment
 were found freely available via internet sources and have been labeld as
 abandonware. They have been included in this distribution for educational
 purposes only and this copyright notice does not attempt to claim any
 ownership of this material.
 */

class AssetDecoratedMap: TerrainMap {
    struct AssetInitialization {
        var type: String
        var color: PlayerColor
        var tilePosition: Position
    }

    struct ResourceInitialization {
        var color = PlayerColor.none
        var gold = 0
        var lumber = 0
    }

    struct SearchTile {
        var x: Int
        var y: Int
    }

    enum SearchStatus {
        case unvisited, queued, visited
    }

    private(set) var assets: [PlayerAsset] = []
    private(set) var assetInitializationList: [AssetInitialization] = []
    private(set) var resourceInitializationList: [ResourceInitialization] = []
    private var searchMap: [[SearchStatus]] = []
    private static var mapNameTranslation: [String: Int] = [:]
    private static var allMaps: [AssetDecoratedMap] = []

    override var playerCount: Int {
        return resourceInitializationList.count - 1
    }

    override init() {
        super.init()
    }

    init(map: AssetDecoratedMap) {
        super.init(terrainMap: map)
        assets = map.assets
        assetInitializationList = map.assetInitializationList
        resourceInitializationList = map.resourceInitializationList
    }

    init(map: AssetDecoratedMap, newColors: [PlayerColor]) {
        super.init(terrainMap: map)
        assets = map.assets
        for initVal in map.assetInitializationList {
            var newInitVal = initVal
            if newColors.count > initVal.color.rawValue {
                newInitVal.color = newColors[newInitVal.color.rawValue]
            }
            assetInitializationList.append(newInitVal)
        }

        for initVal in map.resourceInitializationList {
            var newInitVal = initVal
            if newColors.count > initVal.color.rawValue {
                newInitVal.color = newColors[newInitVal.color.rawValue]
            }
            resourceInitializationList.append(newInitVal)
        }
    }

    static func loadMaps(container: DataContainer) -> Bool {
        func generateError(_ msg: String) -> Bool {
            PrintError(msg + "\n")
            return false
        }

        let fileIterator = container.first()
        if fileIterator == nil {
            return generateError("FileIterator == nil")
        }
        while fileIterator != nil && fileIterator!.isValid() {
            let filename = fileIterator!.name()
            fileIterator!.next()
            if filename.hasSuffix(".map") {
                let tempMap = AssetDecoratedMap()
                if !tempMap.loadMap(source: container.dataSource(name: filename)) {
                    PrintError("Failed to load map \(filename).\n")
                    continue
                } else {
                    PrintDebug("Loaded map \(filename).\n")
                }
                mapNameTranslation[tempMap.mapName] = allMaps.count
                allMaps.append(tempMap)
            }
        }
        PrintDebug("Maps loaded\n")
        return true
    }

    static func findMapIndex(name: String) -> Int {
        if let val = mapNameTranslation[name] {
            return val
        } else {
            return -1
        }
    }

    static func getMap(index: Int) -> AssetDecoratedMap {
        if 0 > index || allMaps.count <= index {
            return AssetDecoratedMap()
        }
        return allMaps[index]
    }

    static func duplicateMap(index: Int, newColors: [PlayerColor]) -> AssetDecoratedMap {
        if 0 > index || allMaps.count <= index {
            return AssetDecoratedMap()
        }
        return AssetDecoratedMap(map: allMaps[index], newColors: newColors)
    }

    func addAsset(asset: PlayerAsset) -> Bool {
        assets.append(asset)
        return true
    }

    func removeAsset(asset: PlayerAsset) -> Bool {
        for i in 0 ..< assets.count {
            if assets[i] === asset {
                assets.remove(at: i)
                break
            }
        }
        return true
    }

    func findNearestAsset(pos: Position, color: PlayerColor, type: AssetType) -> PlayerAsset {
        var bestAsset = assets[0]
        var bestDistanceSquared = -1

        for asset in assets {
            if asset.type == type && asset.color == color && AssetAction.construct != asset.action {
                let currentDistance = asset.position.distanceSquared(pos)
                if -1 == bestDistanceSquared || currentDistance < bestDistanceSquared {
                    bestDistanceSquared = currentDistance
                    bestAsset = asset
                }
            }
        }
        return bestAsset
    }

    func canPlaceAsset(pos: Position, size: Int, ignoreAsset: PlayerAsset) -> Bool {
        var rightX: Int
        var bottomY: Int

        for yOff in 0 ..< size {
            for xOff in 0 ..< size {
                let tileTerrainType = tileTypeAt(x: pos.x + xOff, y: pos.y + yOff)
                if TileType.grass != tileTerrainType
                    && TileType.dirt != tileTerrainType
                    && TileType.stump != tileTerrainType
                    && TileType.rubble != tileTerrainType {
                    return false
                }
            }
        }
        rightX = pos.x + size
        bottomY = pos.y + size
        if rightX >= width {
            return false
        }
        if bottomY >= height {
            return false
        }
        for asset in assets {
            let offset = (AssetType.goldMine == asset.type) ? 1 : 0
            if AssetType.none == asset.type
                || ignoreAsset === asset
                || rightX <= asset.tilePositionX() - offset
                || pos.x >= asset.tilePositionX() + asset.size + offset
                || bottomY <= asset.tilePositionY() - offset
                || pos.y >= asset.tilePositionY() + asset.size + offset {
                // do nothing
            } else {
                return false
            }
        }
        return true
    }

    func findAssetPlacement(placeAsset: PlayerAsset, fromAsset: PlayerAsset, nextTileTarget: Position) -> Position {
        var topY, bottomY, leftX, rightX: Int
        var bestDistance = -1
        var curDistance: Int
        var bestPosition = Position(x: -1, y: -1)
        topY = fromAsset.tilePositionY() - placeAsset.size
        bottomY = fromAsset.tilePositionY() + fromAsset.size
        leftX = fromAsset.tilePositionX() - placeAsset.size
        rightX = fromAsset.tilePositionX() + fromAsset.size

        while true {
            var skipped = 0
            if 0 <= topY {
                let toX = min(rightX, width - 1)
                for curX in max(leftX, 0) ... toX {
                    if canPlaceAsset(pos: Position(x: curX, y: topY), size: placeAsset.size, ignoreAsset: placeAsset) {
                        let tempPosition = Position(x: curX, y: topY)
                        curDistance = tempPosition.distanceSquaredFrom(position: nextTileTarget)
                        if -1 == bestDistance || curDistance < bestDistance {
                            bestDistance = curDistance
                            bestPosition = tempPosition
                        }
                    }
                }
            } else {
                skipped += 1
            }
            if width > rightX {
                let toY = min(bottomY, height - 1)
                for curY in max(topY, 0) ... toY {
                    if canPlaceAsset(pos: Position(x: rightX, y: curY), size: placeAsset.size, ignoreAsset: placeAsset) {
                        let tempPosition = Position(x: rightX, y: curY)
                        curDistance = tempPosition.distanceSquaredFrom(position: nextTileTarget)
                        if -1 == bestDistance || curDistance < bestDistance {
                            bestDistance = curDistance
                            bestPosition = tempPosition
                        }
                    }
                }
            } else {
                skipped += 1
            }
            if height > bottomY {
                let ToX = max(leftX, 0)
                for curX in (ToX ... min(rightX, width - 1)).reversed() {
                    if canPlaceAsset(pos: Position(x: curX, y: bottomY), size: placeAsset.size, ignoreAsset: placeAsset) {
                        let tempPosition = Position(x: curX, y: bottomY)
                        curDistance = tempPosition.distanceSquared(nextTileTarget)
                        if -1 == bestDistance || curDistance < bestDistance {
                            bestDistance = curDistance
                            bestPosition = tempPosition
                        }
                    }
                }
            } else {
                skipped += 1
            }
            if 0 <= leftX {
                let toY = max(topY, 0)
                for curY in (toY ... min(bottomY, height - 1)).reversed() {
                    if canPlaceAsset(pos: Position(x: leftX, y: curY), size: placeAsset.size, ignoreAsset: placeAsset) {
                        let tempPosition = Position(x: leftX, y: curY)
                        curDistance = tempPosition.distanceSquared(nextTileTarget)
                        if -1 == bestDistance || curDistance < bestDistance {
                            bestDistance = curDistance
                            bestPosition = tempPosition
                        }
                    }
                }
            } else {
                skipped += 1
            }
            if 4 == skipped {
                break
            }
            if -1 != bestDistance {
                break
            }
            topY -= 1
            bottomY += 1
            leftX -= 1
            rightX += 1
        }
        return bestPosition
    }

    func loadMap(source: DataSource) -> Bool {
        let lineSource = LineDataSource(dataSource: source)
        var tempResourceInit = ResourceInitialization()
        var tempAssetInit: AssetInitialization
        var assetCount: Int

        func generateError(_ msg: String) -> Bool {
            PrintError(msg + "\n")
            return false
        }

        do {
            try super.loadMap(source: source)
        } catch {
            return false
        }

        var tempString = lineSource.readLine()
        if tempString == nil { return generateError("Failed to read map resource count.") }

        let resourceCount = Int(tempString!)!
        resourceInitializationList = []
        for index in 0 ..< resourceCount {
            tempString = lineSource.readLine()
            if tempString == nil { return generateError("Failed to read map resource \(index).") }
            let tokens = Tokenizer.tokenize(data: tempString!)
            if 3 > tokens.count {
                return generateError("Too few tokens for resource \(index).")
            }
            tempResourceInit.color = PlayerColor(rawValue: Int(tokens[0])!)!
            if 0 == index && PlayerColor.none != tempResourceInit.color {
                return generateError("Expected first resource to be for color None.")
            }

            tempResourceInit.gold = Int(tokens[1])!
            tempResourceInit.lumber = Int(tokens[2])!
            resourceInitializationList.append(tempResourceInit)
        }

        tempString = lineSource.readLine()
        if tempString == nil { return generateError("Failed to read map asset count.") }
        assetCount = Int(tempString!)!
        assetInitializationList = []
        for index in 0 ..< assetCount {
            tempString = lineSource.readLine()
            if tempString == nil { return generateError("Failed to read map asset \(index).") }

            let tokens = Tokenizer.tokenize(data: tempString!)
            if 4 > tokens.count {
                return generateError("Too few toeksn for asset \(index).")
            }
            let color = PlayerColor(rawValue: Int(tokens[1])!)!
            let position = Position(x: Int(tokens[2])!, y: Int(tokens[3])!)
            let tempAssetInit = AssetInitialization(type: tokens[0], color: color, tilePosition: position)

            if (0 > tempAssetInit.tilePosition.x || 0 > tempAssetInit.tilePosition.y)
                || (width <= tempAssetInit.tilePosition.x || height <= tempAssetInit.tilePosition.y) {
                return generateError("Invalid resource position \(index) (\(tempAssetInit.tilePosition.x), \(tempAssetInit.tilePosition.y)).")
            }
            assetInitializationList.append(tempAssetInit)
        }
        return true
    }

    func createInitializeMap() -> AssetDecoratedMap {
        let returnMap = AssetDecoratedMap()
        if returnMap.map.count != map.count {
            returnMap.map = Array(repeating: Array(repeating: .none, count: map[0].count), count: map.count)
        }
        return returnMap
    }

    func createVisibilityMap() -> VisibilityMap {
        return VisibilityMap(width: width, height: height, maxVisibility: PlayerAssetType.maxSight())
    }

    func updateMap(visMap: VisibilityMap, resMap: AssetDecoratedMap) -> Bool {
        if map.count != resMap.map.count {
            resMap.map = Array(repeating: Array(repeating: .none, count: resMap.map[0].count), count: resMap.map.count)
        }
        for (i, asset) in assets.enumerated().reversed() {
            let curPosition = asset.tilePosition
            let assetSize = asset.size
            var removeAsset = false
            if asset.speed != 0 || asset.action == AssetAction.decay || asset.action == AssetAction.attack {
                assets.remove(at: i)
                continue
            }
            for yOff in 0 ..< assetSize {
                let yPos = curPosition.y + yOff
                for xOff in 0 ..< assetSize {
                    let xPos = curPosition.x + xOff
                    let visType = visMap.tileType(xIndex: xPos, yIndex: yPos)
                    if visType == VisibilityMap.TileVisibility.partial
                        || visType == VisibilityMap.TileVisibility.partialPartial
                        || visType == VisibilityMap.TileVisibility.visible {
                        // Remove visible so they can be updated
                        removeAsset = AssetType.none != asset.type
                        break
                    }
                }
                if removeAsset {
                    break
                }
            }
            if removeAsset {
                assets.remove(at: i)
            }
        }
        for yPos in 0 ..< map.count {
            for xPos in 0 ..< map[yPos].count {
                let visType = visMap.tileType(xIndex: xPos - 1, yIndex: yPos - 1)
                if visType == VisibilityMap.TileVisibility.partial
                    || visType == VisibilityMap.TileVisibility.partialPartial
                    || visType == VisibilityMap.TileVisibility.visible {
                    map[yPos][xPos] = resMap.map[yPos][xPos]
                }
            }
        }
        for asset in resMap.assets {
            let curPosition = asset.tilePosition
            let assetSize = asset.size
            var addAsset = false

            for yOff in 0 ..< assetSize {
                let yPos = curPosition.y + yOff
                for xOff in 0 ..< assetSize {
                    let xPos = curPosition.x + xOff

                    let visType = visMap.tileType(xIndex: xPos, yIndex: yPos)
                    if visType == VisibilityMap.TileVisibility.partial
                        || visType == VisibilityMap.TileVisibility.partialPartial
                        || visType == VisibilityMap.TileVisibility.visible {
                        // Add visible resources
                        addAsset = true
                        break
                    }
                }
                if addAsset {
                    assets.append(asset)
                    break
                }
            }
        }
        return true
    }

    func findNearestReachableTileType(pos: Position, type: TileType) -> Position {
        var searchQueueArray: [SearchTile] = []
        var currentSearch = SearchTile(x: 0, y: 0)
        var tempSearch = SearchTile(x: 0, y: 0)
        let mapWidth = width
        let mapHeight = height
        let searchXOffsets = [0, 1, 0, -1]
        let searchYOffsets = [ -1, 0, 1, 0]

        if searchMap.count != map.count {
            searchMap = Array(repeating: Array(repeating: .unvisited, count: map[0].count), count: map.count)
            let lastYIndex = map.count - 1
            let lastXIndex = map[0].count - 1
            for index in 0 ..< map.count {
                searchMap[index][0] = .visited
                searchMap[index][lastXIndex] = .visited
            }
            for index in 1 ..< lastXIndex {
                searchMap[0][index] = .visited
                searchMap[lastYIndex][index] = .visited
            }
        }
        for y in 0 ..< mapHeight {
            for x in 0 ..< mapWidth {
                searchMap[y + 1][x + 1] = .unvisited
            }
        }
        for asset in assets {
            if asset.tilePosition != pos {
                for y in 0 ..< asset.size {
                    for x in 0 ..< asset.size {
                        searchMap[asset.tilePositionY() + y + 1][asset.tilePositionX() + x + 1] = .visited
                    }
                }
            }
        }
        currentSearch.x = pos.x + 1
        currentSearch.y = pos.y + 1
        searchQueueArray.append(currentSearch)
        while searchQueueArray.count > 0 {
            currentSearch = searchQueueArray.first!
            searchQueueArray.remove(at: 0)
            searchMap[currentSearch.y][currentSearch.x] = .visited
            for index in 0 ..< searchXOffsets.count {
                tempSearch.x = currentSearch.x + searchXOffsets[index]
                tempSearch.y = currentSearch.y + searchYOffsets[index]
                if searchMap[tempSearch.y][tempSearch.x] == .unvisited {
                    let curTileType = map[tempSearch.y][tempSearch.x]
                    searchMap[tempSearch.y][tempSearch.x] = .queued
                    if type == curTileType {
                        return Position(x: tempSearch.x, y: tempSearch.y)
                    }
                    if TileType.grass == curTileType
                        || TileType.dirt == curTileType
                        || TileType.stump == curTileType
                        || TileType.rubble == curTileType
                        || TileType.none == curTileType {
                        searchQueueArray.append(tempSearch)
                    }
                }
            }
        }
        return Position(x: -1, y: -1)
    }
}
