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
    private var mapping: [String: Int] = [:]
    private var colorNames: [String] = []
    private var colors: [[UInt32]] = [[]]
    private var originalColors: [[UInt32]] = [[]]

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
        guard let colorSurface = GraphicFactory.loadSurface(from: dataSource.containerURL.appendingPathComponent(pngPath)) else {
            throw GameError.failedToLoadFile(path: pngPath)
        }
        colors = Array(repeating: Array(repeating: 0, count: colorSurface.width), count: colorSurface.height)
        originalColors = Array(repeating: Array(repeating: 0, count: colorSurface.width), count: colorSurface.height)
        state = 0
        try colorSurface.transform(from: colorSurface, dx: 0, dy: 0, width: -1, height: -1, sx: 0, sy: 0, callData: self, callback: observePixels)
        guard let colorCountString = lineSource.readLine(), let colorCount = Int(colorCountString) else {
            throw GameError.failedToGetColorCount
        }
        guard colorCount == colors.count else {
            throw GameError.unmatchedColorCount
        }
        colorNames = Array(repeating: "", count: colorCount)
        for i in 0 ..< colorCount {
            guard let colorName = lineSource.readLine() else {
                throw GameError.failedToGetColorName(index: i)
            }
            mapping[colorName] = i
            colorNames[i] = colorName
        }
    }

    func observePixels() -> UInt32 {
        fatalError("This method is not yet implemented.")
    }

    func recolorPixels() -> UInt32 {
        fatalError("This method is not yet implemented")
    }

    func recolorSurface(at index: Int, on surface: GraphicSurface) throws -> GraphicSurface {
        guard index >= 0 && index < colors.count else {
            throw GameError.indexOutOfBound(index: index)
        }
        state = index
        guard let recoloredSurface = GraphicFactory.createSurface(width: surface.width, height: surface.height) else {
            throw GameError.cannotCreateSurface
        }
        try recoloredSurface.transform(from: surface, dx: 0, dy: 0, width: -1, height: -1, sx: 0, sy: 0, callData: self, callback: recolorPixels)
        return recoloredSurface
    }
}
