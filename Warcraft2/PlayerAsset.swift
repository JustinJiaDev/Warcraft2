import Foundation

class ActivatedPlayerCapability {
    private var actor: PlayerAsset
    private var playerData: PlayerData
    private var target: PlayerAsset

    init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) {
        fatalError("This method is not yet implemented.")
    }

    func percentComplete(max _: Int) {
        fatalError("This method is not yet implemented.")
    }

    func incrementstep() {
        fatalError("This method is not yet implemented.")
    }

    func cancel() {
        fatalError("This method is not yet implemented.")
    }
}

class PlayerCapability {

    enum TargetType {
        case none, asset, terrain, terrainOrAsset, player
    }

    private(set) var name: String
    private(set) var assetCapabilityType: AssetCapabilityType
    private(set) var targetType: TargetType

    init(name: String, targetType: TargetType) {
        fatalError("This method is not yet implemented.")
    }

    private static func nameRegistry() -> [String: PlayerCapability] {
        fatalError("This method is not yet implemented.")
    }

    private static func typeRegistry() -> [Int: PlayerCapability] {
        fatalError("This method is not yet implemented.")
    }

    private static func register(capability: PlayerCapability) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    static func findCapability(type: AssetCapabilityType) -> PlayerCapability {
        fatalError("This method is not yet implemented.")
    }

    static func findCapability(name: String) -> PlayerCapability {
        fatalError("This method is not yet implemented.")
    }

    static func nameToType(name: String) -> AssetCapabilityType {
        fatalError("This method is not yet implemented.")
    }

    static func typeToName(type: AssetCapabilityType) -> String {
        fatalError("This method is not yet implemented.")
    }

    func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        fatalError("This method is not yet implemented.")
    }
}

class PlayerUpgrade {

    private(set) var name: String
    private(set) var armor: Int
    private(set) var sight: Int
    private(set) var speed: Int
    private(set) var basicDamage: Int
    private(set) var piercingDamage: Int
    private(set) var range: Int
    private(set) var goldCost: Int
    private(set) var lumberCost: Int
    private(set) var researchTime: Int
    private(set) var affectedAssets: [AssetType]
    static var registryByName: [String: PlayerUpgrade] = [:]
    static var registryByType: [Int: PlayerUpgrade] = [:]

    init() {
        fatalError("This method is not yet implemented.")
    }

    static func loadUpgrades(container: DataContainer) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    static func load(source: DataSource) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    static func findUpgrade(type: AssetCapabilityType) -> PlayerUpgrade {
        fatalError("This method is not yet implemented.")
    }

    static func findUpgrade(name: String) -> PlayerUpgrade {
        fatalError("This method is not yet implemented.")
    }
}

class PlayerAssetType {
    private(set) weak var this: PlayerAssetType?
    private(set) var name: String
    private(set) var type: AssetType
    private(set) var color: PlayerColor
    private(set) var capabilities: [AssetCapabilityType: Bool]
    private(set) var assetRequirements: [AssetType]
    private(set) var assetUpgrades: [PlayerUpgrade]
    private(set) var hitPoints: Int
    private(set) var armor: Int
    private(set) var sight: Int
    private(set) var constructionSight: Int
    private(set) var size: Int
    private(set) var speed: Int
    private(set) var goldCost: Int
    private(set) var lumberCost: Int
    private(set) var foodConsumption: Int
    private(set) var buildTime: Int
    private(set) var attackSteps: Int
    private(set) var reloadSteps: Int
    private(set) var basicDamage: Int
    private(set) var piercingDamage: Int
    private(set) var range: Int

    private(set) static var registry: [String: PlayerAssetType] = [:]
    private(set) static var typeStrings: [String] = []
    private(set) static var nameTypeTranslation: [String: AssetType] = [:]

    init(playerAssetType: PlayerAssetType) {
        fatalError("This method is not yet implemented.")
    }

    func armorUpgrade() -> Int {
        fatalError("This method is not yet implemented.")
    }

    func sightUpgrade() -> Int {
        fatalError("This method is not yet implemented.")
    }

    func speedUpgrade() -> Int {
        fatalError("This method is not yet implemented.")
    }

    func basicDamageUpgrade() -> Int {
        fatalError("This method is not yet implemented.")
    }

    func piercingDamageUpgrade() -> Int {
        fatalError("This method is not yet implemented.")
    }

    func rangeUpgrade() -> Int {
        fatalError("This method is not yet implemented.")
    }

    func hasCapability(_ capability: AssetCapabilityType) -> Bool {
        return capabilities[capability] ?? false
    }

    func addCapability(_ capability: AssetCapabilityType) {
        capabilities[capability] = true
    }

    func removeCapability(_ capability: AssetCapabilityType) {
        capabilities[capability] = false
    }

    func addUpgrade(upgrade: PlayerUpgrade) {
        assetUpgrades.append(upgrade)
    }

    static func nameToType(name: String) -> AssetType {
        fatalError("This method is not yet implemented.")
    }

    static func typeToName(type: AssetType) -> String {
        fatalError("This method is not yet implemented.")
    }

    static func maxSight() -> Int {
        fatalError("This method is not yet implemented.")
    }

    static func loadTypes(container: DataContainer) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    static func load(source: DataSource) -> Bool {
        fatalError("This method is not yet implemented.")
    }

    static func findDefault(from name: String) -> PlayerAssetType {
        fatalError("This method is not yet implemented.")
    }

    static func findDefault(from type: AssetType) -> PlayerAssetType {
        fatalError("This method is not yet implemented.")
    }

    static func duplicateRegistry(color: PlayerColor) -> [String: PlayerAssetType] {
        fatalError("This method is not yet implemented.")
    }

    static func construct() -> PlayerAsset {
        fatalError("This method is not yet implemented.")
    }
}

struct AssetCommand {
    var action: AssetAction
    var capability: AssetCapabilityType
    var assetTarget: PlayerAsset?
    var activatedCapability: ActivatedPlayerCapability?
}

class PlayerAsset: Equatable {
    public static func ==(lhs: PlayerAsset, rhs: PlayerAsset) -> Bool {
        return lhs == rhs
    }

    var creationCycle: Int = 0
    var hitPoints: Int = 0
    var gold: Int = 0
    var lumber: Int = 0
    var step: Int = 0

    private(set) var moveRemainderX: Int = 0
    private(set) var moveRemainderY: Int = 0

    var tilePosition: Position {
        willSet {
            position.setFromTile(newValue)
        }
    }
    
    var tilePositionX: Int {
        get {
            return tilePosition.x
        }
        set {
            position.setXFromTile(newValue)
            tilePosition.x = newValue
        }
    }
    
    var tilePositionY: Int {
        get {
            return tilePosition.y
        }
        set {
            position.setYFromTile(newValue)
            tilePosition.y = newValue
        }
    }

    var position: Position {
        willSet {
            tilePosition.setToTile(newValue)
        }
    }
    
    var positionX: Int {
        get {
            return position.x
        }
        set {
            tilePosition.setXToTile(newValue)
            position.x = newValue
        }
    }

    var positionY: Int {
        get {
            return position.y
        }
        set {
            tilePosition.setYToTile(newValue)
            position.y = newValue
        }
    }

    var direction: Direction
    
    private(set) var commands: [AssetCommand]
    private(set) var assetType: PlayerAssetType
    
    static var updateFrequency = 1
    private(set) static var updateDivisor = 32

    var isAlive: Bool {
        return hitPoints > 0
    }

    var tileAligned: Bool {
        return position.TileAligned
    }

    var commandCount: Int {
        return commands.count
    }

    var maxHitPoints: Int {
        return assetType.hitPoints
    }

    var action: AssetAction {
        return commands.last?.action ?? .none
    }

    var type: AssetType {
        return assetType.type
    }

    var color: PlayerColor {
        return assetType.color
    }

    var armor: Int {
        return assetType.armor
    }

    var sight: Int {
        return action == .construct ? assetType.constructionSight : assetType.sight
    }

    var size: Int {
        return assetType.size
    }

    var speed: Int {
        return assetType.speed
    }

    var goldCost: Int {
        return assetType.goldCost
    }

    var lumberCost: Int {
        return assetType.lumberCost
    }

    var foodConsumption: Int {
        return assetType.foodConsumption
    }

    var buildTime: Int {
        return assetType.buildTime
    }

    var attackSteps: Int {
        return assetType.attackSteps
    }

    var reloadSteps: Int {
        return assetType.reloadSteps
    }

    var basicDamage: Int {
        return assetType.basicDamage
    }

    var piercingDamage: Int {
        return assetType.piercingDamage
    }

    var range: Int {
        return assetType.range
    }

    var armorUpgrade: Int {
        return assetType.armorUpgrade()
    }

    var sightUpgrade: Int {
        return assetType.sightUpgrade()
    }

    var speedUpgrade: Int {
        return assetType.speedUpgrade()
    }

    var basicDamageUpgrade: Int {
        return assetType.basicDamageUpgrade()
    }

    var piercingDamageUpgrade: Int {
        return assetType.piercingDamageUpgrade()
    }

    var rangeUpgrade: Int {
        return assetType.rangeUpgrade()
    }

    var effectiveArmor: Int {
        return armor + armorUpgrade
    }

    var effectiveSight: Int {
        return sight + sightUpgrade
    }

    var effectiveSpeed: Int {
        return speed + speedUpgrade
    }

    var effectiveBasicDamage: Int {
        return basicDamage + basicDamageUpgrade
    }

    var effectivePiercingDamage: Int {
        return piercingDamage + piercingDamageUpgrade
    }

    var effectiveRange: Int {
        return range + rangeUpgrade
    }

    var capabilities: [AssetCapabilityType] {
        return assetType.capabilities.filter { _, isIncluded in
            return isIncluded
        }.map { key, _ in
            return key
        }
    }

    init(playerAsset: PlayerAssetType) {
        tilePosition = Position(x: 0, y: 0)
        position = Position(x: 0, y: 0)
        
        assetType = playerAsset;
        hitPoints = playerAsset.hitPoints;
        moveRemainderX = 0;
        moveRemainderY = 0;
        direction = .south;
        
        tilePosition = Position()
    }

    static func setUpdateFrequency(_ frequency: Int) -> Int {
        if 0 < frequency {
            PlayerAsset.updateFrequency = frequency
            PlayerAsset.updateDivisor = 32 * PlayerAsset.updateFrequency
        }
        return PlayerAsset.updateFrequency
    }

    func incrementHitPoints(_ increments: Int) -> Int {
        hitPoints += increments
        hitPoints = min(hitPoints, maxHitPoints)
        return hitPoints
    }

    func decrementHitPoints(_ decrements: Int) -> Int {
        hitPoints -= decrements
        hitPoints = max(hitPoints, 0)
        return hitPoints
    }

    func incrementGold(_ increments: Int) -> Int {
        gold += increments
        return gold
    }

    func decrementGold(_ decrements: Int) -> Int {
        gold -= decrements
        return gold
    }

    func incrementLumber(_ increments: Int) -> Int {
        lumber += increments
        return lumber
    }

    func decrementLumber(_ decrements: Int) -> Int {
        lumber -= decrements
        return lumber
    }

    func resetStep() {
        step = 0
    }

    func incrementStep() {
        step += 1
    }

    func closestPosition(_ pos: Position) -> Position {
        return pos.closestPosition(position, objSize: size)
    }

    func clearCommand() {
        commands.removeAll()
    }

    func pushCommand(command: AssetCommand) {
        commands.append(command)
    }

    func enqueueCommand(command: AssetCommand) {
        commands.insert(command, at: 0)
    }

    func popCommand() {
        guard !commands.isEmpty else {
            return
        }
        commands.removeLast()
    }

    func currentCommand() -> AssetCommand {
        guard let last = commands.last else {
            return AssetCommand(action: .none, capability: .none, assetTarget: nil, activatedCapability: nil)
        }
        return last
    }

    func nextCommand() -> AssetCommand {
        guard commands.count > 1 else {
            return AssetCommand(action: .none, capability: .none, assetTarget: nil, activatedCapability: nil)
        }
        return commands[commands.count - 2]
    }

    func hasAction(_ action: AssetAction) -> Bool {
        return commands.first { command in
            return command.action == action
        } != nil
    }

    func hasActiveCapability(_ capability: AssetCapabilityType) -> Bool {
        return commands.first { command in
            return command.action == .capability && command.capability == capability
        } != nil
    }

    func interruptible() -> Bool {
        let command = currentCommand()
        
        switch command.action {
        case .construct, .build, .mineGold, .conveyLumber, .conveyGold, .death, .decay:
            return false
        case .capability:
            if let assetTarget = command.assetTarget {
                return AssetAction.construct != assetTarget.action
            }
            fallthrough
        default:
            return true
        }
    }
    
    
    func changeType(_ type: PlayerAssetType) {
        assetType = type
    }

    func hasCapability(_ capability: AssetCapabilityType) -> Bool {
        return assetType.hasCapability(capability)
    }

    func moveStep(occupancyMap _: [[PlayerAsset]], diagonals _: [[Bool]]) {
        fatalError("This method is not yet implemented.")
    }
}
