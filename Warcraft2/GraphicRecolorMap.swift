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

    private var state: Int = -1
    private var colorIndices: [String: Int] = [:]
    private var colorNames: [Int: String] = [:]
    private var colors: [[RGBA32]] = [[]]
    private var originalColors: [[RGBA32]] = [[]]

    var groupCount: Int {
        return colors.count
    }

    var colorCount: Int {
        return colors.first?.count ?? 0
    }

    func findColor(_ name: String) -> Int {
        // FIXME: MAKE FIND COLOR GREAT AGAIN
        // HACK - START
        return 1
        // HACK - END
    }

    func colorValue(gIndex: Int, cIndex: Int) -> UInt32 {
        // FIXME: MAKE COLOR VALUE GREAT AGAIN
        // HACK - START
        return 1
        // HACK - END
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
        //        colors = Array(repeating: Array(repeating: 0, count: Int(colorSet.size.width) / colorCount), count: colorCount)
        colors = Array(repeating: Array(repeating: RGBA32(), count: Int(colorSet.size.width / (colorSet.size.height / CGFloat(count)))), count: count)
        state = 0
        processPixels(in: colorSet.cgImage!)
        // try colorSurface.transform(from: colorSurface, dx: 0, dy: 0, width: -1, height: -1, sx: 0, sy: 0, callData: self, callback: observePixels)
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

    //    func observePixels(width: Int, height: Int) -> UInt32 {
    //        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
    //
    //        for row in 0 ..< height {
    //            for column in 0 ..< width {
    //                let offset = row * width + column
    //                if pixelBuffer[offset] == .black {
    //                    pixelBuffer[offset] = .green
    //                }
    //            }
    //        }
    //
    //
    //        let row = state / colors[0].count
    //        let column = state % colors[0].count
    //        state += 1
    //        return pixel
    //    }

    func processPixels(in image: CGImage) -> CGImage {
        let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: RGBA32.bitmapInfo
        )!
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let pixelBuffer = context.data!.bindMemory(to: RGBA32.self, capacity: image.width * image.height)
        for row in 0 ..< Int(image.height) {
            for column in 0 ..< Int(image.width) {
                let pixel = pixelBuffer[row * image.width + column]
                colors[row][column] = pixel
                // colors[row][column] = pixel | 0xff00_0000
                state += 1
            }
        }
        return context.makeImage()!
    }

    func recolorPixels(in image: CGImage) -> CGImage {
        let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: RGBA32.bitmapInfo
        )!
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let pixelBuffer = context.data!.bindMemory(to: RGBA32.self, capacity: image.width * image.height)
        for row in 0 ..< Int(image.height) {
            for column in 0 ..< Int(image.width) {
                let offset = row * image.width + column
                if let i = colors.index(where: { $0.contains(pixelBuffer[offset]) }) {
                    let j = colors[i].index(of: pixelBuffer[offset])!
                    pixelBuffer[offset] = colors[i + 1][j]
                }
            }
        }
        return context.makeImage()!
        //        let recolorMap = data as! GraphicRecolorMap
        //        var pixel = pixel
        //        let alpha = pixel & 0xff00000
        //        pixel |= 0xff00000
        //
        //        for index in 0 ..< recolorMap.colors[0].count where pixel == recolorMap.colors[0][index] {
        //            pixel = recolorMap.colors[recolorMap.state][index]
        //            break
        //        }
        //
        //        if alpha != 0 {
        //            let multiplier = alpha >> 24
        //            return ((((pixel & 0x00ff_0000) * multiplier) / 255) & 0x00ff_0000) | ((((pixel & 0x0000_ff00) * multiplier) / 255) & 0x0000_ff00) | ((((pixel & 0x0000_00ff) * multiplier) / 255) & 0x0000_00ff) | alpha
        //        }
        //        return 0x0000_0000
        // return 0
    }

    func recolorTextures(_ textures: [SKTexture], at index: Int) -> [SKTexture] {
        state = index
        return textures.map { texture in
            return SKTexture(cgImage: recolorPixels(in: texture.cgImage()))
        }
    }
}

struct RGBA32: Equatable {
    private var color: UInt32

    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }

    init() {
        color = 0
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }

    static let red = RGBA32(red: 255, green: 0, blue: 0, alpha: 255)
    static let green = RGBA32(red: 0, green: 255, blue: 0, alpha: 255)
    static let blue = RGBA32(red: 0, green: 0, blue: 255, alpha: 255)
    static let white = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
    static let magenta = RGBA32(red: 255, green: 0, blue: 255, alpha: 255)
    static let yellow = RGBA32(red: 255, green: 255, blue: 0, alpha: 255)
    static let cyan = RGBA32(red: 0, green: 255, blue: 255, alpha: 255)

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
}
