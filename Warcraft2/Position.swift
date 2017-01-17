//
//  Position.swift
//  Warcraft2
//
//  Created by Bryce Korte on 1/16/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class CPosition {
    // Originally protected, may need to be public
    var dx: Int
    var dy: Int
    private static var dTileWidth = 1
    private static var dTileHeight = 1
    private static var dHalfTileWidth = 0
    private static var dHalfTileHeight = 0
    private static var dOctant = [[EDirection.dMax]]
    private static let dTileDirections: [[EDirection]] = [
        [.dNorthWest, .dNorth, .dNorthEast],
        [.dWest, .dMax, .dEast],
        [.dSouthWest, .dSouth, .dSouthEast],
    ]

    init() {
        dx = 0
        dy = 0
    }

    init(x: Int, y: Int) {
        dx = x
        dy = y
    }

    init(from pos: CPosition) {
        dx = pos.dx
        dy = pos.dy
    }

    static func == (left: CPosition, right: CPosition) -> Bool {
        return left.dx == right.dx && left.dy == right.dy
    }

    static func != (left: CPosition, right: CPosition) -> Bool {
        return !(left == right)
    }

    static func setTileDimensions(width: Int, height: Int) {
        if 0 < width && 0 < height {
            dTileWidth = width
            dTileHeight = height
            dHalfTileWidth = width / 2
            dHalfTileHeight = height / 2

            dOctant = Array(repeating: Array(repeating: EDirection.dMax, count: dTileWidth), count: dTileHeight)
            for y in 0 ..< dTileHeight {
                for x in 0 ..< dTileWidth {
                    var xDistance = x - dHalfTileWidth
                    var yDistance = y - dHalfTileHeight
                    let negativeX = xDistance < 0
                    let negativeY = yDistance > 0

                    xDistance *= xDistance
                    yDistance *= yDistance

                    if 0 == xDistance + yDistance {
                        dOctant[y][x] = .dMax
                    } else {
                        let sinSquared = Double(yDistance) / Double(xDistance + yDistance)
                        if 0.1464466094 > sinSquared {
                            // East or West
                            if negativeX {
                                dOctant[y][x] = .dWest
                            } else {
                                dOctant[y][x] = .dEast
                            }
                        } else if 0.85355339059 > sinSquared {
                            // NE, SE, SW, NW
                            if negativeY {
                                if negativeX {
                                    dOctant[y][x] = .dSouthWest
                                } else {
                                    dOctant[y][x] = .dSouthEast
                                }
                            } else {
                                if negativeX {
                                    dOctant[y][x] = .dNorthWest
                                } else {
                                    dOctant[y][x] = .dNorthEast
                                }
                            }
                        } else {
                            // North or South
                            if negativeY {
                                dOctant[y][x] = .dSouth
                            } else {
                                dOctant[y][x] = .dNorth
                            }
                        }
                    }
                }
            }
        }
    }

    static func tileWidth() -> Int {
        return CPosition.dTileWidth
    }

    static func tileHeight() -> Int {
        return CPosition.dTileWidth
    }

    static func halfTileWidth() -> Int {
        return dHalfTileWidth
    }

    static func halfTileHeight() -> Int {
        return dHalfTileHeight
    }

    func setFromTile(_ pos: CPosition) {
        dx = pos.dx * CPosition.dTileWidth + CPosition.dHalfTileWidth
        dy = pos.dy * CPosition.dTileHeight + CPosition.dHalfTileHeight
    }

    func setXFromTile(_ x: Int) {
        dx = x * CPosition.dTileWidth + CPosition.dHalfTileWidth
    }

    func setYFromTile(_ y: Int) {
        dy = y * CPosition.dTileHeight + CPosition.dHalfTileHeight
    }

    func setToTile(_ pos: CPosition) {
        dx = pos.dx / CPosition.dTileWidth
        dy = pos.dy / CPosition.dTileHeight
    }

    func setXToTile(_ x: Int) {
        dx = x / CPosition.dTileWidth
    }

    func setYToTile(_ y: Int) {
        dy = y / CPosition.dTileHeight
    }

    func tileOctant() -> EDirection {
        return CPosition.dOctant[dy % CPosition.dTileHeight][dx % CPosition.dTileWidth]
    }

    func adjacentTileDirection(pos: CPosition, objSize: Int) -> EDirection {
        if 1 == objSize {
            let deltaX = pos.dx - dx
            let deltaY = pos.dy - dy

            if 1 < (deltaX * deltaX) || 1 < (deltaY * deltaY) {
                return EDirection.dMax
            }

            return CPosition.dTileDirections[deltaY + 1][deltaX + 1]
        } else {
            let thisPosition = CPosition()
            let targetPosition = CPosition()

            thisPosition.setFromTile(self)
            targetPosition.setFromTile(pos)

            targetPosition.setToTile(thisPosition.closestPosition(targetPosition, objSize: objSize))
            return adjacentTileDirection(pos: targetPosition, objSize: 1)
        }
    }

    func closestPosition(_ pos: CPosition, objSize: Int) -> CPosition {
        let curPosition = CPosition(from: pos)
        var bestPosition = CPosition()
        var bestDistance = -1
        for _ in 0 ..< objSize {
            for _ in 0 ..< objSize {
                let curDistance = curPosition.distanceSquaredFrom(pos: self)
                if -1 == bestDistance || curDistance < bestDistance {
                    bestDistance = curDistance
                    bestPosition = curPosition
                }
                curPosition.dx += CPosition.dTileWidth
            }
            curPosition.dx = pos.dx
            curPosition.dy += CPosition.dTileHeight
        }
        return bestPosition
    }

    func directionTo(_ pos: CPosition) -> EDirection {
        let delta = CPosition(x: pos.dx - dx, y: pos.dy - dy)
        let divX: Int = abs(delta.dx / CPosition.halfTileWidth())
        let divY: Int = abs(delta.dy / CPosition.halfTileHeight())
        let div = max(divX, divY)
        if div != 0 {
            delta.dx /= div
            delta.dy /= div
        }
        delta.dx += CPosition.halfTileWidth()
        delta.dy += CPosition.halfTileHeight()
        delta.dx = max(delta.dx, 0)
        delta.dy = max(delta.dy, 0)
        if CPosition.tileWidth() <= delta.dx {
            delta.dx = CPosition.tileWidth() - 1
        }
        if CPosition.tileHeight() <= delta.dy {
            delta.dy = CPosition.tileHeight() - 1
        }
        return delta.tileOctant()
    }

    func distanceSquaredFrom(pos: CPosition) -> Int {
        let deltaX = pos.dx - dx
        let deltaY = pos.dy - dy
        return deltaX * deltaX + deltaY * deltaY
    }

    func distance(pos: CPosition) -> Int {
        // Not as efficient as original implementation
        return Int(sqrt(Double(self.distanceSquaredFrom(pos: pos))))
    }
}
