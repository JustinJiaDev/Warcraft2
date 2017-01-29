class Bevel {
    private(set) var tileSet: GraphicTileset
    private(set) var topIndices: [Int] = []
    private(set) var bottomIndices: [Int] = []
    private(set) var leftIndices: [Int] = []
    private(set) var rightIndices: [Int] = []
    private(set) var cornerIndices: [Int] = []
    private(set) var dWidth: Int
    
    var width: Int {
        return dWidth
    }
    
    init(tileset: GraphicTileset) {
        tileSet = tileset
        dWidth = tileset.tileWidth
        topIndices[0] = tileSet.findTile(with: "tf")
        for index in 1..<dWidth {
            topIndices[index] = tileSet.findTile(with: "t" + String(index))
        }
        
        bottomIndices[0] = tileSet.findTile(with: "bf")
        for index in 1..<dWidth {
            bottomIndices[index] = tileSet.findTile(with: "b" + String(index))
        }
        
        leftIndices[0] = tileSet.findTile(with: "lf")
        for index in 1..<dWidth {
            leftIndices[index] = tileSet.findTile(with: "l" + String(index))
        }
        
        rightIndices[0] = tileSet.findTile(with: "rf")
        for index in 1..<dWidth {
            rightIndices[index] = tileSet.findTile(with: "r" + String(index))
        }
        
        cornerIndices[0] = tileSet.findTile(with: "tl");
        cornerIndices[1] = tileSet.findTile(with: "tr");
        cornerIndices[2] = tileSet.findTile(with: "bl");
        cornerIndices[3] = tileSet.findTile(with: "br");
    }
    
    func drawBevel(surface: GraphicSurface, xpos: Int , ypos: Int , width: Int , height: Int) throws {
        let topY = ypos - dWidth;
        let bottomY = ypos + height;
        let leftX = xpos - dWidth;
        let rightX = xpos + width;
        
        try tileSet.drawTile(on: surface, x: leftX, y: topY, index: cornerIndices[0])
        try tileSet.drawTile(on: surface, x: rightX, y: topY, index: cornerIndices[1])
        try tileSet.drawTile(on: surface, x: leftX, y: bottomY, index: cornerIndices[2])
        try tileSet.drawTile(on: surface, x: rightX, y: bottomY, index: cornerIndices[3])
        
        for xOff in stride(from: 0, to: width, by: dWidth) {
            var index = 0
            if xOff + dWidth > width {
                index = width - xOff
            }
            try tileSet.drawTile(on: surface, x: xpos + xOff, y: topY, index: topIndices[index])
            try tileSet.drawTile(on: surface, x: xpos + xOff, y: bottomY, index: bottomIndices[index])
        }
        
        for yOff in stride(from: 0, to: height, by: dWidth) {
            var index = 0
            if yOff + dWidth > height {
                index = height - yOff
            }
            try tileSet.drawTile(on: surface, x: leftX, y: ypos + yOff, index: leftIndices[index])
            try tileSet.drawTile(on: surface, x: rightX, y: ypos + yOff, index: rightIndices[index])
        }
    }
}
