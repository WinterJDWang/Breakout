//
//  UserDefaultSettings.swift
//  Breakout
//
//  Created by CSI User on 16/4/11.
//  Copyright © 2016年 Wang. All rights reserved.
//

import Foundation

class UserDefaultSettings {
    
    private struct Const {
        static let ColumnsKey = "Columns"
        static let RowsKey = "Rows"
        static let BallsKey = "Balls"
        static let DifficultyKey = "Difficulty"
        static let AutoStartKey = "AutoStart"
        static let SpeedKey = "Speed"
        static let ChangeKey = "ChangeIndicator"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var columns: Int? {
        get { return defaults.objectForKey(Const.ColumnsKey) as? Int ?? 5}
        set { defaults.setObject(newValue, forKey: Const.ColumnsKey) }
    }
    
    var rows: Int? {
        get { return defaults.objectForKey(Const.RowsKey) as? Int ?? 5}
        set { defaults.setObject(newValue, forKey: Const.RowsKey) }
    }
    
    var balls: Int? {
        get { return defaults.objectForKey(Const.BallsKey) as? Int ?? 1}
        set { defaults.setObject(newValue, forKey: Const.BallsKey) }
    }
    
    var difficulty: Int? {
        get { return defaults.objectForKey(Const.DifficultyKey) as? Int ?? 1}
        set { defaults.setObject(newValue, forKey: Const.DifficultyKey) }
    }
    
    var autoStart: Bool {
        get { return defaults.objectForKey(Const.AutoStartKey) as? Bool ?? false}
        set { defaults.setObject(newValue, forKey: Const.AutoStartKey) }
    }
    
    var speed: Float {
        get { return defaults.objectForKey(Const.SpeedKey) as? Float ?? 1.0 }
        set { defaults.setObject(newValue, forKey: Const.SpeedKey) }
    }
    
    var changed: Bool {
        get { return defaults.objectForKey(Const.ChangeKey) as? Bool ?? false }
        set { defaults.setObject(newValue, forKey: Const.ChangeKey) }
    }


}
