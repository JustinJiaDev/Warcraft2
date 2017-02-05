import Foundation

class GraphicRecolorMap {

    private var state: Int
    private var mapping: Dictionary<String, Int>
    private var colorNames: Array<String>
    private var colors: Array<Array<UInt32>>
    private var originalColors: Array<Array<UInt32>>

    init() {
        state = -1
        mapping = [:]
        colorNames = []
        colors = []
        originalColors = []
    }

    func groupCount() -> Int {
        return colors.count
    }

    func colorCount() -> Int {
        if colors.count > 0 {
            return colors[0].count
        }
        return 0
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

    func recolorSurface(index: Int, srcsurface: GraphicSurface) -> GraphicSurface {
        fatalError("This method is not yet implemented")
    }
}
