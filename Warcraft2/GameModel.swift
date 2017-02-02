enum EventType {
    case none
    case workComplete
    case selection
    case acknowledge
    case ready
    case death
    case attacked
    case missleFire
    case missleHit
    case harvest
    case meleeHist
    case placeAction
    case buttonTick
    case max
}

struct GameEvent {
    var type: EventType
    var asset: PlayerAsset
}

func RangeToDistanceSquared(range: Int) -> Int {
    var newRange:Int = range
    newRange *= Position.tileWidth
    newRange *= range
    newRange += Position.tileWidth * Position.tileWidth
    
    return newRange
    
}

class PlayerData {
    var isAi: Bool
    private(set) var color: PlayerColor
    private var actualMap: AssetDecoratedMap
    private(set) var visibilityMap: VisibilityMap
    private(set) var playerMap: AssetDecoratedMap
    private(set) var assetTypes: [String: PlayerAssetType]
    private(set) var assets: [PlayerAsset]
    private var upgrades: [Bool]
    private(set) var gameEvents: [GameEvent]
    private(set) var gold: Int
    private(set) var lumber: Int
    private(set) var gameCycle: Int

    init(map: AssetDecoratedMap, color: PlayerColor) {
        self.isAi = true
        self.color = color
        self.actualMap = map
        self.visibilityMap = actualMap.createVisibilityMap()
        self.playerMap = self.actualMap.createInitializeMap()
        self.assetTypes = PlayerAssetType.duplicateRegistry(color: self.color)
        self.assets = []
        self.upgrades = []
        self.gameEvents = []
        self.gold = 0
        self.lumber = 0
        self.gameCycle = 0
        
        upgrades = Array(repeating: false, count: AssetCapabilityType.max.rawValue)
        
        for resouceInit in actualMap.resourceInitializationList {
            if resouceInit.color == self.color {
                gold = resouceInit.gold
                lumber = resouceInit.lumber
            }
        }
        
        for assetInit in actualMap.assetInitializationList {
            if assetInit.color == self.color {
                printDebug("Asset Init Error")
                let initAsset:PlayerAsset = createAsset(assetTypeName: assetInit.type)
                initAsset.tilePosition = assetInit.tilePosition
                if (AssetType.goldMine == PlayerAssetType.nameToType(name: assetInit.type)) {
                    initAsset.gold = self.gold
                }
            }
        }
    }

    func incrementCycle() {
        gameCycle += 1
    }

    func isAlive() -> Bool {
        return assets.count != 0
    }

    func incrementGold(by gold: Int) -> Int {
        self.gold += gold
        return self.gold
    }

    func decrementGold(by gold: Int) -> Int {
        self.gold -= gold
        return self.gold
    }

    func incrementLumber(by lumber: Int) -> Int {
        self.lumber += lumber
        return self.lumber
    }
    
    func foodConsumption() -> Int {
        var totalConsumption:Int = 0
        
        for asset in assets {
            let assetConsumption = asset.foodConsumption
            if (assetConsumption > 0) {
                totalConsumption += assetConsumption
            }
        }
        
        return totalConsumption
    }

    func foodProduction() -> Int {
        var totalProduction:Int = 0
        for asset in assets {
            let assetConsumption:Int = foodConsumption()
            if ((assetConsumption < 0) && ((AssetAction.construct != asset.action) || (asset.currentCommand().assetTarget == nil))) {
                totalProduction += -assetConsumption
            }
        }
        
        return totalProduction
    }

    func createMarker(pos: Position, addToMap: Bool) -> PlayerAsset {
        let newMarker:PlayerAsset = assetTypes["None"].construct()
        var tilePosition = Position()
        tilePosition.setToTile(pos)
        newMarker.tilePosition = tilePosition
        if addToMap {
            playerMap.addAsset(newMarker)
        }
        
        return newMarker
    }

    func createAsset(assetTypeName: String) -> PlayerAsset {
        let createdAsset:PlayerAsset = assetTypes[assetTypeName].construct()
        
        createdAsset.creationCycle = gameCycle
        assets.append(createdAsset)
        actualMap.addAsset(createdAsset)
        return createdAsset
    }

    func deleteAsset(asset: PlayerAsset) {
        if let removalIndex = assets.index(of: asset) {
            assets.remove(at: removalIndex)
        }
        else {
            return
        }
        
        actualMap.removeAsset(asset)
    }

    func assetRequirementsMet(assetTypeName: String) -> Bool {
        var assetCount:[Int] = Array(repeating: 0, count: AssetType.max.rawValue)
        
        for asset in assets {
            if AssetAction.construct != asset.action {
                assetCount[asset.type.rawValue] += 1
            }
        }
        
        guard let reqList = assetTypes[assetTypeName]?.assetRequirements else  { assert(false) }
        
        for requirement in reqList {
            if assetCount[requirement.rawValue] == 0 {
                if (AssetType.keep == requirement) && (assetCount[AssetType.castle.rawValue] != 0) {
                    continue
                }
                if ((AssetType.townHall == requirement) && ((assetCount[AssetType.castle.rawValue] != 0) || (assetCount[AssetType.keep.rawValue] != 0))) {
                    continue
                }
                return false
            }
        }
        return true
    }

    func updateVisibility() {
        fatalError("not yet ported")
    }

    func selectAssets(selectArea: Rectangle, assetType: AssetType, selectIdentical: Bool = false) -> [PlayerAsset] {
        fatalError("not yet ported")
    }

    func selectAsset(pos: Position, assetType: AssetType) -> PlayerAsset {
        fatalError("not yet ported")
    }

    func findNearestOwnedAsset(pos: Position, assetTypes: [AssetType]) -> PlayerAsset {
        fatalError("not yet ported")
    }

    func findNearestEnemy(pos: Position, range: Int) -> PlayerAsset {
        fatalError("not yet ported")
    }

    func findBestAssetPlacement(pos: Position, builder: PlayerAsset, assetType: AssetType, buffer: Int) -> Position {
        fatalError("not yet ported")
    }

    func idleAssets() -> [PlayerAsset] {
        fatalError("not yet ported")
    }

    func playerAssetCount(type: AssetType) -> Int {
        fatalError("not yet ported")
    }

    func foundAssetCount(type: AssetType) -> Int {
        fatalError("not yet ported")
    }

    func addUpgrade(upgradeName: String) {
        fatalError("not yet ported")
    }

    func hasUpgrade(upgrade: AssetCapabilityType) -> Bool {
        fatalError("not yet ported")
    }

    func clearGameEvents() {
        gameEvents.removeAll()
    }

    func addGameEvent(event: GameEvent) {
        gameEvents.append(event)
    }

    func appendGameEvents(events: [GameEvent]) {
        fatalError("not yet ported")
    }
}

class GameModel {
    private var randomNumberGenerator: RandomNumberGenerator
    private var actualMap: AssetDecoratedMap
    private var assetOccupancyMap: [[PlayerAsset]]
    private var diagonalOccupancyMap: [[Bool]]
    private var routerMap: RouterMap
    private var players: [PlayerData]
    private var lumberAvailable: [[Int]]
    private(set) var gameCycle: Int
    private var harvestTime: Int
    private var harvestSteps: Int
    private var mineTime: Int
    private var mineSteps: Int
    private var conveyTime: Int
    private var conveySteps: Int
    private var deathTime: Int
    private var deathSteps: Int
    private var decayTime: Int
    private var decaySteps: Int
    private var lumberPerHarvest: Int
    private var goldPerMining: Int

    init(mapIndex: Int, seed: UInt64, newColors: [PlayerColor]) {
        fatalError("not yet implemented")
    }

    func validAsset(asset: PlayerAsset) -> Bool {
        fatalError("not yet implemented")
    }

    func map() -> AssetDecoratedMap {
        return actualMap
    }

    func player(color: PlayerColor) -> PlayerData {
        fatalError("not yet implemented")
    }

    func timestep() {
        fatalError("not yet implemented")
    }

    func clearGameEvents() {
        fatalError("not yet implemented")
    }
}
