//
//  SettingsVC.swift
//  Breakout
//
//  Created by CSI User on 16/4/11.
//  Copyright © 2016年 Wang. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var columnSlider: UISlider!

    @IBOutlet weak var rowSlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var ballStepper: UIStepper!
    @IBOutlet weak var difficultySelector: UISegmentedControl!
    @IBOutlet weak var autoStartSwitch: UISwitch!
    
    @IBOutlet weak var columnLabel: UILabel!
    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var ballLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBAction func columnsChanged(sender: UISlider) {
        columns = Int(sender.value)
        UserDefaultSettings().columns = columns
        UserDefaultSettings().changed = true
    }
    
    @IBAction func rowsChanged(sender: UISlider) {
        rows = Int(sender.value)
        UserDefaultSettings().rows = rows
        UserDefaultSettings().changed = true
    }
    @IBAction func speedChanged(sender: UISlider) {
        speed = sender.value / 100
        UserDefaultSettings().speed = speed
        UserDefaultSettings().changed = true
    }
    @IBAction func ballsChanged(sender: UIStepper) {
        balls = Int(sender.value)
        UserDefaultSettings().balls = balls
        UserDefaultSettings().changed = true
    }
    @IBAction func difficultyChanged(sender: UISegmentedControl) {
        UserDefaultSettings().difficulty = difficulty
        UserDefaultSettings().changed = true
    }
    @IBAction func autoStartChanged(sender: UISwitch) {
        UserDefaultSettings().autoStart = autoStart
        UserDefaultSettings().changed = true
    }
    @IBAction func resetClicked(sender: UIButton) {
        columns = 5
        rows = 5
        balls = 1
        difficulty = 1
        autoStart = false
        speed = 1.0
        
        UserDefaultSettings().columns = columns
        UserDefaultSettings().rows = rows
        UserDefaultSettings().speed = speed
        UserDefaultSettings().balls = balls
        UserDefaultSettings().difficulty = difficulty
        UserDefaultSettings().autoStart = autoStart

        UserDefaultSettings().changed = true
    }
    
    
    
    
    var columns: Int {
        get{
            return Int(columnLabel.text!)!
        }
        set {
            columnLabel.text = "\(newValue)"
            columnSlider.value = Float(newValue)
        }
    }
    var rows: Int {
        get { return Int(rowLabel.text!)! }
        set {
            rowLabel.text = "\(newValue)"
            rowSlider.value = Float(newValue)
        }
    }
    
    var balls: Int {
        get { return Int(ballLabel.text!)! }
        set {
            ballLabel.text = "\(newValue)"
            ballStepper.value = Double(newValue)
        }
    }
    
    var difficulty: Int {
        get { return difficultySelector.selectedSegmentIndex }
        set { difficultySelector.selectedSegmentIndex = newValue }
    }
    
    var autoStart: Bool {
        get { return autoStartSwitch.on }
        set { autoStartSwitch.on = newValue }
    }
    
    var speed: Float {
        get { return speedSlider.value / 100.0 }
        set {
            speedSlider.value = newValue * 100.0
            speedLabel.text = "\(Int(speedSlider.value)) %"
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        columns = UserDefaultSettings().columns!
        rows = UserDefaultSettings().rows!
        balls = UserDefaultSettings().balls!
        difficulty = UserDefaultSettings().difficulty!
        autoStart = UserDefaultSettings().autoStart
        speed = UserDefaultSettings().speed
    }
    
    
}
