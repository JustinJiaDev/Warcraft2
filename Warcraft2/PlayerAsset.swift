import Foundation

class ActivatedPlayerCapability {
    var actor: PlayerAsset
    var playerData: PlayerData
    var target: PlayerAsset

    init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) {
        self.actor = actor
        self.playerData = playerData
        self.target = target
    }

    func percentComplete(max _: Int) -> Int {
        fatalError("You need to override this method.")
    }

    func incrementstep() {
        fatalError("You need to override this method.")
    }

    func cancel() {
        fatalError("You need to override this method.")
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

    init(name: String = "None", targetType: TargetType = .none) {
        self.name = name
        self.assetCapabilityType = PlayerCapability.findType(with: name)
        self.targetType = targetType
    }

    private static func register(capability: PlayerCapability) -> Bool {
        if let _ = nameRegistry[capability.name] {
            return false
        }
        nameRegistry[capability.name] = capability
        typeRegistry[PlayerCapability.findType(with: capability.name).rawValue] = capability
        return true
    }

    static func findCapability(with type: AssetCapabilityType) -> PlayerCapability {
        if let value = typeRegistry[type.rawValue] {
            return value
        }
        return PlayerCapability()
    }

    static func findCapability(with name: String) -> PlayerCapability {
        if let value = nameRegistry[name] {
            return value
        }
        return PlayerCapability()
    }

    static func findType(with name: String) -> AssetCapabilityType {
        var nameTypeTranslation: [String: AssetCapabilityType] = [:]
        nameTypeTranslation["None"] = .none
        nameTypeTranslation["BuildPeasant"] = .buildPeasant
        nameTypeTranslation["BuildFootman"] = .buildFootman
        nameTypeTranslation["BuildArcher"] = .buildArcher
        nameTypeTranslation["BuildRanger"] = .buildRanger
        nameTypeTranslation["BuildFarm"] = .buildFarm
        nameTypeTranslation["BuildTownHall"] = .buildTownHall
        nameTypeTranslation["BuildBarracks"] = .buildBarracks
        nameTypeTranslation["BuildLumberMill"] = .buildLumberMill
        nameTypeTranslation["BuildBlacksmith"] = .buildBlacksmith
        nameTypeTranslation["BuildKeep"] = .buildKeep
        nameTypeTranslation["BuildCastle"] = .buildCastle
        nameTypeTranslation["BuildScoutTower"] = .buildScoutTower
        nameTypeTranslation["BuildGuardTower"] = .buildGuardTower
        nameTypeTranslation["BuildCannonTower"] = .buildCannonTower
        nameTypeTranslation["Move"] = .move
        nameTypeTranslation["Repair"] = .repair
        nameTypeTranslation["Mine"] = .mine
        nameTypeTranslation["BuildSimple"] = .buildSimple
        nameTypeTranslation["BuildAdvanced"] = .buildAdvanced
        nameTypeTranslation["Convey"] = .convey
        nameTypeTranslation["Cancel"] = .cancel
        nameTypeTranslation["BuildWall"] = .buildWall
        nameTypeTranslation["Attack"] = .attack
        nameTypeTranslation["StandGround"] = .standGround
        nameTypeTranslation["Patrol"] = .patrol
        nameTypeTranslation["WeaponUpgrade1"] = .weaponUpgrade1
        nameTypeTranslation["WeaponUpgrade2"] = .weaponUpgrade2
        nameTypeTranslation["WeaponUpgrade3"] = .weaponUpgrade3
        nameTypeTranslation["ArrowUpgrade1"] = .arrowUpgrade1
        nameTypeTranslation["ArrowUpgrade2"] = .arrowUpgrade2
        nameTypeTranslation["ArrowUpgrade3"] = .arrowUpgrade3
        nameTypeTranslation["ArmorUpgrade1"] = .armorUpgrade1
        nameTypeTranslation["ArmorUpgrade2"] = .armorUpgrade2
        nameTypeTranslation["ArmorUpgrade3"] = .armorUpgrade3
        nameTypeTranslation["Longbow"] = .longbow
        nameTypeTranslation["RangerScouting"] = .rangerScouting
        nameTypeTranslation["Marksmanship"] = .marksmanship

        if let value = nameTypeTranslation[name] {
            return value
        }
        printError("Unknown capability name \"\(name)\"\n")
        return .none
    }

    static func findName(with type: AssetCapabilityType) -> String {
        let typeStrings = [
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

        if type.rawValue < 0 || type.rawValue >= typeStrings.count {
            return ""
        }
        return typeStrings[type.rawValue]
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
        try dataContainer.urls.filter { url in
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
        let upgradeType = PlayerCapability.findType(with: name)

        if upgradeType == .none && name != PlayerCapability.findName(with: .none) {
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
                playerUpgrade.affectedAssets.append(PlayerAssetType.findType(with: assetRequirementString))
            } else {
                throw GameError.failedToReadAffectedAsset
            }
        }
    }

    static func findUpgrade(with type: AssetCapabilityType) -> PlayerUpgrade {
        return registryByType[type.rawValue] ?? PlayerUpgrade()
    }

    static func findUpgrade(with name: String) -> PlayerUpgrade {
        return registryByName[name] ?? PlayerUpgrade()
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

    private(set) static var typeStrings = [
        "None",
        "Peasant",
        "Footman",
        "Archer",
        "Ranger",
        "GoldMine",
        "TownHall",
        "Keep",
        "Castle",
        "Farm",
        "Barracks",
        "LumberMill",
        "Blacksmith",
        "ScoutTower",
        "GuardTower",
        "CannonTower"
    ]

    private(set) static var nameTypeTranslation: [String: AssetType] = [
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

    static func findType(with name: String) -> AssetType {
        return nameTypeTranslation[name] ?? .none
    }

    static func findName(with type: AssetType) -> String {
        return typeStrings.indices.contains(type.hashValue) ? typeStrings[type.hashValue] : ""
    }

    static func loadTypes(from dataContainer: DataContainer) throws {
        try dataContainer.urls.filter { url in
            return url.pathExtension == "dat"
        }.forEach { url in
            try load(from: FileDataSource(url: url))
            printDebug("Loaded type \(url.lastPathComponent).", level: .low)
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

        let assetType = findType(with: name)

        if assetType == .none && name != typeStrings[AssetType.none.rawValue] {
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
                playerAssetType.addCapability(PlayerCapability.findType(with: capabilityString))
            } else {
                throw GameError.failedToReadCapability
            }
        }

        guard let assetRequirementCountString = lineSource.readLine(), let assetRequirementCount = Int(assetRequirementCountString) else {
            throw GameError.failedToGetAssetRequirementCount
        }
        for _ in 0 ..< assetRequirementCount {
            if let assetRequirementString = lineSource.readLine() {
                playerAssetType.assetRequirements.append(findType(with: assetRequirementString))
            } else {
                throw GameError.failedToReadAssetRequirement
            }
        }
    }

    static func findDefault(with name: String) -> PlayerAssetType {
        return registry[name] ?? PlayerAssetType()
    }

    static func findDefault(with type: AssetType) -> PlayerAssetType {
        return findDefault(with: findName(with: type))
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
    var capability: AssetCapabilityType
    var assetTarget: PlayerAsset?
    var activatedCapability: ActivatedPlayerCapability?
}

class PlayerAsset {

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

    init(playerAssetType: PlayerAssetType) {
        tilePosition = Position(x: 0, y: 0)
        position = Position(x: 0, y: 0)

        assetType = playerAssetType
        hitPoints = playerAssetType.hitPoints
        moveRemainderX = 0
        moveRemainderY = 0
        direction = .south

        PlayerAsset.updateFrequency = 1

        tilePosition = Position()
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
        return position.closestPosition(position, objectSize: size)
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
        let currentOctant = position.tileOctant
        let currentTile = tilePosition
        let currentPosition = position
        let deltaX: [Direction: Int] = [
            .north: 0,
            .northEast: 5,
            .east: 7,
            .southEast: 5,
            .south: 0,
            .southWest: -5,
            .west: -7,
            .northWest: -5
        ]
        let deltaY: [Direction: Int] = [
            .north: -7,
            .northEast: -5,
            .east: 0,
            .southEast: 5,
            .south: 7,
            .southWest: -5,
            .west: -0,
            .northWest: -5
        ]

        if currentOctant == .max || currentOctant == direction { // Aligned just move
            let newX = speed * deltaX[direction]! * Position.tileWidth + moveRemainderX
            let newY = speed * deltaY[direction]! * Position.tileHeight + moveRemainderY
            moveRemainderX = newX % PlayerAsset.updateDivisor
            moveRemainderY = newY % PlayerAsset.updateDivisor
            positionX += newX / PlayerAsset.updateDivisor
            positionY += newY / PlayerAsset.updateDivisor
        } else { // Entering
            let newX = speed + deltaX[direction]! * Position.tileWidth + moveRemainderX
            let newY = speed + deltaY[direction]! * Position.tileHeight + moveRemainderY
            moveRemainderX = newX % PlayerAsset.updateDivisor
            moveRemainderY = newY % PlayerAsset.updateDivisor
            let newPosition = Position(x: positionX + newX / PlayerAsset.updateDivisor, y: positionY + newY / PlayerAsset.updateDivisor)

            if newPosition.tileOctant == direction {
                newPosition.setToTile(newPosition)
                newPosition.setFromTile(newPosition)
                moveRemainderX = 0
                moveRemainderY = 0
            }

            position = newPosition
        }

        tilePosition.setToTile(position)
        if currentTile != tilePosition {
            let diagonal = (currentTile.x != tilePositionX) && (currentTile.y != tilePositionY)
            let diagonalX = min(currentTile.x, tilePositionX)
            let diagonalY = min(currentTile.y, tilePositionY)

            if (occupancyMap[tilePositionY][tilePositionX] != nil) || (diagonal && diagonals[diagonalY][diagonalX]) {
                var returnValue = false
                if let occupancyMapSquare = occupancyMap[tilePositionY][tilePositionX], occupancyMapSquare.action == .walk {
                    returnValue = occupancyMapSquare.direction == currentPosition.tileOctant
                }
                tilePosition = currentTile
                position = currentPosition
                return returnValue
            }
            if diagonal {
                diagonals[diagonalY][diagonalX] = true
            }
            occupancyMap[tilePositionY][tilePositionX] = occupancyMap[currentTile.y][currentTile.x]
            occupancyMap[currentTile.y][currentTile.x] = nil
        }

        incrementStep()
        return true
    }
}
