//
//  GameView.swift
//  Breakout
//
//  Created by CSI User on 16/4/9.
//  Copyright © 2016年 Wang. All rights reserved.
//

import UIKit

class GameView: UIView {
    
    private var bezierPaths = [String: UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }

}

class EllipseView: UIView {
    private func randomColor() -> UIColor {
        let randomHue = CGFloat(rand()) / CGFloat(RAND_MAX)
        return UIColor(hue: randomHue, saturation: 1.0, brightness: 1.0, alpha: 0.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = randomColor()
        layer.cornerRadius = frame.size.width / 2.0
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }
}

class PaddleView: UIView {
    
    var radius:CGFloat {
        get {
            return 5.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.grayColor()
        layer.cornerRadius = radius
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 2.0
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowOpacity = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Rectangle
    }
}

class BrickView: UIView {
    internal func randomColor() -> UIColor {
        let randomHue = CGFloat(rand()) / CGFloat(RAND_MAX)
        return UIColor(hue: randomHue, saturation: 1.0, brightness: 1.0, alpha: 0.5)
    }
    
    var radius:CGFloat {
        get {
            return 2.5
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = randomColor()
        layer.cornerRadius = frame.size.width / 20
        layer.borderColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowOpacity = 0.1
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Rectangle
    }
}


