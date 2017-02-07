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
        return ((x % Position.tileWidth) == Position.halfTileWidth)
            && ((y % Position.tileHeight) == Position.halfTileHeight)
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
        return left != right
    }

    static func setTileDimensions(width: Int, height: Int) {
        if 0 < width && 0 < height {
            tileWidth = width
            tileHeight = height
            halfTileWidth = width / 2
            halfTileHeight = height / 2

            octant = Array(repeating: Array(repeating: Direction.max, count: tileWidth), count: tileHeight)
            for y in 0 ..< tileHeight {
                for x in 0 ..< tileWidth {
                    var xDistance = x - halfTileWidth
                    var yDistance = y - halfTileHeight
                    let negativeX = xDistance < 0
                    let negativeY = yDistance > 0

                    xDistance *= xDistance
                    yDistance *= yDistance

                    if 0 == xDistance + yDistance {
                        octant[y][x] = .max
                    } else {
                        let sinSquared = Double(yDistance) / Double(xDistance + yDistance)
                        if 0.1464466094 > sinSquared {
                            // East or West
                            if negativeX {
                                octant[y][x] = .west
                            } else {
                                octant[y][x] = .east
                            }
                        } else if 0.85355339059 > sinSquared {
                            // NE, SE, SW, NW
                            if negativeY {
                                if negativeX {
                                    octant[y][x] = .southWest
                                } else {
                                    octant[y][x] = .southEast
                                }
                            } else {
                                if negativeX {
                                    octant[y][x] = .northWest
                                } else {
                                    octant[y][x] = .northEast
                                }
                            }
                        } else {
                            // North or South
                            if negativeY {
                                octant[y][x] = .south
                            } else {
                                octant[y][x] = .north
                            }
                        }
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

    func adjacentTileDirection(position: Position, objSize: Int) -> Direction {
        if 1 == objSize {
            let deltaX = position.x - x
            let deltaY = position.y - y

            if 1 < (deltaX * deltaX) || 1 < (deltaY * deltaY) {
                return Direction.max
            }

            return Position.tileDirections[deltaY + 1][deltaX + 1]
        } else {
            let thisPosition = Position()
            let targetPosition = Position()

            thisPosition.setFromTile(self)
            targetPosition.setFromTile(position)

            targetPosition.setToTile(thisPosition.closestPosition(targetPosition, objSize: objSize))
            return adjacentTileDirection(position: targetPosition, objSize: 1)
        }
    }

    func distanceSquared(_ pos: Position) -> Int {
        let deltaX = pos.x - x
        let deltaY = pos.y - y
        return deltaX * deltaX + deltaY * deltaY
    }

    func closestPosition(_ position: Position, objSize: Int) -> Position {
        let curPosition = Position(from: position)
        var bestPosition = Position()
        var bestDistance = -1
        for _ in 0 ..< objSize {
            for _ in 0 ..< objSize {
                let curDistance = curPosition.distanceSquaredFrom(position: self)
                if -1 == bestDistance || curDistance < bestDistance {
                    bestDistance = curDistance
                    bestPosition = curPosition
                }
                curPosition.x += Position.tileWidth
            }
            curPosition.x = position.x
            curPosition.y += Position.tileHeight
        }
        return bestPosition
    }

    func directionTo(_ position: Position) -> Direction {
        let delta = Position(x: position.x - x, y: position.y - y)
        let divX: Int = abs(delta.x / Position.halfTileWidth)
        let divY: Int = abs(delta.y / Position.halfTileHeight)
        let div = max(divX, divY)
        if div != 0 {
            delta.x /= div
            delta.y /= div
        }
        delta.x += Position.halfTileWidth
        delta.y += Position.halfTileHeight
        delta.x = max(delta.x, 0)
        delta.y = max(delta.y, 0)
        if Position.tileWidth <= delta.x {
            delta.x = Position.tileWidth - 1
        }
        if Position.tileHeight <= delta.y {
            delta.y = Position.tileHeight - 1
        }
        return delta.tileOctant
    }

    func distanceSquaredFrom(position: Position) -> Int {
        let deltaX = position.x - x
        let deltaY = position.y - y
        return deltaX * deltaX + deltaY * deltaY
    }

    func distance(position: Position) -> Int {
        // Not as efficient as original implementation
        return Int(sqrt(Double(self.distanceSquaredFrom(position: position))))
    }
}
