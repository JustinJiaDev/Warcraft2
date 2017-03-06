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
            let assetCommand = AssetCommand(action: .walk, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent = GameEvent(type: .acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            actor.clearCommand()
            actor.pushCommand(assetCommand)
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
            var assetCommand = AssetCommand(action: .mineGold, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent = GameEvent(type: .acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)

            if target.type == .goldMine {
                assetCommand.action = .mineGold
            } else {
                assetCommand.action = .harvestLumber
            }
            actor.clearCommand()
            actor.pushCommand(assetCommand)
            assetCommand.action = .walk
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            actor.pushCommand(assetCommand)
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
        if !actor.hasCapability(.mine) {
            return false
        }
        if actor.lumber > 0 || actor.gold > 0 {
            return false
        }
        if target.type == .goldMine {
            return true
        }
        if target.type != .none {
            return false
        }
        return playerData.playerMap.tileTypeAt(position: target.tilePosition) == .tree
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        actor.clearCommand()
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
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
            var assetCommand = AssetCommand(action: .standGround, capability: nil, assetTarget: playerData.createMarker(at: actor.position, addToMap: false), activatedCapability: nil)
            let tempEvent = GameEvent(type: .acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)

            actor.clearCommand()
            actor.pushCommand(assetCommand)

            if !actor.tileAligned {
                assetCommand.action = .walk
                actor.direction = actor.position.tileOctant.opposite
                actor.pushCommand(assetCommand)
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
        actor.clearCommand()
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
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
        actor.clearCommand()
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
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
            var assetCommand = AssetCommand(action: .conveyLumber, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent = GameEvent(type: EventType.acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)

            actor.popCommand()
            if actor.lumber > 0 {
                actor.pushCommand(assetCommand)
                assetCommand.action = AssetAction.walk
                actor.pushCommand(assetCommand)
                actor.resetStep()
            } else if actor.gold > 0 {
                assetCommand.action = AssetAction.conveyGold
                assetCommand.assetTarget = target
                actor.pushCommand(assetCommand)
                assetCommand.action = AssetAction.walk
                actor.pushCommand(assetCommand)
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
        if actor.speed > 0 && (actor.lumber > 0 || actor.gold > 0) {
            if AssetAction.construct == target.action {
                return false
            }
            if target.type == .townHall || target.type == .keep || target.type == .castle {
                return true
            }
            if actor.lumber > 0 && (target.type == .lumberMill) {
                return true
            }
        }
        return false
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        actor.clearCommand()
        let newCommand = AssetCommand(
            action: .capability,
            capability: assetCapabilityType,
            assetTarget: target,
            activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target)
        )
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
            let patrolCommand = AssetCommand(action: .capability, capability: AssetCapabilityType.patrol, assetTarget: playerData.createMarker(at: actor.position, addToMap: false), activatedCapability: ActivatedCapability(actor: actor, playerData: playerData, target: target))
            let walkCommand = AssetCommand(action: AssetAction.walk, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent = GameEvent(type: .acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)
            actor.clearCommand()
            actor.pushCommand(patrolCommand)

            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            actor.pushCommand(walkCommand)
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
            var assetCommand = AssetCommand(action: .attack, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent = GameEvent(type: .acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)
            actor.clearCommand()
            actor.pushCommand(assetCommand)

            assetCommand.action = AssetAction.walk
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            actor.pushCommand(assetCommand)
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
        if actor.color == target.color || PlayerColor.none == target.color {
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
            var assetCommand = AssetCommand(action: .repair, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent = GameEvent(type: .acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)
            actor.clearCommand()
            actor.pushCommand(assetCommand)

            assetCommand.action = AssetAction.walk
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite
            }
            actor.pushCommand(assetCommand)
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
        if actor.color != target.color || target.speed == 0 {
            return false
        }

        if target.hitPoints >= target.maxHitPoints {
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
