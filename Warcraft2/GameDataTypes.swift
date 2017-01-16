//
//  GameDataTypes.swift
//  Warcraft2
//
//  Created by Bryce Korte on 1/16/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

enum EPlayerColor: Int {
    case
        pcNone = 0,
        pcBlue,
        pcRed,
        pcGreen,
        pcPurple,
        pcOrange,
        pcYellow,
        pcBlack,
        pcWhite,
        pcMax
}

enum EAssetAction: Int {
    case
        aaNone = 0,
        aaConstruct,
        aaBuild,
        aaRepair,
        aaWalk,
        aaStandGround,
        aaAttack,
        aaHarvestLumber,
        aaMineGold,
        aaConveyLumber,
        aaConveyGold,
        aaDeath,
        aaDecay,
        aaCapability
}

enum EAssetCapabilityType: Int {
    case
        actNone = 0,
        actBuildPeasant,
        actBuildFootman,
        actBuildArcher,
        actBuildRanger,
        actBuildFarm,
        actBuildTownHall,
        actBuildBarracks,
        actBuildLumberMill,
        actBuildBlacksmith,
        actBuildKeep,
        actBuildCastle,
        actBuildScoutTower,
        actBuildGuardTower,
        actBuildCannonTower,
        actMove,
        actRepair,
        actMine,
        actBuildSimple,
        actBuildAdvanced,
        actConvey,
        actCancel,
        actBuildWall,
        actAttack,
        actStandGround,
        actPatrol,
        actWeaponUpgrade1,
        actWeaponUpgrade2,
        actWeaponUpgrade3,
        actArrowUpgrade1,
        actArrowUpgrade2,
        actArrowUpgrade3,
        actArmorUpgrade1,
        actArmorUpgrade2,
        actArmorUpgrade3,
        actLongbow,
        actRangerScouting,
        actMarksmanship,
        actMax
}

enum EAssetType: Int {
    case
        atNone = 0,
        atPeasant,
        atFootman,
        atArcher,
        atRanger,
        atGoldMine,
        atTownHall,
        atKeep,
        atCastle,
        atFarm,
        atBarracks,
        atLumberMill,
        atBlacksmith,
        atScoutTower,
        atGuardTower,
        atCannonTower,
        atMax
}

enum EDirection: Int {
    case
        dNorth = 0,
        dNorthEast,
        dEast,
        dSouthEast,
        dSouth,
        dSouthWest,
        dWest,
        dNorthWest,
        dMax

    static func DirectionOpposite(dir: EDirection) -> EDirection {
        let opDir = (dir.rawValue + EDirection.dMax.rawValue / 2) % EDirection.dMax.rawValue
        return EDirection(rawValue: opDir)!
    }
}
