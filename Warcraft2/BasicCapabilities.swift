struct BasicCapabilities {
    static let registrant = BasicCapabilities()

    init() {
        PlayerCapability.register(capability: PlayerCapabilityMove())
        PlayerCapability.register(capability: PlayerCapabilityMineHarvest())
        PlayerCapability.register(capability: PlayerCapabityStandGround())
        PlayerCapability.register(capability: PlayerCapabilityCancel())
        PlayerCapability.register(capability: PlayerCapabilityConvey())
        PlayerCapability.register(capability: PlayerCapabilityPatrol())
        PlayerCapability.register(capability: PlayerCapabilityAttack())
        PlayerCapability.register(capability: PlayerCapabilityRepair())
    }

    func register() {}
}

class PlayerCapabilityMove: PlayerCapability {

    init() {
        super.init(name: "Move", targetType: .terrainOrAsset)
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            playerData.addGameEvent(GameEvent(type: .acknowledge, asset: actor))
            actor.clearCommand()
            actor.pushCommand(AssetCommand(action: .walk, capability: nil, assetTarget: target, activatedCapability: nil))
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            return true
        }

        override func cancel() {
            actor.popCommand()
        }
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        return actor.speed > 0
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return actor.speed > 0
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor.tilePosition != target.tilePosition else {
            return false
        }
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityMineHarvest: PlayerCapability {

    init() {
        super.init(name: "Mine", targetType: .terrainOrAsset)
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            let action: AssetAction = target.type == .goldMine ? .mineGold : .harvestLumber

            playerData.addGameEvent(GameEvent(type: .acknowledge, asset: actor))
            actor.clearCommand()
            actor.pushCommand(AssetCommand(action: action, capability: nil, assetTarget: target, activatedCapability: nil))
            actor.pushCommand(AssetCommand(action: .walk, capability: nil, assetTarget: target, activatedCapability: nil))
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            return true
        }

        override func cancel() {
            actor.popCommand()
        }
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        return actor.hasCapability(.mine)
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor.hasCapability(.mine) else {
            return false
        }
        guard actor.lumber == 0 && actor.gold == 0 else {
            return false
        }

        if target.type == .goldMine {
            return true
        } else if target.type == .none && playerData.playerMap.tileTypeAt(position: target.tilePosition) == .tree {
            return true
        } else {
            return false
        }
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabityStandGround: PlayerCapability {

    init() {
        super.init(name: "StandGround", targetType: .none)
    }

    class ActivatedCapability: ActivatedPlayerCapability {

        func percentCompelte(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            playerData.addGameEvent(GameEvent(type: .acknowledge, asset: actor))

            let target = playerData.createMarker(at: actor.position, addToMap: false)
            actor.clearCommand()
            actor.pushCommand(AssetCommand(action: .standGround, capability: nil, assetTarget: target, activatedCapability: nil))

            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
                actor.pushCommand(AssetCommand(action: .walk, capability: nil, assetTarget: target, activatedCapability: nil))
            }
            return true
        }

        override func cancel() {
            actor.popCommand()
        }
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        return true
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return true
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityCancel: PlayerCapability {

    init() {
        super.init(name: "Cancel", targetType: .none)
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            actor.popCommand()
            if actor.action != .none {
                let assetCommand = actor.currentCommand
                if assetCommand.action == .construct {
                    if let targetActivatedCapability = assetCommand.assetTarget?.currentCommand.activatedCapability {
                        targetActivatedCapability.cancel()
                    } else if let activatedCapability = assetCommand.activatedCapability {
                        activatedCapability.cancel()
                    }
                } else if let activatedCapability = assetCommand.activatedCapability {
                    activatedCapability.cancel()
                }
            }
            return true
        }

        override func cancel() {
            actor.popCommand()
        }
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        return true
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return true
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityConvey: PlayerCapability {

    init() {
        super.init(name: "Convey", targetType: .asset)
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            playerData.addGameEvent(GameEvent(type: EventType.acknowledge, asset: actor))

            actor.popCommand()
            if actor.lumber > 0 {
                actor.pushCommand(AssetCommand(action: .conveyLumber, capability: nil, assetTarget: target, activatedCapability: nil))
                actor.pushCommand(AssetCommand(action: .walk, capability: nil, assetTarget: target, activatedCapability: nil))
                actor.resetStep()
            } else if actor.gold > 0 {
                actor.pushCommand(AssetCommand(action: .conveyGold, capability: nil, assetTarget: target, activatedCapability: nil))
                actor.pushCommand(AssetCommand(action: .walk, capability: nil, assetTarget: target, activatedCapability: nil))
                actor.resetStep()
            }
            return true
        }

        override func cancel() {
            actor.popCommand()
        }
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        return actor.speed > 0 && (actor.lumber > 0 || actor.gold > 0)
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor.speed > 0 else {
            return false
        }
        guard actor.lumber > 0 || actor.gold > 0 else {
            return false
        }
        guard target.action != .construct else {
            return false
        }
        if target.type == .townHall || target.type == .keep || target.type == .castle {
            return true
        } else if target.type == .lumberMill && actor.lumber > 0 {
            return true
        } else {
            return false
        }
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityPatrol: PlayerCapability {

    init() {
        super.init(name: "Patrol", targetType: .terrain)
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            playerData.addGameEvent(GameEvent(type: .acknowledge, asset: actor))
            let patrolCommand = AssetCommand(
                action: .capability,
                capability: .patrol,
                assetTarget: playerData.createMarker(at: actor.position, addToMap: false),
                activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
            )
            let walkCommand = AssetCommand(action: AssetAction.walk, capability: nil, assetTarget: target, activatedCapability: nil)
            actor.clearCommand()
            actor.pushCommand(patrolCommand)
            actor.pushCommand(walkCommand)
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            return true
        }

        override func cancel() {
            actor.popCommand()
        }
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        return actor.speed > 0
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        return actor.speed > 0
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor.tilePosition != target.tilePosition else {
            return false
        }
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityAttack: PlayerCapability {

    init() {
        super.init(name: "Attack", targetType: .asset)
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            playerData.addGameEvent(GameEvent(type: .acknowledge, asset: actor))
            actor.clearCommand()
            actor.pushCommand(AssetCommand(action: .attack, capability: nil, assetTarget: target, activatedCapability: nil))
            actor.pushCommand(AssetCommand(action: .walk, capability: nil, assetTarget: target, activatedCapability: nil))
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            return true
        }

        override func cancel() {
            actor.popCommand()
        }
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        return actor.speed > 0
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor.color != target.color && target.color != .none else {
            return false
        }
        return actor.speed > 0
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor.tilePosition != target.tilePosition else {
            return false
        }
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityRepair: PlayerCapability {

    init() {
        super.init(name: "Repair", targetType: .asset)
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            playerData.addGameEvent(GameEvent(type: .acknowledge, asset: actor))
            actor.clearCommand()
            actor.pushCommand(AssetCommand(action: .repair, capability: nil, assetTarget: target, activatedCapability: nil))
            actor.pushCommand(AssetCommand(action: .walk, capability: nil, assetTarget: target, activatedCapability: nil))
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            return true
        }

        override func cancel() {
            actor.popCommand()
        }
    }

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool {
        return actor.speed > 0 && playerData.gold > 0 && playerData.lumber > 0
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor.color == target.color && target.speed > 0 else {
            return false
        }
        guard target.hitPoints < target.maxHitPoints else {
            return false
        }
        return canInitiate(actor: actor, playerData: playerData)
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        guard actor.tilePosition != target.tilePosition else {
            return false
        }
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}
