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

class PlayerData {
    var isAi: Bool
    private(set) var color: PlayerColor
    private(set) var visibilityMap: VisibilityMap
    private var actualMap: AssetDecoratedMap
    private(set) var playerMap: AssetDecoratedMap
    private(set) var assetTypes: [String: PlayerAssetType]
    private(set) var assets: [PlayerAsset]
    private var upgrades: [Bool]
    private(set) var gameEvents: [GameEvent]
    private(set) var gold: Int
    private(set) var lumber: Int
    private(set) var gameCycle: Int

    init(map: AssetDecoratedMap, color: PlayerColor) {
        fatalError("not yet ported")
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
    
    func decrementLumber(by lumber: Int) -> Int {
        self.lumber -= lumber
        return lumber
    }

    func foodConsumption() {
        fatalError("not yet ported")
    }

    func foodProduction() {
        fatalError("not yet ported")
    }

    func createMarker(pos: Position, addToMap: Bool) -> PlayerAsset {
        fatalError("not yet ported")
    }

    func createAsset(assetTypeName: String) -> PlayerAsset {
        fatalError("not yet ported")
    }

    func deleteAsset(asset: PlayerAsset) {
        fatalError("not yet ported")
    }

    func assetRequirementsMet(assetTypeName: String) -> Bool {
        fatalError("not yet ported")
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
