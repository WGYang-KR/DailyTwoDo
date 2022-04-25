//
//  UIFont.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/25.
//

import Foundation
import UIKit

extension UIFont {
        
        enum Family: String {
            case ExtraBold = "ExtraBold"
            case Bold = "Bold"
            case Regular = ""
            case Light = "Light"
        }
        
        static func nanum(size: CGFloat, family: Family) -> UIFont! {
            let fontName = "NanumGothicOTF" + family.rawValue
            return UIFont(name: fontName, size: size)
        }

}
