import Foundation

class Position {
    var x: Int
    var y: Int

    private(set) static var tileWidth = 1
    private(set) static var tileHeight = 1
    private(set) static var halfTileWidth = 0
    private(set) static var halfTileHeight = 0
    private static var octant = [[Direction.max]]
    private static let tileDirections: [[Direction]] = [
        [.northWest, .north, .northEast],
        [.west, .max, .east],
        [.southWest, .south, .southEast]
    ]

    var TileAligned: Bool {
        return (x % Position.tileWidth) == Position.halfTileWidth && (y % Position.tileHeight) == Position.halfTileHeight
    }

    var tileOctant: Direction {
        return Position.octant[y % Position.tileHeight][x % Position.tileWidth]
    }

    init() {
        x = 0
        y = 0
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    init(from position: Position) {
        x = position.x
        y = position.y
    }

    static func ==(left: Position, right: Position) -> Bool {
        return left.x == right.x && left.y == right.y
    }

    static func !=(left: Position, right: Position) -> Bool {
        return !(left == right)
    }

    static func setTileDimensions(width: Int, height: Int) {
        guard width > 0 && height > 0 else {
            return
        }

        tileWidth = width
        tileHeight = height
        halfTileWidth = width / 2
        halfTileHeight = height / 2

        octant = Array(repeating: Array(repeating: Direction.max, count: tileWidth), count: tileHeight)
        for y in 0 ..< tileHeight {
            for x in 0 ..< tileWidth {
                var xDistance = x - halfTileWidth
                var yDistance = y - halfTileHeight
                let isNegativeX = xDistance < 0
                let isNegativeY = yDistance > 0

                xDistance *= xDistance
                yDistance *= yDistance

                if xDistance + yDistance == 0 {
                    octant[y][x] = .max
                } else {
                    let sinSquared = Double(yDistance) / Double(xDistance + yDistance)
                    if sinSquared < 0.1464466094 {
                        octant[y][x] = isNegativeX ? .west : .east
                    } else if sinSquared < 0.85355339059 {
                        if isNegativeY {
                            octant[y][x] = isNegativeX ? .southWest : .southEast
                        } else {
                            octant[y][x] = isNegativeX ? .northWest : .northEast
                        }
                    } else {
                        octant[y][x] = isNegativeY ? .south : .north
                    }
                }
            }
        }
    }

    func setFromTile(_ position: Position) {
        x = position.x * Position.tileWidth + Position.halfTileWidth
        y = position.y * Position.tileHeight + Position.halfTileHeight
    }

    func setXFromTile(_ x: Int) {
        self.x = x * Position.tileWidth + Position.halfTileWidth
    }

    func setYFromTile(_ y: Int) {
        self.y = y * Position.tileHeight + Position.halfTileHeight
    }

    func setToTile(_ position: Position) {
        x = position.x / Position.tileWidth
        y = position.y / Position.tileHeight
    }

    func setXToTile(_ x: Int) {
        self.x = x / Position.tileWidth
    }

    func setYToTile(_ y: Int) {
        self.y = y / Position.tileHeight
    }

    func adjacentTileDirection(position: Position, objectSize: Int) -> Direction {
        if objectSize == 1 {
            let deltaX = position.x - x
            let deltaY = position.y - y
            if deltaX * deltaX > 0 || deltaY * deltaY > 1 {
                return Direction.max
            }
            return Position.tileDirections[deltaY + 1][deltaX + 1]
        } else {
            let thisPosition = Position()
            let targetPosition = Position()

            thisPosition.setFromTile(self)
            targetPosition.setFromTile(position)

            targetPosition.setToTile(thisPosition.closestPosition(targetPosition, objectSize: objectSize))
            return adjacentTileDirection(position: targetPosition, objectSize: 1)
        }
    }

    func distanceSquared(_ position: Position) -> Int {
        let deltaX = position.x - x
        let deltaY = position.y - y
        return deltaX * deltaX + deltaY * deltaY
    }

    func closestPosition(_ position: Position, objectSize: Int) -> Position {
        let currentPosition = Position(from: position)
        var bestPosition = Position()
        var bestDistance = -1
        for _ in 0 ..< objectSize {
            for _ in 0 ..< objectSize {
                let currentDistance = currentPosition.distanceSquared(from: self)
                if bestDistance == -1 || currentDistance < bestDistance {
                    bestDistance = currentDistance
                    bestPosition = Position(from: currentPosition)
                }
                currentPosition.x += Position.tileWidth
            }
            currentPosition.x = position.x
            currentPosition.y += Position.tileHeight
        }
        return bestPosition
    }

    func directionTo(_ position: Position) -> Direction {
        let delta = Position(x: position.x - x, y: position.y - y)
        let divX = abs(delta.x / Position.halfTileWidth)
        let divY = abs(delta.y / Position.halfTileHeight)
        let div = max(divX, divY)
        if div != 0 {
            delta.x /= div
            delta.y /= div
        }
        delta.x += Position.halfTileWidth
        delta.y += Position.halfTileHeight
        delta.x = max(delta.x, 0)
        delta.y = max(delta.y, 0)
        if delta.x >= Position.tileWidth {
            delta.x = Position.tileWidth - 1
        }
        if delta.y >= Position.tileHeight {
            delta.y = Position.tileHeight - 1
        }
        return delta.tileOctant
    }

    func distanceSquared(from position: Position) -> Int {
        let deltaX = position.x - x
        let deltaY = position.y - y
        return deltaX * deltaX + deltaY * deltaY
    }

    // Not as efficient as original implementation
    func distance(position: Position) -> Int {
        return Int(sqrt(Double(self.distanceSquared(from: position))))
    }
}
