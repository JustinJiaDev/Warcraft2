class RouterMap {

    struct SearchTarget {
        var x = -1
        var y = -1
        var steps = -1
        var tileType = TerrainMap.TileType.none
        var targetDistanceSquared = -1
        var inDirection = Direction.max
    }

    let searchStatusUnvisited = -1
    let searchStatusVisited = -2
    let searchStatusOccupied = -3

    var map: [[Int]] = []
    var searchTargets: [SearchTarget] = []

    static var idealSearchDirection = Direction.north
    static var mapWidth = 1

    static func movingAway(_ first: Direction, _ second: Direction) -> Bool {
        let angleInBetween = abs(first.angle - second.angle)
        let normalizedAngle = min(angleInBetween, 360 - angleInBetween)
        return normalizedAngle <= 45
    }

    func findRoute(assetMap: AssetDecoratedMap, asset: PlayerAsset, target targetPosition: Position) -> Direction {
        let mapWidth = assetMap.width
        let mapHeight = assetMap.height
        let startX = asset.tilePositionX
        let startY = asset.tilePositionY
        var tempSearch = SearchTarget()
        var currentSearch = SearchTarget()
        var bestSearch = SearchTarget()
        var tempTile = Position()
        var currentTile = Position()
        let targetTile = Position.tile(fromAbsolute: targetPosition)
        let searchDirections: [Direction] = [.north, .east, .south, .west]
        let resMapXOffsets = [0, 1, 0, -1]
        let resMapYOffsets = [ -1, 0, 1, 0]
        let diagCheckXOffset = [0, 1, 1, 1, 0, -1, -1, -1]
        let diagCheckYOffset = [ -1, -1, 0, 1, 1, 1, 0, -1]
        var lastInDirection, directionBeforeLast: Direction
        var searchQueueArray: [SearchTarget] = []

        if map.count != mapHeight + 2 || map[0].count != mapWidth + 2 {
            let lastYIndex = mapHeight + 1
            let lastXIndex = mapWidth + 1
            map = Array(repeating: Array(repeating: searchStatusUnvisited, count: mapWidth + 2), count: mapHeight + 2)
            // Set first and last column to visited
            for index in 0 ..< map.count {
                map[index][0] = searchStatusVisited
                map[index][lastXIndex] = searchStatusVisited
            }
            // Set remaining border to visited (note that the corners were
            // already set to visited by the previous for loop)
            for index in 0 ..< mapWidth {
                map[0][index + 1] = searchStatusVisited
                map[lastYIndex][index + 1] = searchStatusVisited
            }
            RouterMap.mapWidth = mapWidth + 2
        }

        if asset.tilePosition == targetTile {
            let deltaX = targetPosition.x - asset.positionX
            let deltaY = targetPosition.y - asset.positionY

            if deltaX > 0 {
                if deltaY > 0 {
                    return .northWest
                } else if deltaY < 0 {
                    return .southEast
                }
                return .east
            } else if deltaX < 0 {
                if deltaY > 0 {
                    return .northWest
                } else if deltaY < 0 {
                    return .southWest
                }
                return .west
            }
            if deltaY > 0 {
                return .north
            } else if deltaY < 0 {
                return .south
            }
            return .max
        }
        // Set all non-border nodes to unvisited
        for y in 0 ..< mapHeight {
            for x in 0 ..< mapWidth {
                map[y + 1][x + 1] = searchStatusUnvisited
            }
        }

        for item in assetMap.assets {
            if asset !== item && item.type != .none {
                if item.action != .walk || asset.color != item.color {
                    if asset.color != item.color || (item.action != .conveyGold && item.action != .conveyLumber && item.action != .mineGold) {
                        for y in 0 ..< item.size {
                            for x in 0 ..< item.size {
                                map[item.tilePositionY + y + 1][item.tilePositionX + x + 1] = searchStatusVisited
                            }
                        }
                    }
                } else {
                    map[item.tilePositionY + 1][item.tilePositionX + 1] = searchStatusOccupied - item.direction.index
                }
            }
        }

        RouterMap.idealSearchDirection = asset.direction
        currentTile = asset.tilePosition
        bestSearch.x = currentTile.x
        bestSearch.y = currentTile.y
        currentSearch.x = bestSearch.x
        currentSearch.y = bestSearch.y
        currentSearch.steps = 0
        bestSearch.targetDistanceSquared = currentTile.distanceSquared(targetTile)
        currentSearch.targetDistanceSquared = bestSearch.targetDistanceSquared
        bestSearch.inDirection = .max
        currentSearch.inDirection = bestSearch.inDirection
        map[startY + 1][startX + 1] = searchStatusVisited
        while true {
            if currentTile == targetTile {
                bestSearch = currentSearch
                break
            }
            if currentSearch.targetDistanceSquared < bestSearch.targetDistanceSquared {
                bestSearch = currentSearch
            }
            for index in 0 ..< searchDirections.count {
                tempTile.x = currentSearch.x + resMapXOffsets[index]
                tempTile.y = currentSearch.y + resMapYOffsets[index]
                let tempDirectionIndex = searchStatusOccupied - map[tempTile.y + 1][tempTile.x + 1]
                if searchStatusUnvisited == map[tempTile.y + 1][tempTile.x + 1] || tempDirectionIndex >= 0 && RouterMap.movingAway(searchDirections[index], Direction(index: tempDirectionIndex)!) {
                    map[tempTile.y + 1][tempTile.x + 1] = index
                    let currentTileType = assetMap.tileTypeAt(x: tempTile.x, y: tempTile.y)
                    if [.grass, .dirt, .stump, .rubble, .none].contains(currentTileType) {
                        tempSearch.x = tempTile.x
                        tempSearch.y = tempTile.y
                        tempSearch.steps = currentSearch.steps + 1
                        tempSearch.tileType = currentTileType
                        tempSearch.targetDistanceSquared = tempTile.distanceSquared(targetTile)
                        tempSearch.inDirection = searchDirections[index]
                        searchQueueArray.append(tempSearch)
                    }
                }
            }
            if searchQueueArray.isEmpty {
                break
            }
            currentSearch = searchQueueArray[0]
            searchQueueArray.remove(at: 0)
            currentTile.x = currentSearch.x
            currentTile.y = currentSearch.y
        }
        lastInDirection = bestSearch.inDirection
        directionBeforeLast = lastInDirection
        currentTile.x = bestSearch.x
        currentTile.y = bestSearch.y
        while currentTile.x != startX || currentTile.y != startY {
            let index = map[currentTile.y + 1][currentTile.x + 1]
            directionBeforeLast = lastInDirection
            lastInDirection = searchDirections[index]
            currentTile.x -= resMapXOffsets[index]
            currentTile.y -= resMapYOffsets[index]
        }
        if directionBeforeLast != lastInDirection {
            let currentTileType = assetMap.tileTypeAt(x: startX + diagCheckXOffset[directionBeforeLast.index], y: startY + diagCheckYOffset[directionBeforeLast.index])
            if [.grass, .dirt, .stump, .rubble, .none].contains(currentTileType) {
                var sum = lastInDirection.index + directionBeforeLast.index
                // NW wrap around
                if sum == 6 && lastInDirection == .north || directionBeforeLast == .north {
                    sum += 8
                }
                sum /= 2
                lastInDirection = Direction(index: sum)!
            }
        }

        return lastInDirection
    }
}
