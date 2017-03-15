struct UnitUpgradeCapabilities {
    static let registrant = UnitUpgradeCapabilities()

    init() {
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "WeaponUpgrade2"))
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "WeaponUpgrade3"))
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "ArmorUpgrade2"))
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "ArmorUpgrade3"))
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "ArrowUpgrade2"))
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "ArrowUpgrade3"))
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "Longbow"))
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "RangerScouting"))
        PlayerCapability.register(capability: PlayerCapabilityUnitUpgrade(upgradeName: "Marksmanship"))
        PlayerCapability.register(capability: PlayerCapabilityBuildRanger(unitName: "Ranger"))
    }

    func register() {}
}

class PlayerCapabilityUnitUpgrade: PlayerCapability {
    class ActivatedCapability: ActivatedPlayerCapability {
        private var upgradingType: PlayerAssetType
        private var upgradeName: String
        private(set) var currentStep: Int
        private(set) var totalSteps: Int
        private var lumber: Int
        private var gold: Int

        init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset, upgradingType: PlayerAssetType, upgradeName: String, lumber: Int, gold: Int, steps: Int) {
            self.upgradingType = upgradingType
            self.upgradeName = upgradeName
            self.currentStep = 0
            self.totalSteps = steps
            self.lumber = lumber
            self.gold = gold
            super.init(actor: actor, playerData: playerData, target: target)
            self.playerData.decrementLumber(by: lumber)
            self.playerData.decrementGold(by: gold)
            self.upgradingType.removeCapability(PlayerCapability.findType(upgradeName))
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        override func incrementStep() -> Bool {
            currentStep += 1
            actor.incrementStep()

            guard currentStep >= totalSteps else {
                return false
            }
            playerData.addUpgrade(upgradeName)
            actor.popCommand()
            if upgradeName.hasSuffix("2") {
                upgradingType.addCapability(PlayerCapability.findType(upgradeName.replacingOccurrences(of: "2", with: "3")))
            }
            return true
        }

        override func cancel() {
            playerData.incrementLumber(by: lumber)
            playerData.incrementGold(by: gold)
            upgradingType.addCapability(PlayerCapability.findType(upgradeName))
            actor.popCommand()
        }
    }

    private var upgradeName: String

    init(upgradeName: String) {
        self.upgradeName = upgradeName
        super.init(name: upgradeName, targetType: .none)
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        guard let upgrade = PlayerUpgrade.findUpgrade(upgradeName) else {
            return false
        }
        guard upgrade.lumberCost <= playerData.lumber else {
            return false
        }
        guard upgrade.goldCost <= playerData.gold else {
            return false
        }
        return true
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return canInitiate(actor: actor, playerData: playerData)
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard let upgrade = PlayerUpgrade.findUpgrade(upgradeName) else {
            return false
        }
        actor.clearCommand()
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(
                actor: actor,
                playerData: playerData,
                target: target,
                upgradingType: actor.assetType,
                upgradeName: upgradeName,
                lumber: upgrade.lumberCost,
                gold: upgrade.goldCost,
                steps: upgrade.researchTime * PlayerAsset.updateFrequency
            )
        )
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityBuildRanger: PlayerCapability {

    class ActivatedCapability: ActivatedPlayerCapability {
        private var upgrandingType: PlayerAssetType
        private var unitName: String
        private var currentStep: Int
        private var totalSteps: Int
        private var lumber: Int
        private var gold: Int

        init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset, upgradingType: PlayerAssetType, unitName: String, lumber: Int, gold: Int, steps: Int) {
            self.unitName = unitName
            self.currentStep = 0
            self.totalSteps = steps
            self.lumber = lumber
            self.gold = gold
            self.upgrandingType = upgradingType
            super.init(actor: actor, playerData: playerData, target: target)
            self.playerData.decrementLumber(by: lumber)
            self.playerData.decrementGold(by: gold)
            if actor.type == .lumberMill {
                self.upgrandingType = upgradingType
                self.upgrandingType.removeCapability(PlayerCapability.findType(("Build" + self.unitName)))
            } else if actor.type == .barracks {
                target.pushCommand(AssetCommand(action: .construct, capability: nil, assetTarget: actor, activatedCapability: nil))
            }
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        override func incrementStep() -> Bool {
            if actor.type == .barracks {
                target.incrementHitPoints((target.maxHitPoints * (currentStep + 1) / totalSteps) - (target.maxHitPoints * currentStep / totalSteps))
            }

            currentStep += 1
            actor.incrementStep()

            guard currentStep >= totalSteps else {
                return false
            }

            if actor.type == .lumberMill {
                let baracks = playerData.assetTypes["Barracks"]!
                let ranger = playerData.assetTypes["Ranger"]!
                let lumberMill = playerData.assetTypes["LumberMill"]!

                baracks.addCapability(AssetCapabilityType.buildRanger)
                baracks.removeCapability(AssetCapabilityType.buildArcher)
                lumberMill.addCapability(AssetCapabilityType.longbow)
                lumberMill.addCapability(AssetCapabilityType.rangerScouting)
                lumberMill.addCapability(AssetCapabilityType.marksmanship)

                // Upgrade all Archers
                for asset in playerData.assets where asset.type == .archer {
                    asset.changeType(to: ranger)
                    asset.incrementHitPoints(ranger.hitPoints - asset.maxHitPoints)
                }
                playerData.addGameEvent(GameEvent(type: .workComplete, asset: actor))
            } else if actor.type == .barracks {
                target.popCommand()
                target.tilePosition = playerData.playerMap.findAssetPlacement(
                    placeAsset: target,
                    fromAsset: actor,
                    nextTileTarget: Position(x: playerData.playerMap.width - 1, y: playerData.playerMap.height - 1)
                )
                playerData.addGameEvent(GameEvent(type: .ready, asset: target))
            }
            actor.popCommand()
            return true
        }

        override func cancel() {
            playerData.incrementLumber(by: lumber)
            playerData.incrementGold(by: gold)
            if actor.type == .lumberMill {
                upgrandingType.addCapability(PlayerCapability.findType("Build" + unitName))
            } else if actor.type == .barracks {
                playerData.deleteAsset(target)
            }
            actor.popCommand()
        }
    }

    private var unitName: String

    init(unitName: String) {
        self.unitName = unitName
        super.init(name: "Build" + unitName, targetType: TargetType.none)
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        if actor.type == .lumberMill {
            guard let upgrade = PlayerUpgrade.findUpgrade(("Build" + unitName)) else {
                return false
            }
            guard upgrade.lumberCost <= playerData.lumber else {
                return false
            }
            guard upgrade.goldCost <= playerData.gold else {
                return false
            }
            guard playerData.assetRequirementsIsMet(name: unitName) else {
                return false
            }
            return true
        } else if actor.type == .barracks {
            guard let assetType = playerData.assetTypes[unitName] else {
                return false
            }
            guard assetType.lumberCost <= playerData.lumber else {
                return false
            }
            guard assetType.goldCost <= playerData.gold else {
                return false
            }
            guard assetType.foodConsumption + playerData.foodConsumption <= playerData.foodProduction else {
                return false
            }
            return true
        } else {
            return false
        }
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return canInitiate(actor: actor, playerData: playerData)
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        if actor.type == .lumberMill {
            guard let upgrade = PlayerUpgrade.findUpgrade("Build" + unitName) else {
                return false
            }
            actor.clearCommand()
            let newCommand = AssetCommand(
                action: .capability,
                capability: assetCapabilityType,
                assetTarget: target,
                activatedCapability: ActivatedCapability(
                    actor: actor,
                    playerData: playerData,
                    target: target,
                    upgradingType: actor.assetType,
                    unitName: unitName,
                    lumber: upgrade.lumberCost,
                    gold: upgrade.goldCost,
                    steps: upgrade.researchTime
                )
            )
            actor.pushCommand(newCommand)
            return true
        } else if actor.type == .barracks {
            guard let assetType = playerData.assetTypes[unitName] else {
                return false
            }
            let newAsset = playerData.createAsset(unitName)
            newAsset.tilePosition = Position.tile(fromAbsolute: actor.position)
            newAsset.hitPoints = 1
            let newCommand = AssetCommand(
                action: .capability,
                capability: assetCapabilityType,
                assetTarget: newAsset,
                activatedCapability: ActivatedCapability(
                    actor: actor,
                    playerData: playerData,
                    target: newAsset,
                    upgradingType: actor.assetType,
                    unitName: unitName,
                    lumber: assetType.lumberCost,
                    gold: assetType.goldCost,
                    steps: assetType.buildTime
                )
            )
            actor.pushCommand(newCommand)
            return true
        } else {
            return false
        }
    }
}
