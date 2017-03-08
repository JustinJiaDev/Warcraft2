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

        name.frame = CGRect(x: iconWidth, y: 0, width: self.frame.size.width - iconWidth, height: 50)
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
        if let playerAsset = asset {
            for subview in self.subviews {
                subview.isHidden = false
            }
            icons.drawTile(on: iconView, index: icons.findTile("peasant")) // FIXME

            name.text = playerAsset.assetType.name
            health.text = "Health: " + String(playerAsset.hitPoints) + " / " + String(playerAsset.maxHitPoints)
            armor.text = "Armor: " + String(playerAsset.armor)
            damage.text = "Damage: " + String(playerAsset.piercingDamage / 2) + " - " + String(playerAsset.piercingDamage + playerAsset.basicDamage)
            range.text = "Range: " + String(playerAsset.range)
            sight.text = "Sight: " + String(playerAsset.sight)
            speed.text = "Speed: " + String(playerAsset.speed)
        } else {
            for subview in self.subviews {
                subview.isHidden = true
            }
        }
    }
}
