import SpriteKit
import UIKit

class GraphicTileset {

    enum GameError: Error {
        case failedToGetPath
        case failedToLoadFile(path: String)
        case failedToReadTileCount
        case failedToReadTileName
    }

    private(set) var surfaceTileset: [SKTexture]!
    private(set) var imageTileset: [UIImage]!
    private(set) var originalImage: UIImage!

    private var tileIndices: [String: Int] = [:]
    private var tileNames: [Int: String] = [:]
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
        for tileName in tileNames.values {
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
            tileIndices.keys.filter { key in
                return self.tileIndices[key]! >= self.tileCount
            }.forEach { key in
                self.tileIndices.removeValue(forKey: key)
            }
            updateGroupNames()
            return tileCount
        }

        self.surfaceTileset?.append(contentsOf: Array(repeating: SKTexture(), count: count - tileCount))
        tileCount = count
        return tileCount
    }

    func findTile(_ name: String) -> Int {
        return tileIndices[name] ?? -1
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
        surface.draw(from: surfaceTileset[index], x: x, y: y, width: tileWidth, height: tileHeight)
    }

    func drawTile(on view: ViewSurface, index: Int) {
        view.draw(from: imageTileset[index])
    }

    func duplicateTile(destinationIndex: Int, tileName: String, sourceIndex: Int) {
        surfaceTileset[destinationIndex] = SKTexture(rect: CGRect(origin: .zero, size: surfaceTileset[sourceIndex].size()), in: surfaceTileset[sourceIndex])
        tileNames[destinationIndex] = tileName
        tileIndices[tileName] = destinationIndex
    }

    func duplicateClippedTile(destinationIndex: Int, tileName: String, sourceIndex: Int, clipIndex: Int) {
        let sourceTexture = surfaceTileset[sourceIndex]
        let maskTexture = surfaceTileset[clipIndex]
        let maskedImage = sourceTexture.cgImage().masking(monoColorCGImage(image: maskTexture.cgImage(), size: maskTexture.size()))!
        surfaceTileset[destinationIndex] = SKTexture(cgImage: maskedImage)
        tileIndices[tileName] = destinationIndex
        tileNames[destinationIndex] = tileName
    }

    func loadTileset(from dataSource: FileDataSource) throws {
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
        guard let images = GraphicFactory.loadImages(from: dataSource.containerURL.appendingPathComponent(pngPath), count: count) else {
            throw GameError.failedToLoadFile(path: pngPath)
        }
        guard let originalImage = GraphicFactory.loadImage(from: dataSource.containerURL.appendingPathComponent(pngPath)) else {
            throw GameError.failedToLoadFile(path: pngPath)
        }
        self.surfaceTileset = tileset
        self.imageTileset = images
        self.originalImage = originalImage
        self.tileCount = count
        self.tileWidth = Int(tileset[0].size().width)
        self.tileHeight = Int(tileset[0].size().height)
        for i in 0 ..< tileCount {
            guard let tileName = lineSource.readLine() else {
                throw GameError.failedToReadTileName
            }
            tileNames[i] = tileName
            tileIndices[tileName] = i
        }
        updateGroupNames()
    }

    private func monoColorCGImage(image: CGImage, size: CGSize) -> CGImage {
        let rect = CGRect(origin: .zero, size: size)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(
            data: nil,
            width: rect.width,
            height: rect.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue).rawValue
        )
        context!.draw(image, in: rect)
        return context!.makeImage()!
    }
}
