//
//  SelectedDate.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/04/20.
//

import Foundation


class SelectedDate {
    static let shared: SelectedDate = SelectedDate()
    
    private init() {
        
    }
    var date: Date = Date()
}
