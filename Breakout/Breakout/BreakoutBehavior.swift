//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by CSI User on 16/4/8.
//  Copyright © 2016年 Wang. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
    private  var gravity = UIGravityBehavior()
    
    private lazy var collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.action = {
            // remove the ball if it goes out of the view
            for ball in self.balls {
                if !CGRectIntersectsRect(self.dynamicAnimator!.referenceView!.bounds, ball.frame) {
                    self.removeBall(ball)
                }
            }
        }
        return collider
    }()
    
    var collisionDelegate: UICollisionBehaviorDelegate? {
        get{
            return collider.collisionDelegate
        }
        set {
            collider.collisionDelegate = newValue
        }
    }

    private lazy var ballBehavior: UIDynamicItemBehavior = {
        let itemBehaviour =  UIDynamicItemBehavior()
        itemBehaviour.allowsRotation = false
        itemBehaviour.elasticity = 1.0
        itemBehaviour.friction = 0.0
        itemBehaviour.resistance = 0.0
        //itemBehaviour.linearVelocityForItem(UIDynamicItem)
        return itemBehaviour
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        //addChildBehavior(brickBehavior)
    }
    
    // MARK: - ball
    
    var balls:[UIView] {
        get {
            return collider.items.filter{$0 is UIView}.map{$0 as! UIView}
        }
    }
    
    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        //gravity.addItem(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: UIView) {
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }
    
    func pushBall(ball: UIView, speed: CGFloat) {
        let push = UIPushBehavior(items: [ball], mode: .Instantaneous)
        push.magnitude = speed
        
        push.angle = CGFloat(Double(arc4random()) * M_PI * 2 / Double(UINT32_MAX))
        push.action = { [weak push] in
            if !push!.active {
                self.removeChildBehavior(push!)
            }
        }
        addChildBehavior(push)
    }
    
    //MARK: - brick
    
    func addBrick(brick: UIView) {
        //dynamicAnimator?.referenceView?.addSubview(brick)
        gravity.addItem(brick)
        //collider.addItem(brick)
        //brickBehavior.addItem(brick)
    }
    
    func removeBrick(brick: UIView) {
        gravity.removeItem(brick)
    }
    
    // MARK: - barrier
    
    func addBarrier(path: UIBezierPath, named name: NSCopying) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func removeBarrier(name: NSCopying) {
        collider.removeBoundaryWithIdentifier(name)
    }
    
    

}
