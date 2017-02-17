import Foundation

class PlayerCapabilityUnitUpgrade: PlayerCapability {
    class Registrant {
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
        }
    }

    private let registrant: Registrant
    
    private var upgradeName: String

    class ActivatedCapability: ActivatedPlayerCapability {
        private var upgradingType: PlayerAssetType
        private var upgradeName: String
        private var currentStep: Int
        private var totalSteps: Int
        private var lumber: Int
        private var gold: Int

        
        init(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset, upgradingType: PlayerAssetType, upgradeName: String, lumber: Int, gold: Int, steps: Int) {
            var assetCommand: AssetCommand

            self.upgradingType = upgradingType
            self.upgradeName = upgradeName
            self.currentStep = 0
            self.totalSteps = steps
            self.lumber = lumber
            self.gold = gold

            super.init(actor: actor, playerData: playerData, target: target)

            self.playerData.decrementLumber(by: self.lumber)
            self.playerData.decrementGold(by: self.gold)
            self.upgradingType.removeCapability(PlayerCapability.findType(with: self.upgradeName))
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        func incrementStep() -> Bool {
            currentStep += 1
            actor.incrementStep()

            if currentStep >= totalSteps {
                playerData.addUpgrade(with: self.upgradeName)
                actor.popCommand()

                let range = upgradeName.range(of: "2")!
                let index = upgradeName.distance(from: upgradeName.startIndex, to: range.lowerBound)
                
                if index == (upgradeName.characters.count - 1) {
                    let i = upgradeName.index(upgradeName.endIndex, offsetBy: 3)
                    upgradingType.addCapability(PlayerCapability.findType(with: upgradeName[i..<upgradeName.endIndex]))
                }

                return true
            }
            return false
        }

        override func cancel() {
            playerData.incrementLumber(by: lumber)
            playerData.incrementGold(by: gold)
            upgradingType.addCapability(PlayerCapability.findType(with: upgradeName))
            actor.popCommand()
        }
    }

    
    init(upgradeName: String) {
        super.init(name: upgradeName, targetType: TargetType.none)
        self.upgradeName = upgradeName
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        if let upgrade: PlayerUpgrade? = PlayerUpgrade.findUpgrade(with: upgradeName) {
            if upgrade!.lumberCost > playerData.lumber {
                return false
            }
            if upgrade!.goldCost > playerData.gold {
                return false
            }
        }
        return true
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return canInitiate(actor: actor, playerData: playerData)
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let upgrade: PlayerUpgrade? = PlayerUpgrade.findUpgrade(with: upgradeName)

        if upgrade != nil {
            let newCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target, upgradingType: actor.assetType, upgradeName: upgradeName, lumber: upgrade!.lumberCost, gold: upgrade!.goldCost, steps: upgrade!.researchTime))

//            actor.clearCommand()

            actor.pushCommand(newCommand)

            return true
        }
        return false
    }
}

class PlayerCapabilityBuildRanger: PlayerCapability {
    private class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityBuildRanger(unitName: "Ranger"))
        }
    }
    private let registrant: Registrant
    
    private var unitName: String

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

            self.playerData.decrementLumber(by: self.lumber)
            self.playerData.decrementGold(by: self.gold)

            if actor.type == .lumberMill {
                self.upgrandingType = upgradingType
                self.upgrandingType.removeCapability(PlayerCapability.findType(with: ("Build" + self.unitName)))

            } else if actor.type == .barracks  {
                var assetCommand: AssetCommand?

                assetCommand!.action = AssetAction.construct
                assetCommand!.assetTarget = actor
                target.pushCommand(assetCommand!)
            }
        }

        override func percentComplete(max: Int) -> Int {
            return currentStep * max / totalSteps
        }

        func incrementstep() -> Bool {
            if AssetType.barracks == actor.type {
                let addHitPoints = (target.maxHitPoints * (currentStep + 1) / totalSteps) - (target.maxHitPoints * currentStep / totalSteps)

                self.target.incrementHitPoints(addHitPoints)

                if target.hitPoints > target.maxHitPoints {
                    target.hitPoints = target.maxHitPoints
                }
            }

            currentStep += 1
            actor.incrementStep()

            if currentStep >= totalSteps {
                var tempEvent: GameEvent?

                if AssetType.lumberMill == actor.type {
                    let baracks = playerData.assetTypes["Barracks"]
                    let ranger = playerData.assetTypes["Ranger"]
                    let lumberMill = playerData.assetTypes["LumberMill"]

                    tempEvent!.type = EventType.workComplete
                    tempEvent!.asset = actor

                    baracks?.addCapability(AssetCapabilityType.buildRanger)
                    baracks?.removeCapability(AssetCapabilityType.buildRanger)
                    lumberMill?.addCapability(AssetCapabilityType.longbow)
                    lumberMill?.addCapability(AssetCapabilityType.rangerScouting)
                    lumberMill?.addCapability(AssetCapabilityType.marksmanship)

                    // Upgrade all Archers
                    for var asset in playerData.assets {
                        if AssetType.archer == asset.type {
                            let hitPointIncrement = ranger!.hitPoints - asset.maxHitPoints

                            asset.changeType(to: ranger!)
                            asset.incrementHitPoints(hitPointIncrement)
                        }
                    }
                } else if AssetType.barracks == actor.type {
                    tempEvent!.type = EventType.ready
                    tempEvent!.asset = target

                    target.popCommand()
                    target.tilePosition = playerData.playerMap.findAssetPlacement(placeAsset: target, fromAsset: actor, nextTileTarget: Position(x: playerData.playerMap.width - 1, y: playerData.playerMap.height - 1))
                }
                playerData.addGameEvent(tempEvent!)
                actor.popCommand()
                return true
            }

            return false
        }

        override func cancel() {
            playerData.incrementLumber(by: lumber)
            playerData.incrementGold(by: gold)

            if AssetType.lumberMill == actor.type {
                upgrandingType.addCapability(PlayerCapability.findType(with: "Build" + self.unitName))
            } else if AssetType.barracks == actor.type {
                playerData.deleteAsset(target)
            }
            actor.popCommand()
        }
    }

    init(unitName: String) {
        self.unitName = unitName
        super.init(name: "Build" + unitName, targetType: TargetType.none)
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        if AssetType.lumberMill == actor.type {
            let upgrade: PlayerUpgrade? = PlayerUpgrade.findUpgrade(with: ("Build" + unitName))

            if upgrade != nil {
                if upgrade!.lumberCost > playerData.lumber {
                    return false
                }
                if upgrade!.goldCost > playerData.gold {
                    return false
                }
                if playerData.assetRequirementsIsMet(name: unitName) != false {
                    return false
                }
            }
        } else if AssetType.barracks == actor.type {
            if let assetType = playerData.assetTypes[unitName] {
                if assetType.lumberCost > playerData.lumber {
                    return false
                }
                if assetType.goldCost > playerData.gold {
                    return false
                }
                if (assetType.foodConsumption + playerData.foodConsumption) > playerData.foodProduction {
                    return false
                }
            }
        }
        return true
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return canInitiate(actor: actor, playerData: playerData)
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        if AssetType.lumberMill == actor.type {
            if let upgrade: PlayerUpgrade? = PlayerUpgrade.findUpgrade(with: "Build" + unitName) {
                var newCommand: AssetCommand?

                actor.clearCommand()
                newCommand!.action = AssetAction.capability
                newCommand!.capability = assetCapabilityType
                newCommand!.assetTarget = target
                newCommand!.activatedCapability = ActivatedCapability(actor: actor, playerData: playerData, target: target, upgradingType: actor.assetType, unitName: unitName, lumber: (upgrade?.lumberCost)!, gold: (upgrade?.goldCost)!, steps: (upgrade?.researchTime)!)
                actor.pushCommand(newCommand!)

                return true
            }
        } else if AssetType.barracks == actor.type {
            if let assetType = playerData.assetTypes[unitName] {
                let newAsset = playerData.createAsset(with: unitName)

                var newCommand: AssetCommand?
                let tilePosition: Position? = nil

                tilePosition!.setToTile(actor.position)
                newAsset.tilePosition = tilePosition!
                newAsset.hitPoints = 1

                newCommand!.action = AssetAction.capability
                newCommand!.capability = assetCapabilityType
                newCommand!.assetTarget = newAsset
                newCommand!.activatedCapability = ActivatedCapability(actor: actor, playerData: playerData, target: newAsset, upgradingType: actor.assetType, unitName: unitName, lumber: assetType.lumberCost, gold: assetType.goldCost, steps: assetType.buildTime)
                actor.pushCommand(newCommand!)
            }
        }
        return false
    }
}
