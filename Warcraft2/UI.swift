//
//  UI.swift
//  Warcraft2
//
//  Created by Justin Jia on 1/10/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Overlay

@IBDesignable
class SplashImageView: UIImageView, CustomBackgroundColor, CustomDesign {

    var backgroundColorStyle: ColorStyle = UIColor.black
    var design: (DesignCustomizable) -> () = {
        let imageView = $0 as! UIImageView
        imageView.contentMode = .scaleAspectFit
    }

}

@IBDesignable
class TitleLabel: UILabel, CustomTextColor, CustomFont, CustomTextAlignment {

    var textColorStyle: ColorStyle = UIColor.white
    var fontStyle: FontStyle = UIFont.preferredFont(forTextStyle: .title1)
    var textAlignmentStyle: TextAlignmentStyle = NSTextAlignment.center

}

// FIXME: Currently add an `@IBDesignable` tag to custom `UIButton` will crash the interface builder, so we have to remove it.
// This won't affect anything, though.
class ActionButton: UIButton, CustomTitleColor, CustomBackgroundColor, CustomDesign {

    var backgroundColorStyle: ColorStyle = UIColor.darkGray
    var titleColorStyle: ColorStyle = UIColor.white
    var design: (DesignCustomizable) -> () = {
        let button = $0 as! UIButton
        button.layer.cornerRadius = 16
    }

}
