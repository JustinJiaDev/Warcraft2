//
//  PlayerCommand.swift
//
//
//  Created by Bryce Korte on 1/23/17.
//
//

struct PlayerCommandRequest {
    var action: AssetCapabilityType
    var actors: [PlayerAsset]
    var targetColor: PlayerColor
    var targetType: AssetType
    var targetLocation: Position
}
