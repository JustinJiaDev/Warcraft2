import Foundation

class PlayerCapabilityMove: PlayerCapability {

    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityMove())
        }
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
        if actor.tilePosition != target.tilePosition {
            let newCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)) // did implement the last parameter correctly? fix it!
            actor.clearCommand()
            actor.pushCommand(newCommand)
            return true
        }
        return false
    }
}

class PlayerCapabilityMineHarvest: PlayerCapability {

    private class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityMove())
        }
    }

    class ActivateCapability: ActivatedPlayerCapability {

        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            var assetCommand: AssetCommand = AssetCommand(action: AssetAction.mineGold, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent: GameEvent = GameEvent(type: EventType.acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)

            if AssetType.goldMine == target.type {
                assetCommand.action = AssetAction.mineGold
            } else {
                assetCommand.action = AssetAction.harvestLumber
            }
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
        return actor.hasCapability(.mine)
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        if !actor.hasCapability(AssetCapabilityType.mine) {
            return false
        }
        if actor.lumber > 0 || actor.gold > 0 {
            return false
        }
        if target.type == .goldMine {
            return true
        }
        if target.type != AssetType.none {
            return false
        }
        
        return playerData.playerMap.tileTypeAt(position: target.tilePosition) == .tree
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let newCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)) // last argument need fix it?
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabityStandGround: PlayerCapability {

    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityMove())
        }
    }

    class ActivatedCapability: ActivatedPlayerCapability {

        func percentCompelte(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            var assetCommand: AssetCommand = AssetCommand(action: AssetAction.standGround, capability: nil, assetTarget: playerData.createMarker(at: actor.position, addToMap: false), activatedCapability: nil) // fix it? assetTarget?
            let tempEvent: GameEvent = GameEvent(type: EventType.acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)

            actor.clearCommand()
            actor.pushCommand(assetCommand)

            if !actor.tileAligned {
                assetCommand.action = AssetAction.walk
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
        let newCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)) // last argument got it right? fix it!
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityCancel: PlayerCapability {

    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityMove())
        }
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            actor.popCommand()

            if AssetAction.none != actor.action {
                var assetCommand: AssetCommand
                assetCommand = actor.currentCommand()

                if AssetAction.construct == assetCommand.action {
                    if assetCommand.assetTarget != nil {
                        assetCommand.assetTarget?.currentCommand().activatedCapability?.cancel()
                    } else if assetCommand.activatedCapability != nil {
                        assetCommand.activatedCapability?.cancel()
                    }
                } else if assetCommand.activatedCapability != nil {
                    assetCommand.activatedCapability?.cancel()
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
        let newCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)) // last argument got it right? or fix it?
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityConvey: PlayerCapability {
    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityMove())
        }
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            var assetCommand: AssetCommand = AssetCommand(action: AssetAction.conveyLumber, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent: GameEvent = GameEvent(type: EventType.acknowledge, asset: actor)
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
        // verify the logic of this line! fix it!
        return actor.speed > 0 && (actor.lumber > 0 || actor.gold > 0)
    }

    override func canApply(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        // verify the logic here! fix it!
        if actor.speed > 0 && (actor.lumber != 0 || actor.gold != 0) {
            if AssetAction.construct == target.action {
                return false
            }
            if AssetType.townHall == target.type || AssetType.keep == target.type || AssetType.castle == target.type {
                return true
            }
            if actor.lumber != 0 && (AssetType.lumberMill == target.type) {
                return true
            }
        }
        return false
    }

    override func applyCapability(actor: PlayerAsset, playerData: PlayerData, target: PlayerAsset) -> Bool {
        let newCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)) // fix it?
        actor.clearCommand()
        actor.pushCommand(newCommand)
        return true
    }
}

class PlayerCapabilityPatrol: PlayerCapability {
    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityMove())
        }
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            let patrolCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: AssetCapabilityType.patrol, assetTarget: playerData.createMarker(at: actor.position, addToMap: false), activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target)) // fix it or no?
            let walkCommand: AssetCommand = AssetCommand(action: AssetAction.walk, capability: nil, assetTarget: target, activatedCapability: nil) // third argument?
            let tempEvent: GameEvent = GameEvent(type: EventType.acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)
            actor.clearCommand()
            actor.pushCommand(patrolCommand)

            if !actor.tileAligned {
                // need verify this line! fix it!
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
        if actor.tilePosition != target.tilePosition {
            let newCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target))
            actor.clearCommand()
            actor.pushCommand(newCommand)
            return true
        }
        return false
    }
}

class PlayerCapabilityAttack: PlayerCapability {
    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityMove())
        }
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            var assetCommand: AssetCommand = AssetCommand(action: AssetAction.attack, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent: GameEvent = GameEvent(type: EventType.acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)
            actor.clearCommand()
            actor.pushCommand(assetCommand)

            assetCommand.action = AssetAction.walk
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite // fix it? is it right?
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
        if actor.tilePosition != target.tilePosition {
            let newCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target))
            actor.clearCommand()
            actor.pushCommand(newCommand)
            return true
        }
        return false
    }
}

class PlayerCapabilityRepair: PlayerCapability {
    class Registrant {
        init() {
            PlayerCapability.register(capability: PlayerCapabilityMove())
        }
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        override func incrementStep() -> Bool {
            var assetCommand: AssetCommand = AssetCommand(action: AssetAction.repair, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent: GameEvent = GameEvent(type: EventType.acknowledge, asset: actor)
            playerData.addGameEvent(tempEvent)
            actor.clearCommand()
            actor.pushCommand(assetCommand)

            assetCommand.action = AssetAction.walk
            if !actor.tileAligned {
                actor.direction = actor.position.tileOctant.opposite // fix it? is it right?
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
        if actor.tilePosition != target.tilePosition {
            let newCommand: AssetCommand = AssetCommand(action: AssetAction.capability, capability: assetCapabilityType, assetTarget: target, activatedCapability: ActivatedPlayerCapability(actor: actor, playerData: playerData, target: target))
            actor.clearCommand()
            actor.pushCommand(newCommand)
            return true
        }
        return false
    }
}
