//
//  extensionStatus.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/26.
//

import Foundation

enum Status: Int, CaseIterable {
    case inComplete
    case onGoing
    case delayed
    case complete
}

extension WorkMo {
    var status: Status {
        get {
            return Status(rawValue: Int(self.statusValue))!
        }
        set(value) {
            self.statusValue = Int16(value.rawValue)
        }
    }
}
