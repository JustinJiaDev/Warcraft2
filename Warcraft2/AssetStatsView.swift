import UIKit

class AssetStatsView: UIView {
    var asset: PlayerAsset?

    let icons: GraphicTileset
    let iconView = UIImageView()

    let name = UILabel()
    let health = UILabel()
    let armor = UILabel()
    let damage = UILabel()
    let range = UILabel()
    let sight = UILabel()
    let speed = UILabel()

    init(icons: GraphicTileset) {
        self.icons = icons // splitVerticalSpriteSheetToUIImages(from: url("img", "Icons.png"), numSprites: 179)

        super.init(frame: CGRect.zero)
        self.addSubview(iconView)
        self.addSubview(name)
        self.addSubview(health)
        self.addSubview(armor)
        self.addSubview(damage)
        self.addSubview(range)
        self.addSubview(sight)
        self.addSubview(speed)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setFrame(frame: CGRect) {
        self.frame = frame

        let iconWidth = CGFloat(self.frame.size.width) * 0.2
        iconView.frame = CGRect(x: 0, y: 0, width: iconWidth, height: iconWidth)

        name.frame = CGRect(x: 0, y: 0, width: self.frame.size.width /* - iconWidth */, height: 50)
        name.textAlignment = .center
        name.textColor = UIColor.white
        name.font = UIFont.systemFont(ofSize: 24)

        health.frame = CGRect(x: 0, y: 50, width: self.frame.width, height: 30)
        health.textAlignment = .center
        health.textColor = UIColor.white
        health.font = UIFont.systemFont(ofSize: 18)

        armor.frame = CGRect(x: 0, y: 80, width: self.frame.width, height: 30)
        armor.textAlignment = .center
        armor.textColor = UIColor.white
        armor.font = UIFont.systemFont(ofSize: 18)

        damage.frame = CGRect(x: 0, y: 110, width: self.frame.width, height: 30)
        damage.textAlignment = .center
        damage.textColor = UIColor.white
        damage.font = UIFont.systemFont(ofSize: 18)

        range.frame = CGRect(x: 0, y: 140, width: self.frame.width, height: 30)
        range.textAlignment = .center
        range.textColor = UIColor.white
        range.font = UIFont.systemFont(ofSize: 18)

        sight.frame = CGRect(x: 0, y: 170, width: self.frame.width, height: 30)
        sight.textAlignment = .center
        sight.textColor = UIColor.white
        sight.font = UIFont.systemFont(ofSize: 18)

        speed.frame = CGRect(x: 0, y: 200, width: self.frame.width, height: 30)
        speed.textAlignment = .center
        speed.textColor = UIColor.white
        speed.font = UIFont.systemFont(ofSize: 18)
    }

    override func layoutSubviews() {
        let nameToImageDictionary: [String: String] = [
            "Peasant": "peasant",
            "Peon": "peon",
            "Footman": "footman",
            "Grunt": "grunt",
            "Archer": "archer",
            "Axethrower": "axethrower",
            "Ranger": "ranger",
            "Berserker": "berserker",
            "Knight": "knight",
            "Ogre": "ogre",
            "Paladin": "paladin",
            "OgreMagi": "ogre-magi",
            "DemoSquad": "demo-squad",
            "Sapper": "sapper",
            "Mage": "mage",
            "DeathKnight": "death-knight",
            "Ballista": "ballista",
            "Catapult": "catapult",
            "HumanOilTanker": "human-oil-tanker",
            "OrcOilTanker": "orc-oil-tanker",
            "HumanTransport": "human-transport",
            "OrcTransport": "orc-transport",
            "HumanDestroyer": "human-destroyer",
            "OrcDestroyer": "orc-destroyer",
            "Battleship": "battleship",
            "Juggernaught": "juggernaught",
            "Submarine": "submarine",
            "Turtle": "turtle",
            "FlyingMachine": "flying-machine",
            "Zeppelin": "zeppelin",
            "Gryphon": "gryphon",
            "Dragon": "dragon",
            "Lothar": "lothar",
            "Gul'dan": "gul'dan",
            "Uther": "uther",
            "Zul'jin": "zul'jin",
            "Cho'gall": "cho'gall",
            "Daemon": "daemon",
            "ChickenFarm": "chicken-farm",
            "PigFarm": "pig-farm",
            "TownHall": "town-hall",
            "GreatHall": "great-hall",
            "HumanBarracks": "human-barracks",
            "OrcBarracks": "orc-barracks",
            "HumanLumberMill": "human-lumber-mill",
            "OrcLumberMill": "orc-lumber-mill",
            "HumanBlacksmith": "human-blacksmith",
            "OrcBlacksmith": "orc-blacksmith",
            "HumanShipyard": "human-shipyard",
            "OrcShipyard": "orc-shipyard",
            "HumanOilRefinery": "human-oil-refinery",
            "OrcOilRefinery": "orc-oil-refinery",
            "HumanFoundary": "human-foundary",
            "OrcFoundary": "orc-foundary",
            "HumanOilRig": "human-oil-rig",
            "OrcOilRig": "orc-oil-rig",
            "Stables": "stables",
            "OgreMound": "ogre-mound",
            "Inventor": "inventor",
            "Alchemist": "alchemist",
            "ScoutTower": "scout-tower",
            "WatchTower": "watch-tower",
            "Church": "church",
            "Altar": "altar",
            "MageTower": "mage-tower",
            "Temple": "temple",
            "Keep": "keep",
            "Stronghold": "stronghold",
            "Castle": "castle",
            "Fortress": "fortress",
            "Castle2": "castle-2",
            "Fortress2": "fortress-2",
            "Aviary": "aviary",
            "Roost": "roost",
            "GoldMine": "gold-mine",
            "HumanGuardTower": "human-guard-tower",
            "HumanCannonTower": "human-cannon-tower",
            "OrcGuardTower": "orc-guard-tower",
            "OrcCannonTower": "orc-cannon-tower",
            "Water": "water",
            "DarkPortal": "dark-portal",
            "OrcRunes": "orc-runes",
            "Runestone": "runestone",
            "HumanMove": "human-move",
            "OrcMove": "orc-move",
            "Repair": "repair",
            "Mine": "mine",
            "BuildSimple": "build-simple",
            "BuildAdvanced": "build-advanced",
            "HumanConvey": "human-convey",
            "OrcConvey": "orc-convey",
            "Cancel": "cancel",
            "HumanWall": "human-wall",
            "OrcWall": "orc-wall",
            "Slow": "slow",
            "Invisibility": "invisibility",
            "Haste": "haste",
            "Runes": "runes",
            "UnholyArmor": "unholy-armor",
            "Lightning": "lightning",
            "FlameShield": "flame-shield",
            "Fireball": "fireball",
            "TouchOfDarkness": "touch-of-darkness",
            "DeathAndDecay": "death-and-decay",
            "Whirlwind": "whirlwind",
            "Blizzard": "blizzard",
            "HolyVision": "holy-vision",
            "Healing": "healing",
            "DeathCoil": "death-coil",
            "Burn": "burn",
            "Exorcism": "exorcism",
            "EyeOfKilrogg": "eye-of-kilrogg",
            "Bloodlust": "bloodlust",
            "Bloodlust2": "bloodlust-2",
            "RaiseDead": "raise-dead",
            "Polymorph": "polymorph",
            "HumanWeapon1": "human-weapon-1",
            "HumanWeapon2": "human-weapon-2",
            "HumanWeapon3": "human-weapon-3",
            "OrcWeapon1": "orc-weapon-1",
            "OrcWeapon2": "orc-weapon-2",
            "OrcWeapon3": "orc-weapon-3",
            "BreedWolf1": "breed-wolf-1",
            "BreedWolf2": "breed-wolf-2",
            "HumanArrow1": "human-arrow-1",
            "HumanArrow2": "human-arrow-2",
            "HumanArrow3": "human-arrow-3",
            "OrcAxe1": "orc-axe-1",
            "OrcAxe2": "orc-axe-2",
            "OrcAxe3": "orc-axe-3",
            "BreedHorse1": "breed-horse-1",
            "BreedHorse2": "breed-horse-2",
            "Longbow": "longbow",
            "RangerScouting": "ranger-scouting",
            "Marksmanship": "marksmanship",
            "LighterAxe": "lighter-axe",
            "BeserkerScouting": "beserker-scouting",
            "Regeneration": "regeneration",
            "CatapultUpgrade1": "catapult-upgrade-1",
            "CatapultUpgrade2": "catapult-upgrade-2",
            "BallistaUpgrade1": "ballista-upgrade-1",
            "BallistaUpgrade2": "ballista-upgrade-2",
            "HumanDemolish": "human-demolish",
            "OrcDemolish": "orc-demolish",
            "HumanCannon1": "human-cannon-1",
            "HumanCannon2": "human-cannon-2",
            "HumanCannon3": "human-cannon-3",
            "OrcCannon1": "orc-cannon-1",
            "OrcCannon2": "orc-cannon-2",
            "OrcCannon3": "orc-cannon-3",
            "OrcAnchor": "orc-anchor",
            "OrcShipArmor1": "orc-ship-armor-1",
            "OrcShipArmor2": "orc-ship-armor-2",
            "HumanAnchor": "human-anchor",
            "HumanShipArmor1": "human-ship-armor-1",
            "HumanShipArmor2": "human-ship-armor-2",
            "OrcShipMove": "orc-ship-move",
            "HumanShipMove": "human-ship-move",
            "OrcShipConvey": "orc-ship-convey",
            "HumanShipConvey": "human-ship-convey",
            "Oil1": "oil-1",
            "Oil2": "oil-2",
            "HumanShipDeploy": "human-ship-deploy",
            "OrcShipDeploy": "orc-ship-deploy",
            "HumanArmor1": "human-armor-1",
            "HumanArmor2": "human-armor-2",
            "HumanArmor3": "human-armor-3",
            "OrcArmor1": "orc-armor-1",
            "OrcArmor2": "orc-armor-2",
            "OrcArmor3": "orc-armor-3",
            "HumanPatrol": "human-patrol",
            "OrcPatrol": "orc-patrol",
            "HumanStandGround": "human-stand-ground",
            "OrcStandGround": "orc-stand-ground",
            "HumanAttackGround": "human-attack-ground",
            "OrcAttackGround": "orc-attack-ground",
            "HumanShipPatrol": "human-ship-patrol",
            "OrcShipPatrol": "orc-ship-patrol",
            "Disabled": "disabled"
        ]

        if let playerAsset = asset {

            health.font = UIFont.systemFont(ofSize: 18)

            name.text = playerAsset.assetType.name
            health.text = "Health: " + String(playerAsset.hitPoints) + " / " + String(playerAsset.maxHitPoints)
            armor.text = "Armor: " + String(playerAsset.armor)
            damage.text = "Damage: " + String(playerAsset.piercingDamage / 2) + " - " + String(playerAsset.piercingDamage + playerAsset.basicDamage)
            range.text = "Range: " + String(playerAsset.range)
            sight.text = "Sight: " + String(playerAsset.sight)
            speed.text = "Speed: " + String(playerAsset.speed)

            for subview in self.subviews {
                subview.isHidden = false
            }

            if playerAsset.speed == 0 {
                armor.isHidden = true
                damage.isHidden = true
                range.isHidden = true
                sight.isHidden = true
                speed.isHidden = true
                health.font = UIFont.systemFont(ofSize: 12)
            }

            print(playerAsset.assetType.name)
            icons.drawTile(on: iconView, index: icons.findTile(nameToImageDictionary[name.text!]!)) // FIXME:

        } else {
            for subview in self.subviews {
                subview.isHidden = true
            }
        }
    }
}
