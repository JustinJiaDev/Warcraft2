import Foundation

class PlayerCapabilityMove: PlayerCapability { // PlayerCapability need to be implemented.

    class Registrant {
        init() {}
    }

    class ActivatedCapability: ActivatedPlayerCapability { // ActivatedPlayerCapability

        override func percentComplete(max: Int) -> Int {
            return 0
        }

        func incrementStep() -> Bool {
            let assetCommand: AssetCommand = AssetCommand(action: AssetAction.walk, capability: nil, assetTarget: target, activatedCapability: nil)
            let tempEvent: GameEvent = GameEvent(type: EventType.acknowledge, asset: actor)
            // need fix it?
            playerData.addGameEvent(tempEvent)
            playerData.addGameEvent(tempEvent) // re-check if I did this line correctly!

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

    override func canInitiate(actor: PlayerAsset, playerData: PlayerData) -> Bool { // PlayerAsset
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
    }

    class ActivateCapability: ActivatedPlayerCapability {

        override func percentComplete(max: Int) -> Int {
            return 0
        }

        func incrementStep() -> Bool {
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
        return actor.hasCapability(AssetCapabilityType.mine) // re-check this line again
    }

    func canApply(actor: PlayerAsset, playerdata: PlayerData, target: PlayerAsset) -> Bool {
        if !actor.hasCapability(AssetCapabilityType.mine) {
            return false
        }
        if actor.lumber != 0 || actor.gold != 0 {
            return false
        }
        if AssetType.goldMine == target.type {
            return true
        }
        if AssetType.none != target.type {
            return false
        }

        // fix the line beneath! re-check it!
        return TerrainMap.TileType.tree == playerdata.playerMap.tileTypeAt(position: target.tilePosition)
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
    }

    class ActivatedCapability: ActivatedPlayerCapability {

        func percentCompelte(max: Int) -> Int {
            return 0
        }

        func incrementStep() -> Bool {
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
    }

    class ActivatedCapability: ActivatedPlayerCapability {
        override func percentComplete(max: Int) -> Int {
            return 0
        }

        func incrementStep() -> Bool {
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
