//
//  Icon.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/25.
//

import Foundation
import UIKit

class StatusImageManager {

    static func setImageOfButton(_ of:UIButton, status: Status) {
        of.setImage(self.getImage(status: status), for: .normal)
    }
    
    private static func getImage(status: Status) -> UIImage {
        switch status {
        case .inComplete:
            guard let inComplete = UIImage(systemName: "square") else {
                return UIImage()
            }
            return inComplete
        case .onGoing:
            guard let onGoing = UIImage(systemName: "square.righthalf.filled") else {
                return UIImage()
            }
            return onGoing
        case .delayed:
            guard let delayed = UIImage(systemName: "arrow.right.square") else {
                return UIImage()
            }
            return delayed
        case .complete:
            guard let complete = UIImage(systemName:"checkmark.square.fill") else {
                return UIImage()
            }
            return complete
        }
    }
    
}
