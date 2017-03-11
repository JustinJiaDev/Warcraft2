import UIKit

class ResourceView: UIView {

    private let icons: GraphicTileset
    private var playerData: PlayerData
    private var lastGoldDisplay = 0
    private var lastLumberDisplay = 0

    var goldImageView = UIImageView()
    var lumberImageView = UIImageView()
    var foodImageView = UIImageView()
    var goldLabel = UILabel()
    var lumberLabel = UILabel()
    var foodLabel = UILabel()

    init(icons: GraphicTileset, playerData: PlayerData) {
        self.icons = icons
        self.playerData = playerData
        super.init(frame: .zero)
        backgroundColor = .black
        addSubview(goldImageView)
        addSubview(goldLabel)
        addSubview(lumberImageView)
        addSubview(lumberLabel)
        addSubview(foodImageView)
        addSubview(foodLabel)
        icons.drawTile(on: goldImageView, index: 0)
        icons.drawTile(on: lumberImageView, index: 1)
        icons.drawTile(on: foodImageView, index: 2)
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
        let iconLength = max(icons.tileWidth, icons.tileHeight)
        goldImageView.frame = CGRect(x: 0, y: 8, width: iconLength, height: iconLength)
        lumberImageView.frame = CGRect(x: bounds.width / 3, y: 8, width: iconLength, height: iconLength)
        foodImageView.frame = CGRect(x: (self.frame.width / 3) * 2, y: 8, width: iconLength, height: iconLength)
        goldLabel.frame = CGRect(x: iconLength + 4, y: 10, width: bounds.width / 3 - iconLength, height: iconLength)
        lumberLabel.frame = CGRect(x: bounds.width / 3 + iconLength + 4, y: 10, width: bounds.width / 3 - iconLength, height: iconLength)
        foodLabel.frame = CGRect(x: (bounds.width / 3) * 2 + iconLength + 4, y: 10, width: bounds.width / 3 - iconLength, height: iconLength)
    }

    func updateResourceInfo() {
        // animate gold update
        let deltaGold = (playerData.gold - lastGoldDisplay) / 5
        lastGoldDisplay = (-3 ... 3).contains(deltaGold) ? playerData.gold : lastGoldDisplay + deltaGold
        goldLabel.text = String(lastGoldDisplay)

        // animate lumber update
        let deltaLumber = (playerData.lumber - lastLumberDisplay) / 5
        lastLumberDisplay = (-3 ... 3).contains(deltaLumber) ? playerData.lumber : lastLumberDisplay + deltaLumber
        lumberLabel.text = String(lastLumberDisplay)

        // display food
        if playerData.foodConsumption > playerData.foodProduction {
            let foodInfo = NSMutableAttributedString(string: "\(playerData.foodConsumption) / \(playerData.foodProduction)")
            foodInfo.addAttribute(
                NSForegroundColorAttributeName,
                value: UIColor.red,
                range: NSRange(location: 0, length: String(playerData.foodConsumption).characters.count)
            )
            foodLabel.text = nil
            foodLabel.attributedText = foodInfo
        } else {
            foodLabel.attributedText = nil
            foodLabel.text = "\(playerData.foodConsumption) / \(playerData.foodProduction)"
        }
    }
}
