//
//  PlayerCommand.swift
//  Warcraft2
//
//  Created by Bryce Korte on 1/23/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

struct PlayerCommandRequest {
    var action: AssetCapabilityType
    var actors: [PlayerAsset]
    var targetColor: PlayerColor
    var targetType: AssetType
    var targetLocation: Position
}
