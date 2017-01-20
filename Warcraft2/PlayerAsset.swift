//
//  PlayerAsset.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/19/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class PlayerData {
}

class ActivatedPlayerCapability {
    private var actor: PlayerAsset
    private var playerData: PlayerData
    private var target: PlayerAsset

    init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) {
        fatalError("You need to override this method.")
    }

    func percentComplete(max _: Int) {
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

    init(name: String, targetType: TargetType) {
        fatalError("You need to override this method.")
    }

    private static func nameRegistry() -> [String: PlayerCapability] {
        fatalError("You need to override this method.")
    }

    private static func typeRegistry() -> [Int: PlayerCapability] {
        fatalError("You need to override this method.")
    }

    private static func register(capability: PlayerCapability) -> Bool {
        fatalError("You need to override this method.")
    }

    static func findCapability(type: AssetCapabilityType) -> PlayerCapability {
        fatalError("You need to override this method.")
    }

    static func findCapability(name: String) -> PlayerCapability {
        fatalError("You need to override this method.")
    }

    static func nameToType(name: String) -> AssetCapabilityType {
        fatalError("You need to override this method.")
    }

    static func typeToName(type: AssetCapabilityType) -> String {
        fatalError("You need to override this method.")
    }

    func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        fatalError("You need to override this method.")
    }

    func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        fatalError("You need to override this method.")
    }

    func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        fatalError("You need to override this method.")
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
        fatalError("You need to override this method.")
    }

    static func loadUpgrades(container: DataContainer) -> Bool {
        fatalError("You need to override this method.")
    }

    static func load(source: DataSource) -> Bool {
        fatalError("You need to override this method.")
    }

    static func findUpgrade(type: AssetCapabilityType) -> PlayerUpgrade {
        fatalError("You need to override this method.")
    }

    static func findUpgrade(name: String) -> PlayerUpgrade {
        fatalError("You need to override this method.")
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
        fatalError("You need to override this method.")
    }

    func armorUpgrade() -> Int {
        fatalError("You need to override this method.")
    }

    func sightUpgrade() -> Int {
        fatalError("You need to override this method.")
    }

    func speedUpgrade() -> Int {
        fatalError("You need to override this method.")
    }

    func basicDamageUpgrade() -> Int {
        fatalError("You need to override this method.")
    }

    func piercingDamageUpgrade() -> Int {
        fatalError("You need to override this method.")
    }

    func rangeUpgrade() -> Int {
        fatalError("You need to override this method.")
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
        fatalError("You need to override this method.")
    }

    static func typeToName(type: AssetType) -> String {
        fatalError("You need to override this method.")
    }

    static func maxSight() -> Int {
        fatalError("You need to override this method.")
    }

    static func loadTypes(container: DataContainer) -> Bool {
        fatalError("You need to override this method.")
    }

    static func load(source: DataSource) -> Bool {
        fatalError("You need to override this method.")
    }

    static func findDefault(from name: String) -> PlayerAssetType {
        fatalError("You need to override this method.")
    }

    static func findDefault(from type: AssetType) -> PlayerAssetType {
        fatalError("You need to override this method.")
    }

    static func duplicateRegistry(color: PlayerColor) -> [String: PlayerAssetType] {
        fatalError("You need to override this method.")
    }

    static func construct() -> PlayerAsset {
        fatalError("You need to override this method.")
    }
}

struct AssetCommand {
    var action: AssetAction
    var capability: AssetCapabilityType
    var assetTarget: PlayerAsset
    var activatedCapability: ActivatedPlayerCapability
}

class PlayerAsset {
    var creationCycle: Int
    var hitPoints: Int
    var gold: Int
    var lumber: Int
    var step: Int

    private(set) var moveRemainderX: Int
    private(set) var moveRemainderY: Int
    private(set) var tilePosition: Position
    private(set) var position: Position
    private(set) var direction: Direction
    private(set) var commands: [AssetCommand]
    private(set) var type: PlayerAssetType
    private(set) static var updateFrequency: Int = 0
    private(set) static var updateDivisor: Int = 0

    var isAlive: Bool {
        return hitPoints > 0
    }

    var tileAligned: Bool {
        return position.TileAligned
    }

    init(playerAsset: PlayerAssetType) {
        fatalError("You need to override this method.")
    }

    func setUpdateFrequency(frequency _: Int) {
        fatalError("You need to override this method.")
    }

    func maxHitPoints() -> Int {
        fatalError("You need to override this method.")
    }

    func incrementHitPoints(_ increments: Int) -> Int {
        hitPoints += increments
        hitPoints = min(hitPoints, maxHitPoints())
        return hitPoints
    }

    func decrementtHitPoints(_ decrements: Int) -> Int {
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

    func setTitlePosition(position _: Position) {
        fatalError("You need to override this method.")
    }

    func tilePositionX() -> Int {
        return tilePosition.x
    }

    func setTilePositionX(_: Int) {
        fatalError("You need to override this method.")
    }

    func tilePositionY() -> Int {
        return tilePosition.y
    }

    func setTilePositionY(_: Int) {
        fatalError("You need to override this method.")
    }

    func setPosition(position _: Position) {
        fatalError("You need to override this method.")
    }

    func positionX() -> Int {
        return position.x
    }

    func setPositionX(_: Int) {
        fatalError("You need to override this method.")
    }

    func positionY() -> Int {
        return position.y
    }

    func setPositionY(_: Int) {
        fatalError("You need to override this method.")
    }
}
