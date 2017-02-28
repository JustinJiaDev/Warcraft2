import Foundation

func isDiagonal(_ left: Position, _ right: Position) -> Bool {
    return left.x != right.x && left.y != right.y
}

func squaredDistanceBetween(_ left: Position, _ right: Position) -> Int {
    let deltaX = left.x - right.x
    let deltaY = left.y - right.y
    return deltaX * deltaX + deltaY * deltaY
}

// FIXME: Not as efficient as original implementation
func distanceBetween(_ left: Position, _ right: Position) -> Int {
    return Int(sqrt(Double(squaredDistanceBetween(left, right))))
}

struct Position {
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

    static func tile(fromAbsolute position: Position) -> Position {
        let x = position.x / Position.tileWidth
        let y = position.y / Position.tileHeight
        return Position(x: x, y: y)
    }

    static func absolute(fromTile tilePosition: Position) -> Position {
        let x = tilePosition.x * Position.tileWidth + Position.halfTileWidth
        let y = tilePosition.y * Position.tileHeight + Position.halfTileHeight
        return Position(x: x, y: y)
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

    mutating func normalizeToTileCenter() {
        let tilePosition = Position.tile(fromAbsolute: self)
        self = Position.absolute(fromTile: tilePosition)
    }

    func directionToAdjacentTile(searchingFrom targetTilePosition: Position, areaLength: Int = 1) -> Direction {
        if areaLength == 1 {
            let deltaX = targetTilePosition.x - x
            let deltaY = targetTilePosition.y - y
            let isAdjacent = deltaX * deltaX <= 1 && deltaY * deltaY <= 1
            return isAdjacent ? Position.tileDirections[deltaY + 1][deltaX + 1] : Direction.max
        }
        let currentAbsolutePosition = Position.absolute(fromTile: self)
        let targetAbsolutePosition = Position.absolute(fromTile: targetTilePosition)
        let closestTargetTilePosition = Position.tile(fromAbsolute: currentAbsolutePosition.closestPosition(searchingFrom: targetAbsolutePosition, areaLength: areaLength))
        return directionToAdjacentTile(searchingFrom: closestTargetTilePosition, areaLength: 1)
    }

    func closestPosition(searchingFrom position: Position, areaLength: Int = 1) -> Position {
        var currentPosition = position
        var bestPosition = Position()
        var bestDistance = -1
        for _ in 0 ..< areaLength {
            for _ in 0 ..< areaLength {
                let currentDistance = squaredDistanceBetween(self, currentPosition)
                if bestDistance == -1 || currentDistance < bestDistance {
                    bestDistance = currentDistance
                    bestPosition = currentPosition
                }
                currentPosition.x += Position.tileWidth
            }
            currentPosition.x = position.x
            currentPosition.y += Position.tileHeight
        }
        return bestPosition
    }

    func directionTo(_ position: Position) -> Direction {
        var delta = Position(x: position.x - x, y: position.y - y)
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
}
