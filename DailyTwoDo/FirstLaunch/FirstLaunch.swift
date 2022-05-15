//
//  FirstLaunch.swift
//  DailyTwoDo
//
//  Created by WG Yang on 2022/05/15.
//

import Foundation

/*
 https://dongkyprogramming.tistory.com/30
 */
final class FirstLaunch {
    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    init(getWasLaunchedBefore: () -> Bool, setWasLaunchedBefore: (Bool) -> ()) {
        let wasLaunchedBefore:Bool = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            setWasLaunchedBefore(true)
        }
    }
    
    convenience init(userDefaults: UserDefaults, key: String) {
        self.init(
            getWasLaunchedBefore: { userDefaults.bool(forKey: key)},
            setWasLaunchedBefore: { userDefaults.set($0, forKey: key)}
        )
    }
    
}
extension FirstLaunch {
    static func alwaysFirst() -> FirstLaunch {
        return FirstLaunch(
            getWasLaunchedBefore: { return false },
            setWasLaunchedBefore: { _ in }) }
}
