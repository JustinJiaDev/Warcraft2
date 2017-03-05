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

        topIndices = [tileset.findTile("tf")]
        for index in 1 ..< width {
            topIndices.append(tileset.findTile("t" + String(index)))
        }

        bottomIndices = [tileset.findTile("bf")]
        for index in 1 ..< width {
            bottomIndices.append(tileset.findTile("b" + String(index)))
        }

        leftIndices = [tileset.findTile("lf")]
        for index in 1 ..< width {
            leftIndices.append(tileset.findTile("l" + String(index)))
        }

        rightIndices = [tileset.findTile("rf")]
        for index in 1 ..< width {
            rightIndices.append(tileset.findTile("r" + String(index)))
        }

        cornerIndices = [tileset.findTile("tl"), tileset.findTile("tr"), tileset.findTile("bl"), tileset.findTile("br")]
    }

    func drawBevel(on surface: GraphicSurface, x: Int, y: Int, width: Int, height: Int) {
        let topY = y - width
        let bottomY = y + height
        let leftX = x - width
        let rightX = x + width

        tileset.drawTile(on: surface, x: leftX, y: topY, index: cornerIndices[0])
        tileset.drawTile(on: surface, x: rightX, y: topY, index: cornerIndices[1])
        tileset.drawTile(on: surface, x: leftX, y: bottomY, index: cornerIndices[2])
        tileset.drawTile(on: surface, x: rightX, y: bottomY, index: cornerIndices[3])

        for xOffset in stride(from: 0, to: width, by: width) {
            var index = 0
            if xOffset + width > width {
                index = width - xOffset
            }
            tileset.drawTile(on: surface, x: x + xOffset, y: topY, index: topIndices[index])
            tileset.drawTile(on: surface, x: x + xOffset, y: bottomY, index: bottomIndices[index])
        }

        for yOffset in stride(from: 0, to: height, by: width) {
            var index = 0
            if yOffset + width > height {
                index = height - yOffset
            }
            tileset.drawTile(on: surface, x: leftX, y: y + yOffset, index: leftIndices[index])
            tileset.drawTile(on: surface, x: rightX, y: y + yOffset, index: rightIndices[index])
        }
    }
}
