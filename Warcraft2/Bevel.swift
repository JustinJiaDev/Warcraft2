class Bevel {
    private(set) var tileset: GraphicTileset
    private(set) var topIndices: [Int]
    private(set) var bottomIndices: [Int]
    private(set) var leftIndices: [Int]
    private(set) var rightIndices: [Int]
    private(set) var cornerIndices: [Int]
    private(set) var width: Int

    init(tileset: GraphicTileset) {
        self.tileset = tileset
        self.width = tileset.tileWidth

        topIndices = [tileset.findTile(with: "tf")]
        for index in 1 ..< width {
            topIndices.append(tileset.findTile(with: "t" + String(index)))
        }

        bottomIndices = [tileset.findTile(with: "bf")]
        for index in 1 ..< width {
            bottomIndices.append(tileset.findTile(with: "b" + String(index)))
        }

        leftIndices = [tileset.findTile(with: "lf")]
        for index in 1 ..< width {
            leftIndices.append(tileset.findTile(with: "l" + String(index)))
        }

        rightIndices = [tileset.findTile(with: "rf")]
        for index in 1 ..< width {
            rightIndices.append(tileset.findTile(with: "r" + String(index)))
        }

        cornerIndices = [tileset.findTile(with: "tl"), tileset.findTile(with: "tr"), tileset.findTile(with: "bl"), tileset.findTile(with: "br")]
    }

    func drawBevel(on surface: GraphicSurface, x: Int, y: Int, width: Int, height: Int) throws {
        let topY = y - width
        let bottomY = y + height
        let leftX = x - width
        let rightX = x + width

        try tileset.drawTile(on: surface, x: leftX, y: topY, index: cornerIndices[0])
        try tileset.drawTile(on: surface, x: rightX, y: topY, index: cornerIndices[1])
        try tileset.drawTile(on: surface, x: leftX, y: bottomY, index: cornerIndices[2])
        try tileset.drawTile(on: surface, x: rightX, y: bottomY, index: cornerIndices[3])

        for xOffset in stride(from: 0, to: width, by: width) {
            var index = 0
            if xOffset + width > width {
                index = width - xOffset
            }
            try tileset.drawTile(on: surface, x: x + xOffset, y: topY, index: topIndices[index])
            try tileset.drawTile(on: surface, x: x + xOffset, y: bottomY, index: bottomIndices[index])
        }

        for yOffset in stride(from: 0, to: height, by: width) {
            var index = 0
            if yOffset + width > height {
                index = height - yOffset
            }
            try tileset.drawTile(on: surface, x: leftX, y: y + yOffset, index: leftIndices[index])
            try tileset.drawTile(on: surface, x: rightX, y: y + yOffset, index: rightIndices[index])
        }
    }
}
