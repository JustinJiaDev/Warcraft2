import Foundation

enum GraphicTilesetError: Error {
    case failedToGetPath
    case failedToLoadFile(path: String)
    case failedToReadTileCount
    case failedToReadTileName
}

class GraphicTileset {

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

        guard let tempSurface = GraphicFactory.createSurface(width: tileWidth, height: count * tileHeight, format: surfaceTileset.format()) else {
            return tileCount
        }
        tempSurface.copy(surface: surfaceTileset, dxPosition: 0, dyPosition: 0, width: -1, height: -1, sxPosition: 0, syPosition: 0)
        self.surfaceTileset = tempSurface
        tileCount = count
        return tileCount
    }

    func findTile(with name: String) -> Int {
        return tileIndex.first { key, _ in
            return key == name
        }?.value ?? -1
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

    func drawTile(on surface: GraphicSurface, x: Int, y: Int, index: Int) {
        guard index >= 0 || index < tileCount, let surfaceTileset = surfaceTileset else {
            return
        }
        surface.draw(
            surface: surfaceTileset,
            dxPosition: x,
            dyPosition: y,
            width: tileWidth,
            height: tileHeight,
            sxPosition: 0,
            syPosition: index * tileHeight
        )
    }

    func drawClippedTile(on surface: GraphicSurface, x: Int, y: Int, index: Int, rgb: UInt32) {
        guard let mask = clippingMasks[index] else {
            return
        }
        let resourceContext = surface.createResourceContext()
        resourceContext.setSourceRGB(rgb)
        resourceContext.maskSurface(surface: mask, xPosition: x, yPosition: y)
        resourceContext.fill()
    }

    func clearTile(at index: Int) -> Bool {
        guard index >= 0 || index < tileCount, let surfaceTileset = surfaceTileset else {
            return false
        }
        surfaceTileset.clear(xPosition: 0, yPosition: index * tileHeight, width: tileWidth, height: tileHeight)
        return true
    }

    func duplicateTile(destinationIndex: Int, tileName: String, sourceIndex: Int) -> Bool {
        guard sourceIndex > 0, destinationIndex > 0, sourceIndex < tileCount, destinationIndex < tileCount, !tileName.isEmpty else {
            return false
        }
        guard let surfaceTileset = surfaceTileset, clearTile(at: destinationIndex) else {
            return false
        }
        surfaceTileset.copy(
            surface: surfaceTileset,
            dxPosition: 0,
            dyPosition: destinationIndex * tileHeight,
            width: tileWidth,
            height: tileHeight,
            sxPosition: 0,
            syPosition: sourceIndex * tileHeight
        )
        tileIndex[tileNames[destinationIndex]] = nil
        tileNames[destinationIndex] = tileName
        tileIndex[tileName] = destinationIndex
        return true
    }

    func duplicateClippedTile(destinationIndex: Int, tileName: String, sourceIndex: Int, clipIndex: Int) -> Bool {
        guard sourceIndex > 0, destinationIndex > 0, clipIndex > 0, sourceIndex < tileCount, destinationIndex < tileCount, clipIndex < clippingMasks.count, !tileName.isEmpty else {
            return false
        }
        guard let surfaceTileset = surfaceTileset, let maskSurface = clippingMasks[clipIndex], clearTile(at: destinationIndex) else {
            return false
        }
        surfaceTileset.copyMaskSurface(
            surface: surfaceTileset,
            dxPosition: 0,
            dyPosition: destinationIndex * tileHeight,
            maskSurface: maskSurface,
            sxPosition: 0,
            syPosition: sourceIndex * tileHeight
        )
        tileIndex[tileNames[destinationIndex]] = nil
        tileNames[destinationIndex] = tileName
        tileIndex[tileName] = destinationIndex
        clippingMasks[destinationIndex] = GraphicFactory.createSurface(width: tileWidth, height: tileHeight, format: .a1)
        clippingMasks[destinationIndex]?.copy(
            surface: surfaceTileset,
            dxPosition: 0,
            dyPosition: 0,
            width: tileWidth,
            height: tileHeight,
            sxPosition: 0,
            syPosition: destinationIndex * tileHeight
        )
        return true
    }

    func createClippingMasks() {
        guard let surfaceTileset = surfaceTileset else {
            return
        }
        for i in 0 ..< tileCount {
            clippingMasks[i] = GraphicFactory.createSurface(width: tileWidth, height: tileHeight, format: .a1)
            clippingMasks[i]?.copy(surface: surfaceTileset, dxPosition: 0, dyPosition: 0, width: tileWidth, height: tileHeight, sxPosition: 0, syPosition: i * tileHeight)
        }
    }

    func loadTileset(from dataSource: DataSource) throws {
        let lineSource = LineDataSource(dataSource: dataSource)
        guard let pngPath = lineSource.readLine(), let surfaceSource = dataSource.container()?.dataSource(name: pngPath) else {
            throw GraphicTilesetError.failedToGetPath
        }
        guard let surfaceTileset = GraphicFactory.loadSurface(dataSource: surfaceSource) else {
            throw GraphicTilesetError.failedToLoadFile(path: pngPath)
        }
        guard let tileCountString = lineSource.readLine(), let count = Int(tileCountString) else {
            throw GraphicTilesetError.failedToReadTileCount
        }
        tileCount = count
        tileWidth = surfaceTileset.width()
        tileHeight = surfaceTileset.height() / tileCount
        for i in 0 ..< tileCount {
            guard let tileName = lineSource.readLine() else {
                throw GraphicTilesetError.failedToReadTileName
            }
            tileNames.append(tileName)
            tileIndex[tileName] = i
        }
        updateGroupNames()
    }
}
