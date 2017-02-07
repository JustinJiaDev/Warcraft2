import Foundation
import os.log

class AssetDecoratedMap: TerrainMap {

    enum GameError: Error {
        case missingFirstFileInterator
        case failedToReadResourceCount
        case failedToReadResource(index: Int)
        case tooFewTokensForResource(index: Int)
        case firstResourceIsNotForColorNone
        case failedToReadAssetCount
        case failedToReadAsset(index: Int)
        case tooFewTokensForAsset(index: Int)
        case invalidAssetPosition(x: Int, y: Int)
        case unknownColorIndex(index: Int)
    }

    enum SearchStatus {
        case unvisited, queued, visited
    }

    struct AssetInitialization {
        var type: String
        var color: PlayerColor
        var tilePosition: Position
    }

    struct ResourceInitialization {
        var color: PlayerColor
        var gold: Int
        var lumber: Int
    }

    struct SearchTile {
        var x: Int
        var y: Int
    }

    private(set) var assets: [PlayerAsset] = []
    private(set) var assetInitializationList: [AssetInitialization] = []
    private(set) var resourceInitializationList: [ResourceInitialization] = []
    private var searchMap: [[SearchStatus]] = []
    private static var mapNameTranslation: [String: Int] = [:]
    private static var all: [AssetDecoratedMap] = []

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
        assetInitializationList = map.assetInitializationList.map { asset in
            guard asset.color.index < newColors.count else {
                return asset
            }
            var asset = asset
            asset.color = newColors[asset.color.index]
            return asset
        }
        resourceInitializationList = map.resourceInitializationList.map { resource in
            guard resource.color.index < newColors.count else {
                return resource
            }
            var resource = resource
            resource.color = newColors[resource.color.index]
            return resource
        }
    }

    static func loadMaps(container: DataContainer) throws {
        guard let fileIterator = container.first() else {
            throw GameError.missingFirstFileInterator
        }
        while fileIterator.isValid() {
            let filename = fileIterator.name()
            fileIterator.next()
            if filename.hasSuffix(".map") {
                do {
                    let map = AssetDecoratedMap()
                    try map.loadMap(source: container.dataSource(name: filename))
                    mapNameTranslation[map.mapName] = all.count
                    all.append(map)
                    printDebug("Loaded map \(filename).", level: .low)
                } catch {
                    printError("Failed to load map \(filename) (Error: \(error)).")
                }
            }
        }
        printDebug("Maps loaded.", level: .low)
    }

    static func mapIndex(of name: String) -> Int {
        return mapNameTranslation[name] ?? -1
    }

    static func map(at index: Int) -> AssetDecoratedMap {
        guard index >= 0 && index < all.count else {
            return AssetDecoratedMap()
        }
        return all[index]
    }

    static func duplicateMap(at index: Int, newColors: [PlayerColor]) -> AssetDecoratedMap {
        guard index >= 0 && index < all.count else {
            return AssetDecoratedMap()
        }
        return AssetDecoratedMap(map: all[index], newColors: newColors)
    }

    func addAsset(_ asset: PlayerAsset) {
        assets.append(asset)
    }

    func removeAsset(_ asset: PlayerAsset) {
        if let index = assets.index(where: { $0 === asset }) {
            assets.remove(at: index)
        }
    }

    func findNearestAsset(at position: Position, color: PlayerColor, type: AssetType) -> PlayerAsset {
        var bestAsset = assets[0]
        var bestDistanceSquared = -1
        for asset in assets {
            if asset.type == type && asset.color == color && AssetAction.construct != asset.action {
                let currentDistance = asset.position.distanceSquared(position)
                if bestDistanceSquared == -1 || currentDistance < bestDistanceSquared {
                    bestDistanceSquared = currentDistance
                    bestAsset = asset
                }
            }
        }
        return bestAsset
    }

    func canPlaceAsset(at position: Position, size: Int, ignoreAsset: PlayerAsset) -> Bool {
        var rightX: Int
        var bottomY: Int

        for yOffset in 0 ..< size {
            for xOffset in 0 ..< size {
                let tileTerrainType = tileTypeAt(x: position.x + xOffset, y: position.y + yOffset)
                if TileType.grass != tileTerrainType
                    && TileType.dirt != tileTerrainType
                    && TileType.stump != tileTerrainType
                    && TileType.rubble != tileTerrainType {
                    return false
                }
            }
        }
        rightX = position.x + size
        bottomY = position.y + size
        if rightX >= width {
            return false
        }
        if bottomY >= height {
            return false
        }
        for asset in assets {
            let offset = (AssetType.goldMine == asset.type) ? 1 : 0
            if .none == asset.type
                || ignoreAsset === asset
                || rightX <= asset.tilePositionX - offset
                || position.x >= asset.tilePositionX + asset.size + offset
                || bottomY <= asset.tilePositionY - offset
                || position.y >= asset.tilePositionY + asset.size + offset {
                continue
            } else {
                return false
            }
        }
        return true
    }

    func findAssetPlacement(placeAsset: PlayerAsset, fromAsset: PlayerAsset, nextTileTarget: Position) -> Position {
        var bestDistance = -1
        var bestPosition = Position(x: -1, y: -1)
        var topY = fromAsset.tilePositionY - placeAsset.size
        var bottomY = fromAsset.tilePositionY + fromAsset.size
        var leftX = fromAsset.tilePositionX - placeAsset.size
        var rightX = fromAsset.tilePositionX + fromAsset.size
        while true {
            var skipped = 0
            if topY >= 0 {
                let toX = min(rightX, width - 1)
                for x in max(leftX, 0) ... toX {
                    if canPlaceAsset(at: Position(x: x, y: topY), size: placeAsset.size, ignoreAsset: placeAsset) {
                        let position = Position(x: x, y: topY)
                        let currentDistance = position.distanceSquaredFrom(position: nextTileTarget)
                        if -1 == bestDistance || currentDistance < bestDistance {
                            bestDistance = currentDistance
                            bestPosition = position
                        }
                    }
                }
            } else {
                skipped += 1
            }
            if width > rightX {
                let toY = min(bottomY, height - 1)
                for y in max(topY, 0) ... toY {
                    if canPlaceAsset(at: Position(x: rightX, y: y), size: placeAsset.size, ignoreAsset: placeAsset) {
                        let position = Position(x: rightX, y: y)
                        let currentDistance = position.distanceSquaredFrom(position: nextTileTarget)
                        if -1 == bestDistance || currentDistance < bestDistance {
                            bestDistance = currentDistance
                            bestPosition = position
                        }
                    }
                }
            } else {
                skipped += 1
            }
            if height > bottomY {
                let toX = max(leftX, 0)
                for x in (toX ... min(rightX, width - 1)).reversed() {
                    if canPlaceAsset(at: Position(x: x, y: bottomY), size: placeAsset.size, ignoreAsset: placeAsset) {
                        let position = Position(x: x, y: bottomY)
                        let currentDistance = position.distanceSquared(nextTileTarget)
                        if -1 == bestDistance || currentDistance < bestDistance {
                            bestDistance = currentDistance
                            bestPosition = position
                        }
                    }
                }
            } else {
                skipped += 1
            }
            if leftX >= 0 {
                let toY = max(topY, 0)
                for y in (toY ... min(bottomY, height - 1)).reversed() {
                    if canPlaceAsset(at: Position(x: leftX, y: y), size: placeAsset.size, ignoreAsset: placeAsset) {
                        let position = Position(x: leftX, y: y)
                        let currentDistance = position.distanceSquared(nextTileTarget)
                        if -1 == bestDistance || currentDistance < bestDistance {
                            bestDistance = currentDistance
                            bestPosition = position
                        }
                    }
                }
            } else {
                skipped += 1
            }
            if skipped == 4 {
                break
            }
            if bestDistance != -1 {
                break
            }
            topY -= 1
            bottomY += 1
            leftX -= 1
            rightX += 1
        }
        return bestPosition
    }

    override func loadMap(source: DataSource) throws {
        try super.loadMap(source: source)

        let lineSource = LineDataSource(dataSource: source)

        resourceInitializationList = []
        guard let resourceCountString = lineSource.readLine(), let resourceCount = Int(resourceCountString) else {
            throw GameError.failedToReadResourceCount
        }
        for index in 0 ... resourceCount {
            guard let currentLine = lineSource.readLine() else {
                throw GameError.failedToReadResource(index: index)
            }
            let tokens = Tokenizer.tokenize(data: currentLine)
            guard tokens.count >= 3, let playerColorIndex = Int(tokens[0]), let gold = Int(tokens[1]), let lumber = Int(tokens[2]) else {
                throw GameError.tooFewTokensForResource(index: index)
            }
            guard let playerColor = PlayerColor(index: playerColorIndex) else {
                throw GameError.unknownColorIndex(index: playerColorIndex)
            }
            if index == 0 && playerColor != .none {
                throw GameError.firstResourceIsNotForColorNone
            }
            resourceInitializationList.append(ResourceInitialization(color: playerColor, gold: gold, lumber: lumber))
        }

        assetInitializationList = []
        guard let assetCountString = lineSource.readLine(), let assetCount = Int(assetCountString) else {
            throw GameError.failedToReadAssetCount
        }
        for index in 0 ..< assetCount {
            guard let currentLine = lineSource.readLine() else {
                throw GameError.failedToReadAsset(index: index)
            }

            let tokens = Tokenizer.tokenize(data: currentLine)
            guard tokens.count >= 4, let type = tokens.first, let playerColorIndex = Int(tokens[1]), let x = Int(tokens[2]), let y = Int(tokens[3]) else {
                throw GameError.tooFewTokensForAsset(index: index)
            }
            guard x >= 0, y >= 0, x < width, y < width else {
                throw GameError.invalidAssetPosition(x: x, y: y)
            }
            guard let color = PlayerColor(index: playerColorIndex) else {
                throw GameError.unknownColorIndex(index: playerColorIndex)
            }
            let position = Position(x: x, y: y)
            assetInitializationList.append(AssetInitialization(type: type, color: color, tilePosition: position))
        }
    }

    func createInitializeMap() -> AssetDecoratedMap {
        let returnMap = AssetDecoratedMap()
        if returnMap.map.count != map.count {
            returnMap.map = Array(repeating: Array(repeating: .none, count: map[0].count), count: map.count)
        }
        return returnMap
    }

    func createVisibilityMap() -> VisibilityMap {
        return VisibilityMap(width: width, height: height, maxVisibility: PlayerAssetType.maxSight)
    }

    func updateMap(visibilityMap: VisibilityMap, assetDecoratedMap: AssetDecoratedMap) {
        if map.count != assetDecoratedMap.map.count {
            assetDecoratedMap.map = Array(repeating: Array(repeating: .none, count: assetDecoratedMap.map[0].count), count: assetDecoratedMap.map.count)
        }
        for (index, asset) in assets.enumerated().reversed() {
            let currentPosition = asset.tilePosition
            let assetSize = asset.size
            var removeAsset = false
            if asset.speed != 0 || asset.action == AssetAction.decay || asset.action == AssetAction.attack {
                assets.remove(at: index)
                continue
            }
            for yOffset in 0 ..< assetSize {
                let yPosition = currentPosition.y + yOffset
                for xOffset in 0 ..< assetSize {
                    let xPosition = currentPosition.x + xOffset
                    let tileType = visibilityMap.tileTypeAt(x: xPosition, y: yPosition)
                    if tileType == .partial || tileType == .partialPartial || tileType == .visible {
                        removeAsset = (asset.type != .none) // Remove visible so they can be updated
                        break
                    }
                }
                if removeAsset {
                    break
                }
            }
            if removeAsset {
                assets.remove(at: index)
            }
        }
        for yPosition in 0 ..< map.count {
            for xPosition in 0 ..< map[yPosition].count {
                let type = visibilityMap.tileTypeAt(x: xPosition - 1, y: yPosition - 1)
                if type == .partial || type == .partialPartial || type == .visible {
                    map[yPosition][xPosition] = assetDecoratedMap.map[yPosition][xPosition]
                }
            }
        }
        for asset in assetDecoratedMap.assets {
            let currentPosition = asset.tilePosition
            let assetSize = asset.size
            var addAsset = false

            for yOffset in 0 ..< assetSize {
                let yPosition = currentPosition.y + yOffset
                for xOffset in 0 ..< assetSize {
                    let xPosition = currentPosition.x + xOffset
                    let type = visibilityMap.tileTypeAt(x: xPosition, y: yPosition)
                    if type == .partial || type == .partialPartial || type == .visible {
                        addAsset = true // Add visible resources
                        break
                    }
                }
                if addAsset {
                    assets.append(asset)
                    break
                }
            }
        }
    }

    func findNearestReachableTileType(at position: Position, type: TileType) -> Position {
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
            if asset.tilePosition != position {
                for y in 0 ..< asset.size {
                    for x in 0 ..< asset.size {
                        searchMap[asset.tilePositionY + y + 1][asset.tilePositionX + x + 1] = .visited
                    }
                }
            }
        }
        currentSearch.x = position.x + 1
        currentSearch.y = position.y + 1
        searchQueueArray.append(currentSearch)
        while searchQueueArray.count > 0 {
            currentSearch = searchQueueArray[0]
            searchQueueArray.remove(at: 0)
            searchMap[currentSearch.y][currentSearch.x] = .visited
            for index in 0 ..< searchXOffsets.count {
                tempSearch.x = currentSearch.x + searchXOffsets[index]
                tempSearch.y = currentSearch.y + searchYOffsets[index]
                if searchMap[tempSearch.y][tempSearch.x] == .unvisited {
                    let tileType = map[tempSearch.y][tempSearch.x]
                    searchMap[tempSearch.y][tempSearch.x] = .queued
                    if type == tileType {
                        return Position(x: tempSearch.x, y: tempSearch.y)
                    }
                    if tileType == .grass || tileType == .dirt || tileType == .stump || tileType == .rubble || tileType == .none {
                        searchQueueArray.append(tempSearch)
                    }
                }
            }
        }
        return Position(x: -1, y: -1)
    }
}
