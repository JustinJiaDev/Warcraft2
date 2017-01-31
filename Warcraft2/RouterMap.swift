class RouterMap {

    struct SearchTarget {
        var x = -1
        var y = -1
        var steps = -1
        var tileType = TerrainMap.TileType.none
        var targetDistanceSquared = -1
        var inDirection = Direction.max
    }

    enum SearchStatus: Int {
        case unvisited = -1
        case visited = -2
        case occupied = -3
    }

    var map: [[SearchStatus]] = []
    var searchTargets: [SearchTarget] = []

    static var idealSearchDirection = Direction.north
    static var mapWidth = 1

    static func movingAway(_ dir1: Direction, _ dir2: Direction) -> Bool {
        if 0 > dir2.rawValue || Direction.max.rawValue <= dir2.rawValue {
            return false
        }
        let value = Direction.max.rawValue + dir2.rawValue - dir1.rawValue % Direction.max.rawValue
        if 1 >= value || Direction.max.rawValue - 1 <= value {
            return true
        }
        return false
    }

    func findRoute(resMap: AssetDecoratedMap, asset: PlayerAsset, target: Position) -> Direction {
        let mapWidth = resMap.width
        let mapHeight = resMap.height
        let startX = asset.tilePositionX()
        let startY = asset.tilePositionY()
        var tempSearch = SearchTarget()
        var currentSearch = SearchTarget()
        var bestSearch = SearchTarget()
        let tempTile = Position()
        var currentTile = Position()
        let targetTile = Position()
        var searchDirections: [Direction] = [.north, .east, .south, .west]
        let resMapXOffsets = [0, 1, 0, -1]
        let resMapYOffsets = [ -1, 0, 1, 0]
        let diagCheckXOffset = [0, 1, 1, 1, 0, -1, -1, -1]
        let diagCheckYOffset = [ -1, -1, 0, 1, 1, 1, 0, -1]
        var lastInDirection, directionBeforeLast: Direction
        var searchQueueArray: [SearchTarget] = []

        targetTile.setToTile(target)
        if map.count != mapHeight + 2 || map[0].count != mapWidth + 2 {
            let lastYIndex = mapHeight + 1
            let lastXIndex = mapWidth + 1
            map = Array(repeating: Array(repeating: .unvisited, count: mapWidth + 2), count: mapHeight + 2)
            for index in 0 ..< map.count {
                map[index][0] = .visited
                map[index][lastXIndex] = .visited
            }
            for index in 0 ..< mapWidth {
                map[0][index + 1] = .visited
                map[lastYIndex][index + 1] = .visited
            }
            RouterMap.mapWidth = mapWidth + 2
        }

        if asset.tilePosition == targetTile {
            let deltaX = target.x - asset.positionX()
            let deltaY = target.y - asset.positionY()

            if 0 < deltaX {
                if 0 < deltaY {
                    return .northWest
                } else if 0 > deltaY {
                    return .southEast
                }
                return .east
            } else if 0 > deltaX {
                if 0 < deltaY {
                    return .northWest
                } else if 0 > deltaY {
                    return .southWest
                }
                return .west
            }
            if 0 < deltaY {
                return .north
            } else if 0 > deltaY {
                return .south
            }
            return .max
        }
        for y in 0 ..< mapHeight {
            for x in 0 ..< mapWidth {
                map[y + 1][x + 1] = SearchStatus.unvisited
            }
        }

        for res in resMap.assets {
            if asset !== res {
                if AssetType.none != res.type {
                    if AssetAction.walk != res.action || asset.color != res.color {
                        if asset.color != res.color || AssetAction.conveyGold != res.action && AssetAction.conveyLumber != res.action && AssetAction.mineGold != res.action {
                            for yOff in 0 ..< res.size {
                                for xOff in 0 ..< res.size {
                                    map[res.tilePositionY() + yOff + 1][res.tilePositionX() + xOff + 1] = SearchStatus.visited
                                }
                            }
                        }
                    } else {
                        map[res.tilePositionY() + 1][res.tilePositionX() + 1] = SearchStatus(rawValue: SearchStatus.occupied.rawValue - res.direction.rawValue)!
                    }
                }
            }
        }

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
        map[startY + 1][startX + 1] = .visited
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
                let tempDirection = Direction(rawValue: SearchStatus.occupied.rawValue - map[tempTile.y + 1][tempTile.x + 1].rawValue)!
                if SearchStatus.unvisited == map[tempTile.y + 1][tempTile.x + 1] || RouterMap.movingAway(searchDirections[index], tempDirection) {
                    map[tempTile.y + 1][tempTile.x + 1] = SearchStatus(rawValue: index)!
                    let curTileType = resMap.tileTypeAt(x: tempTile.x, y: tempTile.y)
                    if TerrainMap.TileType.grass == curTileType
                        || TerrainMap.TileType.dirt == curTileType
                        || TerrainMap.TileType.stump == curTileType
                        || TerrainMap.TileType.rubble == curTileType
                        || TerrainMap.TileType.none == curTileType {
                        tempSearch.x = tempTile.x
                        tempSearch.y = tempTile.y
                        tempSearch.steps = currentSearch.steps + 1
                        tempSearch.tileType = curTileType
                        tempSearch.targetDistanceSquared = tempTile.distanceSquared(targetTile)
                        tempSearch.inDirection = searchDirections[index]
                        searchQueueArray.append(tempSearch)
                    }
                }
            }
            if searchQueueArray.isEmpty {
                break
            }
            currentSearch = searchQueueArray.first!
            searchQueueArray.remove(at: 0)
            currentTile.x = currentSearch.x
            currentTile.y = currentSearch.y
        }
        lastInDirection = bestSearch.inDirection
        directionBeforeLast = lastInDirection
        currentTile.x = bestSearch.x
        currentTile.y = bestSearch.y
        while currentTile.x != startX || currentTile.y != startY {
            let index = map[currentTile.y + 1][currentTile.x + 1].rawValue

            directionBeforeLast = lastInDirection
            lastInDirection = searchDirections[index]
            currentTile.x -= resMapXOffsets[index]
            currentTile.y -= resMapYOffsets[index]
        }
        if directionBeforeLast != lastInDirection {
            let curTileType = resMap.tileTypeAt(x: startX + diagCheckXOffset[directionBeforeLast.rawValue], y: startY + diagCheckYOffset[directionBeforeLast.rawValue])
            if curTileType == TerrainMap.TileType.grass
                || curTileType == TerrainMap.TileType.dirt
                || curTileType == TerrainMap.TileType.stump
                || curTileType == TerrainMap.TileType.rubble
                || curTileType == TerrainMap.TileType.none {
                var sum = lastInDirection.rawValue + directionBeforeLast.rawValue
                // NW wrap around
                if 6 == sum && lastInDirection == Direction.north || Direction.north == directionBeforeLast {
                    sum += 8
                }
                sum /= 2
                lastInDirection = Direction(rawValue: sum)!
            }
        }

        return lastInDirection
    }
}
