class GraphicRecolorMap {

    private var state: Int
    private var mapping: [String: Int] = [:]
    private var colorNames: [String] = []
    private var colors: [[UInt32]] = [[]]
    private var originalColors: [[UInt32]] = [[]]

    init() {
        fatalError("This method is not yet implemented.")
    }

    var groupCount: Int {
        return colors.count
    }

    var colorCount: Int {
        return (colors.count != 0) ? colors[0].count : 0
    }

    func findColor(colorname: String) -> Int {
        fatalError("This method is not yet implemented.")
    }

    func colorValue(gindex: Int, cindex: Int) -> UInt32 {
        fatalError("This method is not yet implemented.")
    }

    func load(source: DataSource) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    func observePixels() -> UInt32 {
        fatalError("This method is not yet implemented.")
    }

    func recolorPixels() -> UInt32 {
        fatalError("This method is not yet implemented")
    }

    func recolorSurface(index: Int, on surface: GraphicSurface) -> GraphicSurface {
        fatalError("This method is not yet implemented")
    }
}
