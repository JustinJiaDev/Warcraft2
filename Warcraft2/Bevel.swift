class Bevel {
    private(set) var tileSet: GraphicTileset
    private(set) var topIndices: [Int] = []
    private(set) var bottomIndices: [Int] = []
    private(set) var leftIndices: [Int] = []
    private(set) var rightIndices: [Int] = []
    private(set) var cornerIndices: [Int] = []
    private(set) var width: Int

    init(tileset: GraphicTileset) {
        tileSet = tileset
        width = tileset.tileWidth
        topIndices[0] = tileSet.findTile(with: "tf")
        for index in 1 ..< width {
            topIndices[index] = tileSet.findTile(with: "t" + String(index))
        }

        bottomIndices[0] = tileSet.findTile(with: "bf")
        for index in 1 ..< width {
            bottomIndices[index] = tileSet.findTile(with: "b" + String(index))
        }

        leftIndices[0] = tileSet.findTile(with: "lf")
        for index in 1 ..< width {
            leftIndices[index] = tileSet.findTile(with: "l" + String(index))
        }

        rightIndices[0] = tileSet.findTile(with: "rf")
        for index in 1 ..< width {
            rightIndices[index] = tileSet.findTile(with: "r" + String(index))
        }

        cornerIndices[0] = tileSet.findTile(with: "tl")
        cornerIndices[1] = tileSet.findTile(with: "tr")
        cornerIndices[2] = tileSet.findTile(with: "bl")
        cornerIndices[3] = tileSet.findTile(with: "br")
    }

    func drawBevel(surface: GraphicSurface, xpos: Int, ypos: Int, width: Int, height: Int) throws {
        let topY = ypos - width
        let bottomY = ypos + height
        let leftX = xpos - width
        let rightX = xpos + width

        try tileSet.drawTile(on: surface, x: leftX, y: topY, index: cornerIndices[0])
        try tileSet.drawTile(on: surface, x: rightX, y: topY, index: cornerIndices[1])
        try tileSet.drawTile(on: surface, x: leftX, y: bottomY, index: cornerIndices[2])
        try tileSet.drawTile(on: surface, x: rightX, y: bottomY, index: cornerIndices[3])

        for xOffset in stride(from: 0, to: width, by: width) {
            var index = 0
            if xOffset + width > width {
                index = width - xOffset
            }
            try tileSet.drawTile(on: surface, x: xpos + xOffset, y: topY, index: topIndices[index])
            try tileSet.drawTile(on: surface, x: xpos + xOffset, y: bottomY, index: bottomIndices[index])
        }

        for yOffset in stride(from: 0, to: height, by: width) {
            var index = 0
            if yOffset + width > height {
                index = height - yOffset
            }
            try tileSet.drawTile(on: surface, x: leftX, y: ypos + yOffset, index: leftIndices[index])
            try tileSet.drawTile(on: surface, x: rightX, y: ypos + yOffset, index: rightIndices[index])
        }
    }
}
