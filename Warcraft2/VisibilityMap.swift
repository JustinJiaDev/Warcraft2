class VisibilityMap {
    enum TileVisibility {
        case none
        case partialPartial
        case partial
        case visible
        case seenPartial
        case seen
    }

    private var map: [[TileVisibility]]
    private var maxVisibility: Int
    private var totalMapTiles: Int
    private var unseenTiles: Int

    init(width: Int, height: Int, maxVisibility: Int) {
        let rowCount = height + 2 * maxVisibility
        let columnCount = width + 2 * maxVisibility
        self.maxVisibility = maxVisibility
        self.map = Array(repeating: Array(repeating: .none, count: columnCount), count: rowCount)
        self.totalMapTiles = width * height
        self.unseenTiles = totalMapTiles
    }

    init(map: VisibilityMap) {
        self.maxVisibility = map.maxVisibility
        self.map = map.map
        self.totalMapTiles = map.totalMapTiles
        self.unseenTiles = map.unseenTiles
    }

    var width: Int {
        if map.count != 0 {
            return map[0].count - 2 * maxVisibility
        }
        return 0
    }

    var height: Int {
        return map.count - 2 * maxVisibility
    }

    func seenPercent(max: Int) -> Int {
        return (max * (totalMapTiles - unseenTiles)) / totalMapTiles
    }

    func tileTypeAt(x: Int, y: Int) -> TileVisibility {
        if (-maxVisibility > x) || (-maxVisibility > y) {
            return .none
        }
        if map.count <= y + maxVisibility {
            return .none
        }
        if map[y + maxVisibility].count <= x + maxVisibility {
            return .none
        }
        return map[y + maxVisibility][x + maxVisibility]
    }

    func update(assets: [PlayerAsset]) {
        for i in 0 ..< map.count {
            var row = map[i]
            for j in 0 ..< row.count {
                let cell = row[j]
                if cell == TileVisibility.visible || cell == TileVisibility.partial {
                    map[i][j] = TileVisibility.seen
                } else if cell == TileVisibility.partialPartial {
                    map[i][j] = TileVisibility.seenPartial
                }
            }
        }
        for asset in assets {
            let anchor = asset.tilePosition
            let sight = asset.effectiveSight + asset.size / 2
            let sightSquared = sight * sight
            anchor.x = anchor.x + asset.size / 2
            anchor.y = anchor.y + asset.size / 2
            for x in 0 ... sight {
                let xSquared = x * x
                let xSquared1 = (x != 0) ? (x - 1) * (x - 1) : 0
                for y in 0 ... sight {
                    let ySquared = y * y
                    let ySquared1 = (y != 0) ? (y - 1) * (y - 1) : 0

                    if (xSquared + ySquared) < sightSquared {
                        // Visible
                        map[anchor.y - y + maxVisibility][anchor.x - x + maxVisibility] = .visible
                        map[anchor.y - y + maxVisibility][anchor.x + x + maxVisibility] = .visible
                        map[anchor.y + y + maxVisibility][anchor.x - x + maxVisibility] = .visible
                        map[anchor.y + y + maxVisibility][anchor.x + x + maxVisibility] = .visible
                    } else if xSquared1 + ySquared1 < sightSquared {
                        // Partial
                        var curVis = map[anchor.y - y + maxVisibility][anchor.x - x + maxVisibility]
                        if TileVisibility.seen == curVis {
                            map[anchor.y - y + maxVisibility][anchor.x - x + maxVisibility] = .partial
                        } else if (TileVisibility.none == curVis) || (TileVisibility.seenPartial == curVis) {
                            map[anchor.y - y + maxVisibility][anchor.x - x + maxVisibility] = .partialPartial
                        }
                        curVis = map[anchor.y - y + maxVisibility][anchor.x + x + maxVisibility]
                        if TileVisibility.seen == curVis {
                            map[anchor.y - y + maxVisibility][anchor.x + x + maxVisibility] = .partial
                        } else if (TileVisibility.none == curVis) || (TileVisibility.seenPartial == curVis) {
                            map[anchor.y - y + maxVisibility][anchor.x + x + maxVisibility] = .partialPartial
                        }
                        curVis = map[anchor.y + y + maxVisibility][anchor.x - x + maxVisibility]
                        if TileVisibility.seen == curVis {
                            map[anchor.y + y + maxVisibility][anchor.x - x + maxVisibility] = TileVisibility.partial
                        } else if (TileVisibility.none == curVis) || (TileVisibility.seenPartial == curVis) {
                            map[anchor.y + y + maxVisibility][anchor.x - x + maxVisibility] = .partialPartial
                        }
                        curVis = map[anchor.y + y + maxVisibility][anchor.x + x + maxVisibility]
                        if TileVisibility.seen == curVis {
                            map[anchor.y + y + maxVisibility][anchor.x + x + maxVisibility] = .partial
                        } else if (TileVisibility.none == curVis) || (TileVisibility.seenPartial == curVis) {
                            map[anchor.y + y + maxVisibility][anchor.x + x + maxVisibility] = .partialPartial
                        }
                    }
                }
            }
        }
    }
}
