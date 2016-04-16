//
//  ViewController.swift
//  Breakout
//
//  Created by CSI User on 16/4/8.
//  Copyright © 2016年 Wang. All rights reserved.
//

import UIKit

class GameVC: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var gameView: GameView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func tap(sender: UITapGestureRecognizer) {
        pushBall()
    }
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Ended: fallthrough
        case .Changed:
            placePaddle(sender.translationInView(gameView))
            sender.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    

    private var behavior = BreakoutBehavior()
    
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.gameView)
        animator.addBehavior(self.behavior)
        return animator
    }()

    
    
    // MARK: - ball
    
    let BallSize = CGSize(width: 40.0, height: 40.0)
    
    var autoStartTimer: NSTimer?
    
    // set a timer to create the ball automatically
    func setAutoStartTimer() {
        if UserDefaultSettings().autoStart {
            autoStartTimer =  NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(GameVC.autoStart(_:)), userInfo: nil, repeats: true)
        }
    }
    // create and push the ball automatically
    func autoStart(timer: NSTimer) {
        if behavior.balls.count < UserDefaultSettings().balls {
            let ball = createBall()
            placeBall(ball)
            behavior.addBall(ball)
            behavior.pushBall(behavior.balls.last!, speed: CGFloat(UserDefaultSettings().speed))
        }
    }
    
    func createBall() -> UIView {
        var frame = CGRect()
        frame.origin = CGPointZero
        frame.size = BallSize
        
        let ballView = EllipseView(frame: frame)
        return ballView
    }
    func placeBall(ball: UIView) {
        var center = paddle.center
        center.y -= PaddleSize.height / 2 + BallSize.width / 2.0
        ball.center = center
    }
    
    // when player taps the screen, create a new ball or push the last ball
    func pushBall() {
        
        if behavior.balls.count < UserDefaultSettings().balls {
            let ball = createBall()
            placeBall(ball)
            behavior.addBall(ball)
        }
        behavior.pushBall(behavior.balls.last!, speed: CGFloat(UserDefaultSettings().speed))
    }
    
    
    // MARK: - brick
    let BrickRows = 5
    let BrickColumns = 5
    // set the bricks' proportions of the screen
    let BrickTotalWidth: CGFloat = 1.0
    let BrickTotalHeight: CGFloat = 0.3
    let BrickTopSpacing: CGFloat = 0.05
    let BrickSpacing: CGFloat = 3.0
    let BrickCornerRadius: CGFloat = 2.5
    
    private var bricks = [Int:Brick]()
    
    private struct Brick {
        var relativeFrame: CGRect
        var view: UIView
        var action: BrickAction
    }
    
    private typealias BrickAction = ((Int) -> Void)?
    
    // set the bricks
    private func SetBrick() {
        if bricks.count > 0 { return }
        
        let Rows = Int(UserDefaultSettings().rows!)
        let Columns = Int(UserDefaultSettings().columns!)
        
        let deltaX = 1.0 / CGFloat(Columns)
        let deltaY = 0.3 / CGFloat(Rows)
        
        var frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: deltaX, height: deltaY))

        for row in 0..<Rows {
            for column in 0..<Columns {
                frame.origin.x = deltaX * CGFloat(column)
                frame.origin.y = deltaY * CGFloat(row) + BrickTopSpacing
                let brick = BrickView(frame: frame)
                gameView.addSubview(brick)
                
                var action: BrickAction = nil
                action = setBrickAction(UserDefaultSettings().difficulty!, brickRow: row, brick: brick)
                
                bricks[row * Columns + column] = Brick(relativeFrame: frame, view: brick, action: action)
            }
        }
    }
    // set the actions of the bricks for "Normal" and "Hard" difficulty level
    private func setBrickAction(difficulty: Int, brickRow: Int, brick: BrickView) -> BrickAction {
        var action: BrickAction = nil
        
        if difficulty != 0 {
            action = { index in
                if brick.backgroundColor != UIColor.blackColor() {
                    self.destroyBrickAtIndex(index)
                    self.recordScore()
                } else {
                    NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(GameVC.changeBrickColor(_:)), userInfo: brick, repeats: false)
                }
            }
            
            if difficulty == 1 {
                // set the last row of the bricks to back color for the normal level
                if brickRow + 1 == UserDefaultSettings().rows! {
                    brick.backgroundColor = UIColor.blackColor()
                    
                }
            }else{
                //set all the bricks to black color for the hard level
                brick.backgroundColor = UIColor.blackColor()
            }
        }
        
        return action
    }
    
    func changeBrickColor(timer: NSTimer) {
        if let brick = timer.userInfo as? BrickView {
            BrickView.animateWithDuration(0.5, animations: { () -> Void in
                brick.backgroundColor = brick.randomColor()
                }, completion: nil)
        }
    }
    
    //Placing the bricks, just takes the relative frame information boosts it to the device dimensions, 
    //and adjusts the barriers for the collision behavior:

    private func placeBricks() {
        for (index, brick) in bricks {
            brick.view.frame.origin.x = brick.relativeFrame.origin.x * gameView.bounds.width
            brick.view.frame.origin.y = brick.relativeFrame.origin.y * gameView.bounds.height + 10
            brick.view.frame.size.width = brick.relativeFrame.width * gameView.bounds.width
            brick.view.frame.size.height = brick.relativeFrame.height * gameView.bounds.height
            
            brick.view.frame = CGRectInset(brick.view.frame, BrickSpacing, BrickSpacing)
            
            behavior.addBarrier(UIBezierPath(roundedRect: brick.view.frame, cornerRadius: 2.5), named: index)
        }
    }
    
    // set the animation when a brick is hit by the ball
    private func destroyBrickAtIndex(index: Int) {
        behavior.removeBarrier(index)
        if let brick = bricks[index] {
            UIView.transitionWithView(brick.view, duration: 0.2, options: .TransitionFlipFromBottom, animations: {
                brick.view.alpha = 0.5
                }, completion: { (success) -> Void in
                    self.behavior.addBrick(brick.view)
                    UIView.animateWithDuration(1.0, animations: {
                        brick.view.alpha = 0.0
                        }, completion: { (success) -> Void in
                            self.behavior.removeBrick(brick.view)
                            brick.view.removeFromSuperview()
                            if self.bricks.count == 0 {
                                self.gameFinished()
                            }
                    })
            })
            bricks.removeValueForKey(index)
        }
    }
    
    // MARK: - paddle
    
    let PaddleSize = CGSize(width: 80.0, height: 20.0)
    
    lazy var paddle: PaddleView = {
        var frame = CGRect()
        frame.origin = CGPoint(x: -1, y: -1)
        frame.size = self.PaddleSize
        
        let paddle = PaddleView(frame: frame)
        self.gameView.addSubview(paddle)
        
        return paddle
    }()
    
    private func resetPaddle() {
        if !CGRectContainsRect(gameView.bounds, paddle.frame) {
            paddle.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.maxY - paddle.bounds.height * 3.5)
        } else {
            paddle.center = CGPoint(x: paddle.center.x, y: gameView.bounds.maxY - paddle.bounds.height * 3.5)
        }
        addPaddleBarrier()
    }
    
    func placePaddle(translation: CGPoint) {
        var origin = paddle.frame.origin
        origin.x = max(min(origin.x + translation.x, gameView.bounds.maxX - PaddleSize.width), 0.0)
        paddle.frame.origin = origin
        addPaddleBarrier()
    }
    
    func addPaddleBarrier() {
        behavior.addBarrier(UIBezierPath(roundedRect: paddle.frame, cornerRadius: paddle.radius), named: "paddlePath")
    }

    // MARK: - game functions
    
    var score = 0
    // add 10 points when a brick is destroied by the ball
    func recordScore() -> Int {
        score += 10
        scoreLabel.text = " Level: \(UserDefaultSettings().difficulty! + 1)    Score:  \(score)"
        return score
    }
    // remove all the existing balls and set the alert when the game is over
    func gameFinished() {
        
        autoStartTimer?.invalidate()
        autoStartTimer = nil
        
        for ball in behavior.balls {
            behavior.removeBall(ball)
        }
        
        let alertController = UIAlertController(title: "Game Over", message: "your score is \(score)", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Play Again", style: .Default, handler: { (action) in
            self.SetBrick()
            self.setAutoStartTimer()
            self.score = 0
            self.scoreLabel.text = " Level: \(UserDefaultSettings().difficulty! + 1)    Score:  \(self.score)"
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    // destroy the bricks when collision happened
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let index = identifier as? Int {
            if let action = bricks[index]?.action {
                action(index)
            } else {
                destroyBrickAtIndex(index)
                recordScore()
            }
        }
    }
    
  
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator.delegate = self
        behavior.collisionDelegate = self
        
        scoreLabel.text = " Level: \(UserDefaultSettings().difficulty! + 1)    Score:  \(score)"
        
        SetBrick()
       
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaultSettings().changed {
            UserDefaultSettings().changed = false
            for (_, brick) in bricks {
                brick.view.removeFromSuperview()
            }
            bricks.removeAll(keepCapacity: true)
            
            for ball in behavior.balls {
                ball.removeFromSuperview()
            }
            //Reset the animator and the breakout behavior
            animator.removeAllBehaviors()
            behavior = BreakoutBehavior()
            animator.addBehavior(behavior)
            behavior.collisionDelegate = self
            
            score = 0
            scoreLabel.text = " Level: \(UserDefaultSettings().difficulty! + 1)    Score:  \(score)"
            SetBrick()
        }
        
        setAutoStartTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        autoStartTimer?.invalidate()
        autoStartTimer = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // set the bounds of the view, make it a little higher than the height of the view
        var rect = gameView.bounds
        rect.size.height += 100
        behavior.addBarrier(UIBezierPath(rect: rect), named: "bounds")
    
        resetPaddle()
        placeBricks()
        
        // reset the position of the ball
        for ball in behavior.balls {
            if !CGRectContainsRect(gameView.bounds, ball.frame) {
                placeBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
        
    }

    
}




