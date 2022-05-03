//
//  UIViewExtension.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/05/03.
//

import Foundation
import UIKit

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}
