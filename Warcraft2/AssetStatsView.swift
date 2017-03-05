import UIKit

class AssetStatsView: UIView {

    var assetType = UILabel()
    var assetIconView = UIImageView()
    var armor = UILabel()
    var damage = UILabel()
    var range = UILabel()
    var sight = UILabel()
    var speed = UILabel()

    override func layoutSubviews() {
        let icons = splitVerticalSpriteSheetToUIImages(from: url("img", "Icons.png"), numSprites: 179)
        let iconWidth = CGFloat(self.frame.size.width) * 0.3
        assetType = UILabel(frame: CGRect(x: iconWidth, y: 0, width: CGFloat(self.frame.size.width) - iconWidth, height: 50))
        assetType.text = "Peasant"
        assetType.textAlignment = .center
        assetType.textColor = UIColor.white

        assetIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconWidth))
        assetIconView.image = icons[0]

        armor = UILabel(frame: CGRect(x: 0, y: assetType.bounds.height, width: self.frame.width, height: 30))
        armor.text = "Armor: 0"
        armor.textAlignment = .center
        armor.textColor = UIColor.white
        damage = UILabel(frame: CGRect(x: 0, y: assetType.bounds.height + 30, width: self.frame.width, height: 30))
        damage.text = "Damage: 1-5"
        damage.textAlignment = .center
        damage.textColor = UIColor.white
        range = UILabel(frame: CGRect(x: 0, y: assetType.bounds.height + (30 * 2), width: self.frame.width, height: 30))
        range.text = "Range: 1"
        range.textAlignment = .center
        range.textColor = UIColor.white
        sight = UILabel(frame: CGRect(x: 0, y: assetType.bounds.height + (30 * 3), width: self.frame.width, height: 30))
        sight.text = "Sight: 4"
        sight.textAlignment = .center
        sight.textColor = UIColor.white
        speed = UILabel(frame: CGRect(x: 0, y: assetType.bounds.height + (30 * 4), width: self.frame.width, height: 30))
        speed.text = "Speed: 10"
        speed.textAlignment = .center
        speed.textColor = UIColor.white

        self.addSubview(assetType)
        self.addSubview(assetIconView)
        self.addSubview(armor)
        self.addSubview(damage)
        self.addSubview(range)
        self.addSubview(sight)
        self.addSubview(speed)
    }
}
