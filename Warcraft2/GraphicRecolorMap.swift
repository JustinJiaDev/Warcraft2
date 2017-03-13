import SpriteKit

class GraphicRecolorMap {

    enum GameError: Error {
        case failedToGetPath
        case failedToGetColorCount
        case failedToGetColorName(index: Int)
        case unmatchedColorCount
        case cannotCreateSurface
        case failedToLoadFile(path: String)
        case indexOutOfBound(index: Int)
    }

    private var firstColorSetColumns: [UInt32: Int] = [:]
    private var colorIndices: [String: Int] = [:]
    private var colorNames: [Int: String] = [:]
    private var colors: [[UInt32]] = [[]]

    var groupCount: Int {
        return colors.count
    }

    var colorCount: Int {
        return colors.first?.count ?? 0
    }

    func findColor(_ name: String) -> Int {
        return colorIndices[name] ?? -1
    }

    func colorValue(gIndex: Int, cIndex: Int) -> UInt32 {
        return colors[gIndex][cIndex]
    }

    func load(from dataSource: FileDataSource) throws {
        let lineSource = LineDataSource(dataSource: dataSource)
        guard let pngPath = lineSource.readLine() else {
            throw GameError.failedToGetPath
        }
        guard let colorCountString = lineSource.readLine(), let count = Int(colorCountString) else {
            throw GameError.failedToGetColorCount
        }
        guard let colorSet = GraphicFactory.loadImage(from: dataSource.containerURL.appendingPathComponent(pngPath)) else {
            throw GameError.failedToLoadFile(path: pngPath)
        }
        colors = Array(repeating: Array(repeating: 0, count: Int(colorSet.size.width / (colorSet.size.height / CGFloat(count)))), count: count)
        firstColorSetColumns = [:]
        processPixels(in: colorSet.cgImage!)
        colorIndices = [:]
        colorNames = [:]
        for i in 0 ..< count {
            guard let colorName = lineSource.readLine() else {
                throw GameError.failedToGetColorName(index: i)
            }
            colorIndices[colorName] = i
            colorNames[i] = colorName
        }
    }

    func processPixels(in image: CGImage) {
        let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        )!
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let pixelBuffer = context.data!.bindMemory(to: UInt32.self, capacity: image.width * image.height)
        for row in 0 ..< Int(image.height) {
            for column in 0 ..< Int(image.width) {
                colors[row][column] = pixelBuffer[row * image.width + column]
            }
        }
        for column in 0 ..< Int(image.width) {
            firstColorSetColumns[colors[0][column]] = column
        }
    }

    func recolorPixels(in image: CGImage, index: Int) -> CGImage {
        let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        )!
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let pixelBuffer = context.data!.bindMemory(to: UInt32.self, capacity: image.width * image.height)
        for row in 0 ..< Int(image.height) {
            for column in 0 ..< Int(image.width) {
                let offset = row * image.width + column
                if let j = firstColorSetColumns[pixelBuffer[offset]] {
                    pixelBuffer[offset] = colors[index][j]
                }
            }
        }
        return context.makeImage()!
    }
}
