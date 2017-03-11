import UIKit

class StatsView: UIView {
    var asset: PlayerAsset?

    let iconName: [String: String] = [
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

    let icons: GraphicTileset

    let iconImageView = UIImageView()
    let nameLabel = UILabel()
    let healthLabel = UILabel()
    let armorLabel = UILabel()
    let damageLabel = UILabel()
    let rangeLabel = UILabel()
    let sightLabel = UILabel()
    let speedLabel = UILabel()

    init(icons: GraphicTileset) {
        self.icons = icons
        super.init(frame: .zero)
        backgroundColor = .black
        self.addSubview(iconImageView)
        self.addSubview(nameLabel)
        self.addSubview(healthLabel)
        self.addSubview(armorLabel)
        self.addSubview(damageLabel)
        self.addSubview(rangeLabel)
        self.addSubview(sightLabel)
        self.addSubview(speedLabel)
        for subview in subviews where subview is UILabel {
            let label = subview as! UILabel
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont(name: "Papyrus", size: 16)
        }
    }

    override init(frame: CGRect) {
        fatalError("View can't be initialized using this method.")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("View can't be initialized using this method.")
    }

    override func layoutSubviews() {
        iconImageView.frame = CGRect(x: 8, y: 8, width: icons.tileWidth, height: icons.tileHeight)
        nameLabel.frame = CGRect(x: Int(iconImageView.frame.maxX), y: 12, width: bounds.width - icons.tileWidth - 16, height: icons.tileHeight)
        healthLabel.frame = CGRect(x: 8, y: 50, width: bounds.width - 16, height: 30)
        armorLabel.frame = CGRect(x: 8, y: 80, width: bounds.width - 16, height: 30)
        damageLabel.frame = CGRect(x: 8, y: 110, width: bounds.width - 16, height: 30)
        rangeLabel.frame = CGRect(x: 8, y: 140, width: bounds.width - 16, height: 30)
        sightLabel.frame = CGRect(x: 8, y: 170, width: bounds.width - 16, height: 30)
        speedLabel.frame = CGRect(x: 8, y: 200, width: bounds.width - 16, height: 30)
    }

    func displayAssetInfo(_ asset: PlayerAsset?) {
        for subview in subviews {
            subview.isHidden = asset == nil
        }

        guard let asset = asset else {
            return
        }

        nameLabel.text = asset.assetType.name
        healthLabel.text = "Health: \(asset.hitPoints) / \(asset.maxHitPoints)"
        armorLabel.text = "Armor: \(asset.armor)"
        damageLabel.text = "Damage: \(asset.piercingDamage / 2) - \(asset.piercingDamage + asset.basicDamage)"
        rangeLabel.text = "Range: \(asset.range)"
        sightLabel.text = "Sight: \(asset.sight)"
        speedLabel.text = "Speed: \(asset.speed)"

        if asset.speed == 0 {
            armorLabel.isHidden = true
            damageLabel.isHidden = true
            rangeLabel.isHidden = true
            sightLabel.isHidden = true
            speedLabel.isHidden = true
            healthLabel.adjustsFontSizeToFitWidth = true
        }

        icons.drawTile(on: iconImageView, index: icons.findTile(iconName[asset.assetType.name]!))
    }
}
