import Foundation

class ActivatedPlayerCapability {
    private(set) var actor: PlayerAsset
    private(set) var playerData: PlayerData
    private(set) var target: PlayerAsset

    init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) {
        self.actor = actor
        self.playerData = playerData
        self.target = target
    }

    func percentComplete(max _: Int) -> Int {
        fatalError("This method should be overriden in the derived class.")
    }

    @discardableResult func incrementStep() -> Bool {
        fatalError("This method should be overriden in the derived class.")
    }

    func cancel() {
        fatalError("This method should be overriden in the derived class.")
    }
}

class PlayerCapability {

    enum TargetType {
        case none, asset, terrain, terrainOrAsset, player
    }

    private(set) var name: String
    private(set) var assetCapabilityType: AssetCapabilityType
    private(set) var targetType: TargetType
    private static var nameRegistry: [String: PlayerCapability] = [:]
    private static var typeRegistry: [Int: PlayerCapability] = [:]

    private static let nameTypeTranslation: [String: AssetCapabilityType] = [
        "None": .none,
        "BuildPeasant": .buildPeasant,
        "BuildFootman": .buildFootman,
        "BuildArcher": .buildArcher,
        "BuildRanger": .buildRanger,
        "BuildFarm": .buildFarm,
        "BuildTownHall": .buildTownHall,
        "BuildBarracks": .buildBarracks,
        "BuildLumberMill": .buildLumberMill,
        "BuildBlacksmith": .buildBlacksmith,
        "BuildKeep": .buildKeep,
        "BuildCastle": .buildCastle,
        "BuildScoutTower": .buildScoutTower,
        "BuildGuardTower": .buildGuardTower,
        "BuildCannonTower": .buildCannonTower,
        "Move": .move,
        "Repair": .repair,
        "Mine": .mine,
        "BuildSimple": .buildSimple,
        "BuildAdvanced": .buildAdvanced,
        "Convey": .convey,
        "Cancel": .cancel,
        "BuildWall": .buildWall,
        "Attack": .attack,
        "StandGround": .standGround,
        "Patrol": .patrol,
        "WeaponUpgrade1": .weaponUpgrade1,
        "WeaponUpgrade2": .weaponUpgrade2,
        "WeaponUpgrade3": .weaponUpgrade3,
        "ArrowUpgrade1": .arrowUpgrade1,
        "ArrowUpgrade2": .arrowUpgrade2,
        "ArrowUpgrade3": .arrowUpgrade3,
        "ArmorUpgrade1": .armorUpgrade1,
        "ArmorUpgrade2": .armorUpgrade2,
        "ArmorUpgrade3": .armorUpgrade3,
        "Longbow": .longbow,
        "RangerScouting": .rangerScouting,
        "Marksmanship": .marksmanship
    ]

    private static let typeStrings = [
        "None",
        "BuildPeasant",
        "BuildFootman",
        "BuildArcher",
        "BuildRanger",
        "BuildFarm",
        "BuildTownHall",
        "BuildBarracks",
        "BuildLumberMill",
        "BuildBlacksmith",
        "BuildKeep",
        "BuildCastle",
        "BuildScoutTower",
        "BuildGuardTower",
        "BuildCannonTower",
        "Move",
        "Repair",
        "Mine",
        "BuildSimple",
        "BuildAdvanced",
        "Convey",
        "Cancel",
        "BuildWall",
        "Attack",
        "StandGround",
        "Patrol",
        "WeaponUpgrade1",
        "WeaponUpgrade2",
        "WeaponUpgrade3",
        "ArrowUpgrade1",
        "ArrowUpgrade2",
        "ArrowUpgrade3",
        "ArmorUpgrade1",
        "ArmorUpgrade2",
        "ArmorUpgrade3",
        "Longbow",
        "RangerScouting",
        "Marksmanship"
    ]

    init(name: String = "None", targetType: TargetType = .none) {
        self.name = name
        self.assetCapabilityType = PlayerCapability.findType(name)
        self.targetType = targetType
    }

    @discardableResult static func register(capability: PlayerCapability) -> Bool {
        if nameRegistry[capability.name] != nil {
            return false
        }
        nameRegistry[capability.name] = capability
        typeRegistry[PlayerCapability.findType(capability.name).rawValue] = capability
        return true
    }

    static func findCapability(_ type: AssetCapabilityType) -> PlayerCapability {
        return typeRegistry[type.rawValue] ?? PlayerCapability()
    }

    static func findCapability(_ name: String) -> PlayerCapability {
        return nameRegistry[name] ?? PlayerCapability()
    }

    static func findType(_ name: String) -> AssetCapabilityType {
        return nameTypeTranslation[name] ?? .none
    }

    static func findName(_ type: AssetCapabilityType) -> String {
        return type.rawValue >= 0 && type.rawValue < typeStrings.count ? typeStrings[type.rawValue] : ""
    }

    func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        fatalError("You need to override this method.")
    }

    func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        fatalError("You need to override this method.")
    }

    @discardableResult func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        fatalError("You need to override this method.")
    }
}

class PlayerUpgrade {
    enum GameError: Error {
        case fileIteratorNull
        case failedToGetName
        case unknownUpgradeType(type: String)
        case failedToGetArmor
        case failedToGetSight
        case failedToGetSpeed
        case failedToGetBasicDamage
        case failedToGetPiercingDamage
        case failedToGetRange
        case failedToGetGoldCost
        case failedToGetLumberCost
        case failedToGetResearchTime
        case failedToGetAffectedAssetCountString
        case failedToReadAffectedAsset
    }

    private(set) var name = ""
    private(set) var armor = -1
    private(set) var sight = -1
    private(set) var speed = -1
    private(set) var basicDamage = -1
    private(set) var piercingDamage = -1
    private(set) var range = -1
    private(set) var goldCost = -1
    private(set) var lumberCost = -1
    private(set) var researchTime = -1
    private(set) var affectedAssets = [AssetType]()
    static var registryByName: [String: PlayerUpgrade] = [:]
    static var registryByType: [Int: PlayerUpgrade] = [:]

    static func loadUpgrades(from dataContainer: DataContainer) throws {
        try dataContainer.contentURLs.filter { url in
            return url.pathExtension == "dat"
        }.forEach { url in
            try load(from: FileDataSource(url: url))
            printDebug("Loaded upgrade \(url.lastPathComponent).", level: .low)
        }
        printDebug("Upgrades loaded.", level: .low)
    }

    static func load(from dataSource: DataSource) throws {
        let lineSource = LineDataSource(dataSource: dataSource)

        guard let name = lineSource.readLine() else {
            throw GameError.failedToGetName
        }
        let upgradeType = PlayerCapability.findType(name)

        if upgradeType == .none && name != PlayerCapability.findName(.none) {
            throw GameError.unknownUpgradeType(type: name)
        }

        let playerUpgrade = registryByName[name] ?? PlayerUpgrade()
        if playerUpgrade.name == "None" {
            playerUpgrade.name = name
            registryByName[name] = playerUpgrade
            registryByType[upgradeType.rawValue] = playerUpgrade
        }

        if let armorString = lineSource.readLine(), let armor = Int(armorString) {
            playerUpgrade.armor = armor
        } else {
            throw GameError.failedToGetArmor
        }

        if let sightString = lineSource.readLine(), let sight = Int(sightString) {
            playerUpgrade.sight = sight
        } else {
            throw GameError.failedToGetSight
        }
        if let speedString = lineSource.readLine(), let speed = Int(speedString) {
            playerUpgrade.speed = speed
        } else {
            throw GameError.failedToGetSpeed
        }
        if let basicDamageString = lineSource.readLine(), let basicDamage = Int(basicDamageString) {
            playerUpgrade.basicDamage = basicDamage
        } else {
            throw GameError.failedToGetBasicDamage
        }
        if let piercingDamageString = lineSource.readLine(), let piercingDamage = Int(piercingDamageString) {
            playerUpgrade.piercingDamage = piercingDamage
        } else {
            throw GameError.failedToGetPiercingDamage
        }
        if let rangeString = lineSource.readLine(), let range = Int(rangeString) {
            playerUpgrade.range = range
        } else {
            throw GameError.failedToGetRange
        }
        if let goldCostString = lineSource.readLine(), let goldCost = Int(goldCostString) {
            playerUpgrade.goldCost = goldCost
        } else {
            throw GameError.failedToGetGoldCost
        }
        if let lumberCostString = lineSource.readLine(), let lumberCost = Int(lumberCostString) {
            playerUpgrade.lumberCost = lumberCost
        } else {
            throw GameError.failedToGetLumberCost
        }
        if let researchTimeString = lineSource.readLine(), let researchTime = Int(researchTimeString) {
            playerUpgrade.researchTime = researchTime
        } else {
            throw GameError.failedToGetResearchTime
        }

        guard let affectedAssetCountString = lineSource.readLine(), let affectedAssetCount = Int(affectedAssetCountString) else {
            throw GameError.failedToGetAffectedAssetCountString
        }
        for _ in 0 ..< affectedAssetCount {
            if let assetRequirementString = lineSource.readLine() {
                playerUpgrade.affectedAssets.append(PlayerAssetType.findType(assetRequirementString))
            } else {
                throw GameError.failedToReadAffectedAsset
            }
        }
    }

    static func findUpgrade(_ type: AssetCapabilityType) -> PlayerUpgrade {
        return registryByType[type.rawValue] ?? PlayerUpgrade()
    }

    static func findUpgrade(_ name: String) -> PlayerUpgrade? {
        return registryByName[name]
    }
}

class PlayerAssetType {
    enum GameError: Error {
        case unknownResourceType(type: String)
        case failedToGetResourceTypeName
        case failedToGetHitPoints
        case failedToGetArmor
        case failedToGetSight
        case failedToGetConstructionSight
        case failedToGetSize
        case failedToGetSpeed
        case failedToGetGoldCost
        case failedToGetLumberCost
        case failedToGetFoodConsumption
        case failedToGetBuildTime
        case failedToGetAttackSteps
        case failedToGetReloadSteps
        case failedToGetBasicDamage
        case failedToGetPiercingDamage
        case failedToGetRange
        case failedToGetCapabilityCount
        case failedToReadCapability
        case failedToGetAssetRequirementCount
        case failedToReadAssetRequirement
        case failedToLoadResource
        case fileIteratorNull
    }

    private(set) var name = "None"
    private(set) var type = AssetType.none
    private(set) var color = PlayerColor.none
    private(set) var capabilities: [AssetCapabilityType: Bool] = [:]
    private(set) var assetRequirements: [AssetType] = []
    private(set) var assetUpgrades: [PlayerUpgrade] = []
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

    var armorUpgrade: Int {
        var returnValue = 0
        for upgrade in assetUpgrades {
            returnValue += upgrade.armor
        }
        return returnValue
    }

    var sightUpgrade: Int {
        var returnValue = 0
        for upgrade in assetUpgrades {
            returnValue += upgrade.sight
        }
        return returnValue
    }

    var speedUpgrade: Int {
        var returnValue = 0
        for upgrade in assetUpgrades {
            returnValue += upgrade.speed
        }
        return returnValue
    }

    var basicDamageUpgrade: Int {
        var returnValue = 0
        for upgrade in assetUpgrades {
            returnValue += upgrade.basicDamage
        }
        return returnValue
    }

    var piercingDamageUpgrade: Int {
        var returnValue = 0
        for upgrade in assetUpgrades {
            returnValue += upgrade.piercingDamage
        }
        return returnValue
    }

    var rangeUpgrade: Int {
        var returnValue = 0
        for upgrade in assetUpgrades {
            returnValue += upgrade.range
        }
        return returnValue
    }

    private static let names: [AssetType: String] = [
        .none: "None",
        .peasant: "Peasant",
        .footman: "Footman",
        .archer: "Archer",
        .ranger: "Ranger",
        .goldMine: "GoldMine",
        .townHall: "TownHall",
        .keep: "Keep",
        .castle: "Castle",
        .farm: "Farm",
        .barracks: "Barracks",
        .lumberMill: "LumberMill",
        .blacksmith: "Blacksmith",
        .scoutTower: "ScoutTower",
        .guardTower: "GuardTower",
        .cannonTower: "CannonTower"
    ]

    private static let types: [String: AssetType] = [
        "None": .none,
        "Peasant": .peasant,
        "Footman": .footman,
        "Archer": .archer,
        "Ranger": .ranger,
        "GoldMine": .goldMine,
        "TownHall": .townHall,
        "Keep": .keep,
        "Castle": .castle,
        "Farm": .farm,
        "Barracks": .barracks,
        "LumberMill": .lumberMill,
        "Blacksmith": .blacksmith,
        "ScoutTower": .scoutTower,
        "GuardTower": .guardTower,
        "CannonTower": .cannonTower
    ]

    private(set) static var registry: [String: PlayerAssetType] = [:]

    static var maxSight: Int {
        var currentMaxSight = 0
        for (_, type) in registry {
            currentMaxSight = max(currentMaxSight, type.sight)
        }
        return currentMaxSight
    }

    init(playerAsset: PlayerAssetType) {
        name = playerAsset.name
        type = playerAsset.type
        color = playerAsset.color
        capabilities = playerAsset.capabilities
        assetUpgrades = playerAsset.assetUpgrades
        assetRequirements = playerAsset.assetRequirements
        hitPoints = playerAsset.hitPoints
        armor = playerAsset.armor
        sight = playerAsset.sight
        constructionSight = playerAsset.constructionSight
        size = playerAsset.size
        speed = playerAsset.speed
        goldCost = playerAsset.goldCost
        lumberCost = playerAsset.lumberCost
        foodConsumption = playerAsset.foodConsumption
        buildTime = playerAsset.buildTime
        attackSteps = playerAsset.attackSteps
        reloadSteps = playerAsset.reloadSteps
        basicDamage = playerAsset.basicDamage
        piercingDamage = playerAsset.piercingDamage
        range = playerAsset.range
    }

    init() {
        for capability in AssetCapabilityType.allValues {
            capabilities[capability] = false
        }
        hitPoints = 1
        armor = 0
        sight = 0
        constructionSight = 0
        size = 1
        speed = 0
        goldCost = 0
        lumberCost = 0
        foodConsumption = 0
        buildTime = 0
        attackSteps = 0
        reloadSteps = 0
        basicDamage = 0
        piercingDamage = 0
        range = 0
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

    func addUpgrade(_ upgrade: PlayerUpgrade) {
        assetUpgrades.append(upgrade)
    }

    func construct() -> PlayerAsset {
        return PlayerAsset(playerAssetType: self)
    }

    static func findType(_ name: String) -> AssetType {
        return types[name] ?? .none
    }

    static func findName(_ type: AssetType) -> String {
        return names[type] ?? ""
    }

    static func loadTypes(from dataContainer: DataContainer) {
        dataContainer.contentURLs.filter { url in
            return url.pathExtension == "dat"
        }.forEach { url in
            do {
                try load(from: FileDataSource(url: url))
                printDebug("Loaded type \(url.lastPathComponent).", level: .low)
            } catch {
                printError("Failed to load type \(url.lastPathComponent). \(error.localizedDescription)")
            }
        }
        let playerAssetType = PlayerAssetType()
        playerAssetType.name = "None"
        playerAssetType.type = .none
        playerAssetType.color = .none
        playerAssetType.hitPoints = 256
        registry["None"] = playerAssetType
        printDebug("Types loaded.", level: .low)
    }

    static func load(from dataSource: DataSource) throws {
        let lineSource = LineDataSource(dataSource: dataSource)

        guard let name = lineSource.readLine() else {
            throw GameError.failedToGetResourceTypeName
        }

        let assetType = findType(name)

        if assetType == .none && name != names[.none] {
            throw GameError.unknownResourceType(type: name)
        }

        let playerAssetType = registry[name] ?? PlayerAssetType()
        if playerAssetType.name == "None" {
            playerAssetType.name = name
            registry[name] = playerAssetType
        }
        playerAssetType.type = assetType
        playerAssetType.color = .none

        if let hitPointsString = lineSource.readLine(), let hitPoints = Int(hitPointsString) {
            playerAssetType.hitPoints = hitPoints
        } else {
            throw GameError.failedToGetHitPoints
        }
        if let armorString = lineSource.readLine(), let armor = Int(armorString) {
            playerAssetType.armor = armor
        } else {
            throw GameError.failedToGetArmor
        }
        if let sightString = lineSource.readLine(), let sight = Int(sightString) {
            playerAssetType.sight = sight
        } else {
            throw GameError.failedToGetSight
        }
        if let constructionSightString = lineSource.readLine(), let constructionSight = Int(constructionSightString) {
            playerAssetType.constructionSight = constructionSight
        } else {
            throw GameError.failedToGetConstructionSight
        }
        if let sizeString = lineSource.readLine(), let size = Int(sizeString) {
            playerAssetType.size = size
        } else {
            throw GameError.failedToGetSize
        }
        if let speedString = lineSource.readLine(), let speed = Int(speedString) {
            playerAssetType.speed = speed
        } else {
            throw GameError.failedToGetSpeed
        }
        if let goldCostString = lineSource.readLine(), let goldCost = Int(goldCostString) {
            playerAssetType.goldCost = goldCost
        } else {
            throw GameError.failedToGetGoldCost
        }
        if let lumberCostString = lineSource.readLine(), let lumberCost = Int(lumberCostString) {
            playerAssetType.lumberCost = lumberCost
        } else {
            throw GameError.failedToGetLumberCost
        }
        if let foodConsumptionString = lineSource.readLine(), let foodConsumption = Int(foodConsumptionString) {
            playerAssetType.foodConsumption = foodConsumption
        } else {
            throw GameError.failedToGetFoodConsumption
        }
        if let buildTimeString = lineSource.readLine(), let buildTime = Int(buildTimeString) {
            playerAssetType.buildTime = buildTime
        } else {
            throw GameError.failedToGetBuildTime
        }
        if let attackStepsString = lineSource.readLine(), let attackSteps = Int(attackStepsString) {
            playerAssetType.attackSteps = attackSteps
        } else {
            throw GameError.failedToGetAttackSteps
        }
        if let reloadStepsString = lineSource.readLine(), let reloadSteps = Int(reloadStepsString) {
            playerAssetType.reloadSteps = reloadSteps
        } else {
            throw GameError.failedToGetReloadSteps
        }
        if let basicDamageString = lineSource.readLine(), let basicDamage = Int(basicDamageString) {
            playerAssetType.basicDamage = basicDamage
        } else {
            throw GameError.failedToGetBasicDamage
        }
        if let piercingDamageString = lineSource.readLine(), let piercingDamage = Int(piercingDamageString) {
            playerAssetType.piercingDamage = piercingDamage
        } else {
            throw GameError.failedToGetPiercingDamage
        }
        if let rangeString = lineSource.readLine(), let range = Int(rangeString) {
            playerAssetType.range = range
        } else {
            throw GameError.failedToGetRange
        }

        guard let capabilityCountString = lineSource.readLine(), let capabilityCount = Int(capabilityCountString) else {
            throw GameError.failedToGetCapabilityCount
        }
        for (capability, _) in playerAssetType.capabilities {
            playerAssetType.capabilities[capability] = false
        }
        for _ in 0 ..< capabilityCount {
            if let capabilityString = lineSource.readLine() {
                playerAssetType.addCapability(PlayerCapability.findType(capabilityString))
            } else {
                throw GameError.failedToReadCapability
            }
        }

        guard let assetRequirementCountString = lineSource.readLine(), let assetRequirementCount = Int(assetRequirementCountString) else {
            throw GameError.failedToGetAssetRequirementCount
        }
        for _ in 0 ..< assetRequirementCount {
            if let assetRequirementString = lineSource.readLine() {
                playerAssetType.assetRequirements.append(findType(assetRequirementString))
            } else {
                throw GameError.failedToReadAssetRequirement
            }
        }
    }

    static func findDefault(_ name: String) -> PlayerAssetType {
        return registry[name] ?? PlayerAssetType()
    }

    static func findDefault(_ type: AssetType) -> PlayerAssetType {
        return findDefault(findName(type))
    }

    static func duplicateRegistry(changeColorTo color: PlayerColor) -> [String: PlayerAssetType] {
        var returnRegistry: [String: PlayerAssetType] = [:]
        for (key, value) in registry {
            let newAssetType = PlayerAssetType(playerAsset: value)
            newAssetType.color = color
            returnRegistry[key] = newAssetType
        }
        return returnRegistry
    }
}

struct AssetCommand {
    var action: AssetAction
    var capability: AssetCapabilityType?
    var assetTarget: PlayerAsset?
    var activatedCapability: ActivatedPlayerCapability?
}

class PlayerAsset {

    var creationCycle: Int = 0
    var hitPoints: Int = 0
    var gold: Int = 0
    var lumber: Int = 0
    var step: Int = 0

    private static let deltaX: [Direction: Int] = [
        .north: 0,
        .northEast: 5,
        .east: 7,
        .southEast: 5,
        .south: 0,
        .southWest: -5,
        .west: -7,
        .northWest: -5
    ]
    private static let deltaY: [Direction: Int] = [
        .north: -7,
        .northEast: -5,
        .east: 0,
        .southEast: 5,
        .south: 7,
        .southWest: 5,
        .west: 0,
        .northWest: -5
    ]

    private(set) var moveRemainderX: Int = 0
    private(set) var moveRemainderY: Int = 0

    var position: Position

    var tilePosition: Position {
        get {
            return Position.tile(fromAbsolute: position)
        }
        set {
            position = Position.absolute(fromTile: newValue)
        }
    }

    var tilePositionX: Int {
        return tilePosition.x
    }

    var tilePositionY: Int {
        return tilePosition.y
    }

    var positionX: Int {
        return position.x
    }

    var positionY: Int {
        return position.y
    }

    var direction: Direction

    private(set) var commands: [AssetCommand] = []
    private(set) var assetType: PlayerAssetType

    private static var _updateFrequency = 1
    static var updateFrequency: Int {
        get {
            return _updateFrequency
        }
        set {
            if newValue > 0 {
                _updateFrequency = newValue
                updateDivisor = 32 * _updateFrequency
            }
        }
    }

    private(set) static var updateDivisor = 32

    var isAlive: Bool {
        return hitPoints > 0
    }

    var tileAligned: Bool {
        return position.tileAligned
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
        return assetType.armorUpgrade
    }

    var sightUpgrade: Int {
        return assetType.sightUpgrade
    }

    var speedUpgrade: Int {
        return assetType.speedUpgrade
    }

    var basicDamageUpgrade: Int {
        return assetType.basicDamageUpgrade
    }

    var piercingDamageUpgrade: Int {
        return assetType.piercingDamageUpgrade
    }

    var rangeUpgrade: Int {
        return assetType.rangeUpgrade
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

    var currentCommand: AssetCommand {
        guard let last = commands.last else {
            return AssetCommand(action: .none, capability: .none, assetTarget: nil, activatedCapability: nil)
        }
        return last
    }

    var nextCommand: AssetCommand {
        guard commands.count > 1 else {
            return AssetCommand(action: .none, capability: .none, assetTarget: nil, activatedCapability: nil)
        }
        return commands[commands.count - 2]
    }

    var activeCapability: AssetCapabilityType {
        return commands.first { command in
            return command.action == .capability
        }?.capability ?? .none
    }

    init(playerAssetType: PlayerAssetType) {
        position = Position()
        assetType = playerAssetType
        hitPoints = playerAssetType.hitPoints
        moveRemainderX = 0
        moveRemainderY = 0
        direction = .south
    }

    @discardableResult func incrementHitPoints(_ increments: Int) -> Int {
        hitPoints += increments
        hitPoints = min(hitPoints, maxHitPoints)
        return hitPoints
    }

    @discardableResult func decrementHitPoints(_ decrements: Int) -> Int {
        hitPoints -= decrements
        hitPoints = max(hitPoints, 0)
        return hitPoints
    }

    @discardableResult func incrementGold(_ increments: Int) -> Int {
        gold += increments
        return gold
    }

    @discardableResult func decrementGold(_ decrements: Int) -> Int {
        gold -= decrements
        return gold
    }

    @discardableResult func incrementLumber(_ increments: Int) -> Int {
        lumber += increments
        return lumber
    }

    @discardableResult func decrementLumber(_ decrements: Int) -> Int {
        lumber -= decrements
        return lumber
    }

    func resetStep() {
        step = 0
    }

    func incrementStep() {
        step += 1
    }

    func closestPosition(_ position: Position) -> Position {
        return position.closestPosition(searchingFrom: self.position, areaLength: size)
    }

    func clearCommand() {
        commands.removeAll()
    }

    func pushCommand(_ command: AssetCommand) {
        commands.append(command)
    }

    func enqueueCommand(_ command: AssetCommand) {
        commands.insert(command, at: 0)
    }

    func popCommand() {
        guard !commands.isEmpty else {
            return
        }
        commands.removeLast()
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
        let command = currentCommand
        switch command.action {
        case .construct, .build, .mineGold, .conveyLumber, .conveyGold, .death, .decay:
            return false
        case .capability:
            if let assetTarget = command.assetTarget {
                return AssetAction.construct != assetTarget.action
            }
            return true
        default:
            return true
        }
    }

    func changeType(to type: PlayerAssetType) {
        assetType = type
    }

    func hasCapability(_ capability: AssetCapabilityType) -> Bool {
        return assetType.hasCapability(capability)
    }

    func moveStep(occupancyMap: inout [[PlayerAsset?]], diagonals: inout [[Bool]]) -> Bool {
        let newX = speed * PlayerAsset.deltaX[direction]! * Position.tileWidth + moveRemainderX
        let newY = speed * PlayerAsset.deltaY[direction]! * Position.tileHeight + moveRemainderY
        var newPosition = Position(x: position.x + newX / PlayerAsset.updateDivisor, y: position.y + newY / PlayerAsset.updateDivisor)
        if position.tileOctant == .max || position.tileOctant == direction || newPosition.tileOctant != direction {
            moveRemainderX = newX % PlayerAsset.updateDivisor
            moveRemainderY = newY % PlayerAsset.updateDivisor
        } else {
            moveRemainderX = 0
            moveRemainderY = 0
            newPosition.normalizeToTileCenter()
        }

        let newTilePosition = Position.tile(fromAbsolute: newPosition)
        if tilePosition != newTilePosition {
            let diagonalX = min(tilePosition.x, newTilePosition.x)
            let diagonalY = min(tilePosition.y, newTilePosition.y)
            if occupancyMap[tilePositionY][tilePositionX] != nil || (isDiagonal(tilePosition, newTilePosition) && diagonals[diagonalY][diagonalX]) {
                if let occupancyMapSquare = occupancyMap[newTilePosition.y][newTilePosition.x], occupancyMapSquare.action == .walk, occupancyMapSquare.direction == position.tileOctant {
                    position = newPosition
                    return true
                }
                position = newPosition
                return false
            }
            diagonals[diagonalY][diagonalX] = isDiagonal(tilePosition, newTilePosition)
            occupancyMap[newTilePosition.y][newTilePosition.x] = occupancyMap[tilePosition.y][tilePosition.x]
            occupancyMap[tilePosition.y][tilePosition.x] = nil
        }
        position = newPosition
        incrementStep()
        return true
    }
}
