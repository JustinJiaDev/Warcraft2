import Foundation

class GraphicTileset {

    enum GameError: Error {
        case failedToGetPath
        case failedToLoadFile(path: String)
        case failedToReadTileCount
        case failedToReadTileName
        case indexOutOfBound(index: Int)
        case missingTileset
        case missingTileName
    }

    private var surfaceTileset: GraphicSurface?
    private var clippingMasks: [Int: GraphicSurface] = [:]

    private var tileIndex: [String: Int] = [:]
    private var tileNames: [String] = []
    private var groupSteps: [String: Int] = [:]
    private var groupNames: [String] = []

    private(set) var tileCount: Int = 0
    private(set) var tileWidth: Int = 0
    private(set) var tileHeight: Int = 0

    var tileHalfWidth: Int {
        return tileWidth / 2
    }

    var tileHalfHeight: Int {
        return tileHeight / 2
    }

    var groupCount: Int {
        return groupNames.count
    }

    private static func parseGroupName(_ tileName: String) -> (String, Int)? {
        var name = tileName
        var numberString = ""
        while name.unicodeScalars.count > 0 {
            guard let last = name.unicodeScalars.last, !CharacterSet.decimalDigits.contains(last) else {
                numberString.unicodeScalars.insert(name.unicodeScalars.removeLast(), at: numberString.unicodeScalars.startIndex)
                continue
            }
            guard !numberString.isEmpty, let number = Int(numberString) else {
                return nil
            }
            return (name, number)
        }
        return nil
    }

    private func updateGroupNames() {
        groupSteps.removeAll()
        groupNames.removeAll()
        for tileName in tileNames {
            guard let (groupName, groupStep) = GraphicTileset.parseGroupName(tileName) else {
                continue
            }
            if let oldGroupStep = groupSteps[groupName] {
                groupSteps[groupName] = max(oldGroupStep, groupStep + 1)
            } else {
                groupSteps[groupName] = groupStep + 1
                groupNames.append(groupName)
            }
        }
    }

    func setTileCount(_ count: Int) -> Int {
        guard count > 0, tileWidth > 0, tileHeight > 0, let surfaceTileset = surfaceTileset else {
            return tileCount
        }

        guard count >= tileCount else {
            tileCount = count
            tileIndex.keys.filter { key in
                return self.tileIndex[key]! >= self.tileCount
            }.forEach { key in
                self.tileIndex.removeValue(forKey: key)
            }
            updateGroupNames()
            return tileCount
        }

        guard let newSurface = GraphicFactory.createSurface(width: tileWidth, height: tileHeight * count, format: surfaceTileset.format) else {
            return tileCount
        }
        do {
            try newSurface.copy(from: surfaceTileset, dx: 0, dy: 0, width: -1, height: -1, sx: 0, sy: 0)
        } catch {
            return tileCount
        }
        self.surfaceTileset = newSurface
        tileCount = count
        return tileCount
    }

    func findTile(with name: String) -> Int {
        return tileIndex[name] ?? -1
    }

    func groupName(at index: Int) -> String {
        guard index >= 0 || index < groupNames.count else {
            return ""
        }
        return groupNames[index]
    }

    func groupSteps(at index: Int) -> Int {
        return groupSteps(of: groupName(at: index))
    }

    func groupSteps(of groupName: String) -> Int {
        return groupSteps[groupName] ?? 0
    }

    func drawTile(on surface: GraphicSurface, x: Int, y: Int, index: Int) throws {
        guard index >= 0 || index < tileCount else {
            throw GameError.indexOutOfBound(index: index)
        }
        guard let surfaceTileset = surfaceTileset else {
            throw GameError.missingTileset
        }
        try surface.draw(
            from: surfaceTileset,
            dx: x,
            dy: y,
            width: tileWidth,
            height: tileHeight,
            sx: 0,
            sy: index * tileHeight
        )
    }

    func drawClippedTile(on surface: GraphicSurface, x: Int, y: Int, index: Int, rgb: UInt32) throws {
        // FIXME: MAKE DRAW CLIPPED TILE GREAT AGAIN
        // HACK - BEGIN
        //
        // HACK - END
        // ORIGINAL - BEGIN
        //        guard let mask = clippingMasks[index] else {
        //            throw GameError.indexOutOfBound(index: index)
        //        }
        //        let resourceContext = surface.createResourceContext()
        //        resourceContext.setSourceRGB(rgb)
        //        resourceContext.maskSurface(surface: mask, xPosition: x, yPosition: y)
        //        resourceContext.fill()
        // ORIGINAL - END
    }

    func clearTile(at index: Int) throws {
        guard index >= 0 || index < tileCount else {
            throw GameError.indexOutOfBound(index: index)
        }
        guard let surfaceTileset = surfaceTileset else {
            throw GameError.missingTileset
        }
        try surfaceTileset.clear(x: 0, y: index * tileHeight, width: tileWidth, height: tileHeight)
    }

    func duplicateTile(destinationIndex: Int, tileName: String, sourceIndex: Int) throws {
        guard sourceIndex > 0, sourceIndex < tileCount else {
            throw GameError.indexOutOfBound(index: sourceIndex)
        }
        guard destinationIndex > 0, destinationIndex < tileCount else {
            throw GameError.indexOutOfBound(index: destinationIndex)
        }
        guard let surfaceTileset = surfaceTileset else {
            throw GameError.missingTileset
        }
        guard !tileName.isEmpty else {
            throw GameError.missingTileName
        }
        try clearTile(at: destinationIndex)
        try surfaceTileset.copy(
            from: surfaceTileset,
            dx: 0,
            dy: destinationIndex * tileHeight,
            width: tileWidth,
            height: tileHeight,
            sx: 0,
            sy: sourceIndex * tileHeight
        )
        tileIndex[tileNames[destinationIndex]] = nil
        tileNames[destinationIndex] = tileName
        tileIndex[tileName] = destinationIndex
    }

    func duplicateClippedTile(destinationIndex: Int, tileName: String, sourceIndex: Int, clipIndex: Int) throws {
        guard sourceIndex > 0, sourceIndex < tileCount else {
            throw GameError.indexOutOfBound(index: sourceIndex)
        }
        guard destinationIndex > 0, destinationIndex < tileCount else {
            throw GameError.indexOutOfBound(index: destinationIndex)
        }
        guard let maskSurface = clippingMasks[clipIndex] else {
            throw GameError.indexOutOfBound(index: clipIndex)
        }
        guard let surfaceTileset = surfaceTileset else {
            throw GameError.missingTileset
        }
        guard !tileName.isEmpty else {
            throw GameError.missingTileName
        }
        try clearTile(at: destinationIndex)
        try surfaceTileset.copy(
            from: surfaceTileset,
            dx: 0,
            dy: destinationIndex * tileHeight,
            maskSurface: maskSurface,
            sx: 0,
            sy: sourceIndex * tileHeight
        )
        tileIndex[tileNames[destinationIndex]] = nil
        tileNames[destinationIndex] = tileName
        tileIndex[tileName] = destinationIndex
        clippingMasks[destinationIndex] = GraphicFactory.createSurface(width: tileWidth, height: tileHeight, format: .a1)
        try clippingMasks[destinationIndex]?.copy(
            from: surfaceTileset,
            dx: 0,
            dy: 0,
            width: tileWidth,
            height: tileHeight,
            sx: 0,
            sy: destinationIndex * tileHeight
        )
    }

    func createClippingMasks() throws {
        guard let surfaceTileset = surfaceTileset else {
            throw GameError.missingTileset
        }
        for i in 0 ..< tileCount {
            clippingMasks[i] = GraphicFactory.createSurface(width: tileWidth, height: tileHeight, format: .a1)
            try clippingMasks[i]?.copy(from: surfaceTileset, dx: 0, dy: 0, width: tileWidth, height: tileHeight, sx: 0, sy: i * tileHeight)
        }
    }

    func loadTileset(from dataSource: DataSource) throws {
        let lineSource = LineDataSource(dataSource: dataSource)
        // FIXME: MAKE TILESET GREAT AGAIN
        // HACK - START
        let name = lineSource.readLine()!
        let surfaceTileset = GraphicFactory.loadPNGTilesetSurface(name: name)
        // HACK - END
        // ORIGINAL - START
        //        guard let pngPath = lineSource.readLine(), let surfaceSource = dataSource.container()?.dataSource(name: pngPath) else {
        //            throw GameError.failedToGetPath
        //        }
        //        guard let surfaceTileset = GraphicFactory.loadSurface(dataSource: surfaceSource) else {
        //            throw GameError.failedToLoadFile(path: pngPath)
        //        }
        // ORIGINAL - END
        guard let tileCountString = lineSource.readLine(), let count = Int(tileCountString) else {
            throw GameError.failedToReadTileCount
        }
        self.surfaceTileset = surfaceTileset
        self.tileCount = count
        self.tileWidth = surfaceTileset.width
        self.tileHeight = surfaceTileset.height / tileCount
        for i in 0 ..< tileCount {
            guard let tileName = lineSource.readLine() else {
                throw GameError.failedToReadTileName
            }
            tileNames.append(tileName)
            tileIndex[tileName] = i
        }
        updateGroupNames()
    }
}
