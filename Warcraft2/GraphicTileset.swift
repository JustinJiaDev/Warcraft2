import Foundation
import SpriteKit

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

    private(set) var surfaceTileset: [SKTexture]?

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

    @discardableResult func setTileCount(_ count: Int) -> Int {
        guard count > 0, tileWidth > 0, tileHeight > 0 else {
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

        self.surfaceTileset?.append(contentsOf: Array(repeating: SKTexture(), count: count - tileCount))
        tileCount = count
        return tileCount
    }

    func findTile(_ name: String) -> Int {
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
        surface.draw(from: surfaceTileset[index], x: x, y: y, width: tileWidth, height: tileHeight)
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

    func duplicateTile(destinationIndex: Int, tileName: String, sourceIndex: Int) throws {
        guard sourceIndex > 0, sourceIndex < tileCount else {
            throw GameError.indexOutOfBound(index: sourceIndex)
        }
        guard destinationIndex > 0, destinationIndex < tileCount else {
            throw GameError.indexOutOfBound(index: destinationIndex)
        }
        guard var surfaceTileset = surfaceTileset else {
            throw GameError.missingTileset
        }
        guard !tileName.isEmpty else {
            throw GameError.missingTileName
        }
        surfaceTileset[destinationIndex] = SKTexture(rect: CGRect(origin: .zero, size: CGSize(width: tileWidth, height: tileHeight)), in: surfaceTileset[sourceIndex])
        tileIndex[tileNames[destinationIndex]] = nil
        tileNames[destinationIndex] = tileName
        tileIndex[tileName] = destinationIndex
    }

    func duplicateClippedTile(destinationIndex: Int, tileName: String, sourceIndex: Int, clipIndex: Int) throws {
        // FIXME: MAKE DRAW CLIPPED TILE GREAT AGAIN
        // HACK - BEGIN
        //
        // HACK - END
        // ORIGINAL - BEGIN
        //        guard sourceIndex > 0, sourceIndex < tileCount else {
        //            throw GameError.indexOutOfBound(index: sourceIndex)
        //        }
        //        guard destinationIndex > 0, destinationIndex < tileCount else {
        //            throw GameError.indexOutOfBound(index: destinationIndex)
        //        }
        //        guard let maskSurface = clippingMasks[clipIndex] else {
        //            throw GameError.indexOutOfBound(index: clipIndex)
        //        }
        //        guard let surfaceTileset = surfaceTileset else {
        //            throw GameError.missingTileset
        //        }
        //        guard !tileName.isEmpty else {
        //            throw GameError.missingTileName
        //        }
        //        try clearTile(at: destinationIndex)
        //        try surfaceTileset.copy(
        //            from: surfaceTileset,
        //            dx: 0,
        //            dy: destinationIndex * tileHeight,
        //            maskSurface: maskSurface,
        //            sx: 0,
        //            sy: sourceIndex * tileHeight
        //        )
        //        tileIndex[tileNames[destinationIndex]] = nil
        //        tileNames[destinationIndex] = tileName
        //        tileIndex[tileName] = destinationIndex
        //        clippingMasks[destinationIndex] = GraphicFactory.createSurface(width: tileWidth, height: tileHeight, format: .a1)
        //        try clippingMasks[destinationIndex]?.copy(
        //            from: surfaceTileset,
        //            dx: 0,
        //            dy: 0,
        //            width: tileWidth,
        //            height: tileHeight,
        //            sx: 0,
        //            sy: destinationIndex * tileHeight
        //        )
        // ORIGINAL - END
    }

    func loadTileset(from dataSource: DataSource) throws {
        let lineSource = LineDataSource(dataSource: dataSource)
        guard let pngPath = lineSource.readLine() else {
            throw GameError.failedToGetPath
        }
        guard let tileCountString = lineSource.readLine(), let count = Int(tileCountString) else {
            throw GameError.failedToReadTileCount
        }
        guard let tileset = GraphicFactory.loadTextures(from: dataSource.containerURL.appendingPathComponent(pngPath), count: count) else {
            throw GameError.failedToLoadFile(path: pngPath)
        }
        self.surfaceTileset = tileset
        self.tileCount = count
        self.tileWidth = Int(tileset[0].size().width)
        self.tileHeight = Int(tileset[0].size().height)
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
