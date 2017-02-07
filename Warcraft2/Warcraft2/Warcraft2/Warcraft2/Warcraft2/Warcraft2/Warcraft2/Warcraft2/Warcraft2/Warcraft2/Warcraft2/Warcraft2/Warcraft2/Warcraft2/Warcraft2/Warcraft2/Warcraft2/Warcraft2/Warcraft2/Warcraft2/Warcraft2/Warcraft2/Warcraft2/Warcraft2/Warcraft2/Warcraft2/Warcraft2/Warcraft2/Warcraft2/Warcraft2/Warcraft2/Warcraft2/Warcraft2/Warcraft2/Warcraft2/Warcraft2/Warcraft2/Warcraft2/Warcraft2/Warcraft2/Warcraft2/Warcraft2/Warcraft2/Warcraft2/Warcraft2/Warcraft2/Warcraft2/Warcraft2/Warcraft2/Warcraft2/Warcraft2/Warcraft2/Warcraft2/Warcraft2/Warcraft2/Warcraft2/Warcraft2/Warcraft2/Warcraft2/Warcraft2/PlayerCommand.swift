struct PlayerCommandRequest {
    var action: AssetCapabilityType
    var actors: [PlayerAsset]
    var targetColor: PlayerColor
    var targetType: AssetType
    var targetLocation: Position
}
