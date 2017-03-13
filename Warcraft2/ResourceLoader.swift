import Foundation

func url(_ pathComponents: String...) -> URL {
    return pathComponents.reduce(Bundle.main.url(forResource: "data", withExtension: nil)!, { result, pathComponent in
        return result.appendingPathComponent(pathComponent)
    })
}

func colorMap(_ name: String) throws -> GraphicRecolorMap {
    let colorMapSource = try FileDataSource(url: url("img", name.appending(".dat")))
    let colorMap = GraphicRecolorMap()
    try colorMap.load(from: colorMapSource)
    return colorMap
}

func tileset(_ name: String) throws -> GraphicTileset {
    let tilesetSource = try FileDataSource(url: url("img", name.appending(".dat")))
    let tileset = GraphicTileset()
    try tileset.loadTileset(from: tilesetSource)
    return tileset
}

func multicolorTileset(_ name: String, _ colorMap: GraphicRecolorMap) throws -> GraphicMulticolorTileset {
    let tilesetSource = try FileDataSource(url: url("img", name.appending(".dat")))
    let tileset = GraphicMulticolorTileset()
    try tileset.loadTileset(colorMap: colorMap, from: tilesetSource)
    return tileset
}
