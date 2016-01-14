//
//  LedPadView.swift
//  ledPad
//
//  Created by LeeYaping on 1/13/16.
//  Copyright © 2016 lisper. All rights reserved.
//

import UIKit

class LedPadView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    //当前触摸点
    var fingerPoint = CGPoint()
    //已划过的点集合
    var points:[CGPoint] = [CGPoint]()
    //已划过的点的下标
    var selectIndexs:[Int] = [Int]()
    //圆半径
    var circleRadius:CGFloat!
    //圆中心距
    var centerDistance:CGFloat!
    //第一个圆的X
    var firstPointX:CGFloat!
    //第一个圆的Y
    var firstPointY:CGFloat = 140
    //led的边长(一排的数量)
    var ledLength:Int = 12
    //靠边的距离
    var sideWidth:CGFloat = 10
    //两个圆边与边的距离
    var circleSideWidth:CGFloat = 10
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let screenW = UIScreen.mainScreen().bounds.width
        print("screenWidth = \(screenW)")
        self.backgroundColor = UIColor(red: 70/255, green: 80/255, blue: 60/255, alpha: 1)
        centerDistance = (screenW-self.sideWidth*2.0)/CGFloat(self.ledLength)
        circleRadius = (screenW-self.circleSideWidth*CGFloat(self.ledLength-1)-self.sideWidth*2.0) / CGFloat(self.ledLength*2)
        firstPointX = sideWidth + circleRadius
        firstPointY = 140
        print("R = \(circleRadius)")
        fillPoints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        for i in 0..<self.selectIndexs.count {
            if (i+1) < self.selectIndexs.count {
            let l1 = self.selectIndexs[i]
            let l2 = self.selectIndexs[i+1]
                print("\(l1), \(l2)")
            drawLine(points[l1], p2: points[l2])
            }
        }
        if (self.selectIndexs.count > 0) {
            drawLine(points[self.selectIndexs.last!], p2: self.fingerPoint)
        }
        drawCircles()
    }
    
    func fillPoints () {
        for row in 0..<ledLength {
            for col in 0..<ledLength {
                let tmpX = CGFloat(col)*self.centerDistance + self.firstPointX
                let tmpY = CGFloat(row)*self.centerDistance + self.firstPointY
                self.points.append(CGPoint(x: tmpX, y: tmpY))
            }
        }
    }
    
    func drawLine(p1:CGPoint, p2:CGPoint) {
        let bp = UIBezierPath()
        bp.lineWidth = 4
        bp.lineCapStyle = .Round
        bp.moveToPoint(p1)
        bp.addLineToPoint(p2)
        UIColor.redColor().setStroke()
        bp.stroke()
    }
    
    func drawLines(lines:[CGPoint]) {
        if (lines.count < 2) {
            return
        }
        let bp = UIBezierPath()
        bp.lineWidth = 4
        bp.lineCapStyle = .Round
        //UIColor(red: 0.4, green: 0.5, blue: 0.4, alpha: 1).setStroke()
        UIColor.redColor().setStroke()
        UIColor.redColor().setFill()
        
        bp.moveToPoint(lines[0])
        for i in 0..<lines.count {
            bp.addLineToPoint(lines[i])
        }
        bp.stroke()
        
    }
    
    
    func drawCircle(point:CGPoint, index:Int) {
        let context = UIGraphicsGetCurrentContext()
        if contains(index) {
            UIColor.redColor().setStroke()
            UIColor.yellowColor().setFill()
        } else {
            UIColor(red: 40/255, green: 60/255, blue: 50/255, alpha: 1).setFill()
            UIColor(red: 40/255, green: 50/255, blue: 50/255, alpha: 1).setStroke()
        }
        CGContextAddArc(context, point.x, point.y, self.circleRadius, 0, CGFloat(M_PI*2), 1)
        //CGContextStrokePath(context)
        CGContextFillPath(context)
        CGContextSetLineWidth(context, 4.0)
        CGContextAddArc(context, point.x, point.y, self.circleRadius, 0, CGFloat(M_PI*2), 1)
        CGContextStrokePath(context)
    }
    
    func drawCircles() {
        for i in 0..<self.points.count {
            drawCircle(self.points[i], index: i)
        }
    }
    
    func distance (p1:CGPoint, _ p2:CGPoint) -> CGFloat {
        return pow(pow(p1.x-p2.x, 2) + pow(p1.y-p2.y, 2), 0.5)
    }
    
    func contains(index:Int) -> Bool {
        for i in 0..<self.selectIndexs.count {
            if index == selectIndexs[i] {
                return true
            }
        }
        return false
    }
    
    func processPoint(point:CGPoint) {
        for i in 0..<self.points.count {
            if (!contains(i)) {
                if distance(point, points[i]) <= circleRadius {
                    self.selectIndexs.append(i)
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selectIndexs.removeAll(keepCapacity: false)
        self.fingerPoint = (touches.first?.locationInView(self))!
        processPoint(fingerPoint)
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.fingerPoint = (touches.first?.locationInView(self))!
        processPoint(fingerPoint)
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.selectIndexs.count > 0 {
            self.fingerPoint = self.points[self.selectIndexs.last!]
            self.setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    }
    
}
