import UIKit

// UTILITY FUNCTION: For splitting a sprite sheet (input as UIImage) into numSprites different textures, returned as [UIImage]
func splitVerticalSpriteSheetToUIImages(from url: URL, numSprites: Int) -> [UIImage] {
    let image = UIImage(contentsOfFile: url.path)!
    let segmentHeight: CGFloat = image.size.height / CGFloat(numSprites)
    var cropRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: segmentHeight)
    var imageSegments: [UIImage] = []
    for i in 0 ..< numSprites {
        cropRect.origin.y = CGFloat(i) * segmentHeight
        let currentSegmentCGImage = image.cgImage!.cropping(to: cropRect)
        let currentSegmentUIImage = UIImage(cgImage: currentSegmentCGImage!)
        imageSegments.append(currentSegmentUIImage)
    }
    return imageSegments
}

class ResourceBarView: UIView {

    var gold = UIView()
    var goldIconView = UIImageView()
    var goldCount = UILabel()
    var lumber = UIView()
    var lumberIconView = UIImageView()
    var lumberCount = UILabel()
    var food = UIView()
    var foodIconView = UIImageView()
    var foodCount = UILabel()

    override func layoutSubviews() {
        let icons = splitVerticalSpriteSheetToUIImages(from: url("img", "MiniIcons.png"), numSprites: 4) // FIXME: hard-coded 4?
        let iconSideLength = self.frame.height

        gold.frame = CGRect(x: 0, y: 0, width: self.frame.width / 3, height: self.frame.height)
        goldIconView.frame = CGRect(x: 0, y: 0, width: iconSideLength, height: iconSideLength)
        goldIconView.image = icons[0]

        goldCount.frame = CGRect(x: iconSideLength, y: 0, width: gold.bounds.width - iconSideLength, height: gold.bounds.height)
        goldCount.text = "0"
        goldCount.textColor = UIColor.white

        gold.addSubview(goldIconView)
        gold.addSubview(goldCount)

        lumber.frame = CGRect(x: 0, y: 0, width: self.frame.width / 3, height: self.frame.height)
        lumberIconView.frame = CGRect(x: self.frame.width / 3, y: 0, width: iconSideLength, height: iconSideLength)
        lumberIconView.image = icons[1]

        lumberCount.frame = CGRect(x: self.frame.width / 3 + iconSideLength, y: 0, width: lumber.bounds.width - iconSideLength, height: lumber.bounds.height)
        lumberCount.text = "0"
        lumberCount.textColor = UIColor.white

        lumber.addSubview(lumberIconView)
        lumber.addSubview(lumberCount)

        food.frame = CGRect(x: 0, y: 0, width: self.frame.width / 3, height: self.frame.height)
        foodIconView.frame = CGRect(x: (self.frame.width / 3) * 2, y: 0, width: iconSideLength, height: iconSideLength)
        foodIconView.image = icons[2]

        foodCount.frame = CGRect(x: (self.frame.width / 3) * 2 + iconSideLength, y: 0, width: food.bounds.width - iconSideLength, height: food.bounds.height)
        foodCount.text = "0"
        foodCount.textColor = UIColor.white

        food.addSubview(foodIconView)
        food.addSubview(foodCount)

        self.addSubview(gold)
        self.addSubview(lumber)
        self.addSubview(food)
    }
}
