//
//  LedPadView.swift
//  ledPad
//
//  Created by LeeYaping on 1/13/16.
//  Copyright © 2016 lisper. All rights reserved.
//

import UIKit

class LedPadView: UIView {

    //当前触摸点
    var fingerPoint = CGPoint()
    //所有点对象映射
    var points:[CGPoint] = [CGPoint]()
    //
    var drawPoints:[[CGPoint]] = [[CGPoint]]()
    //已划过的点的下标
    var selectIndexs:[[Int]] = [[Int]]()
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
    var circleSideDistance:CGFloat = 10
    var sideLength:CGFloat!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let screenW = UIScreen.mainScreen().bounds.width
        print("screenWidth = \(screenW)")
        self.backgroundColor = UIColor(red: 70/255, green: 80/255, blue: 60/255, alpha: 1)
        circleRadius = (screenW-self.circleSideDistance*CGFloat(self.ledLength-1)-self.sideWidth*2.0) / CGFloat(self.ledLength*2)
        centerDistance = (screenW-self.sideWidth*2.0 - circleRadius*2)/CGFloat(self.ledLength-1)
        sideLength = screenW-self.sideWidth*2
        firstPointX = sideWidth + circleRadius
        firstPointY = 140
        print("R = \(circleRadius)")
        fillPoints()
        
        let clearButton = UIButton(type: UIButtonType.Custom)
        clearButton.frame = CGRect(x: sideWidth, y: self.firstPointY+sideLength, width: 100, height: 40)
        clearButton.backgroundColor = UIColor(red: 80/255, green: 90/255, blue: 40/255, alpha: 1)
        clearButton.setTitle("clear", forState: UIControlState.Normal)
        clearButton.titleLabel?.font = UIFont.systemFontOfSize(28)
        clearButton.addTarget(self, action: "clearActive", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(clearButton)
    }
    
    func clearActive() {
        self.selectIndexs.removeAll(keepCapacity: true)
        self.drawPoints.removeAll(keepCapacity: true)
        self.setNeedsDisplay()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        for i in 0..<self.selectIndexs.count {
            for j in 0..<self.selectIndexs[i].count {
                if (j+1) < self.selectIndexs[i].count {
                    let l1 = self.selectIndexs[i][j]
                    let l2 = self.selectIndexs[i][j+1]
                    drawLine(points[l1], p2: points[l2])
                }
            }
        }
        
        let lastIndex = self.selectIndexs.count-1
            if ( lastIndex >= 0 && self.selectIndexs[lastIndex].count > 0) {
                drawLine(points[self.selectIndexs[lastIndex].last!], p2: self.fingerPoint)
            }
        drawCircles()
        for i in 0..<self.drawPoints.count {
            drawLines(self.drawPoints[i], color: UIColor.greenColor())
        }
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
    
    func drawLines(lines:[CGPoint], color:UIColor) {
        if (lines.count < 2) {
            return
        }
        let bp = UIBezierPath()
        bp.lineWidth = 4
        bp.lineCapStyle = .Round
        //UIColor(red: 0.4, green: 0.5, blue: 0.4, alpha: 1).setStroke()
        color.setStroke()
        color.setFill()
        
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
        // CGContextSetLineWidth(context, 4.0)
        // CGContextAddArc(context, point.x, point.y, self.circleRadius-2.0, 0, CGFloat(M_PI*2), 1)
        // CGContextStrokePath(context)
    }
    
    func drawCircles() {
        for i in 0..<self.points.count {
            drawCircle(self.points[i], index: i)
        }
    }
    
    func distance (p1:CGPoint, _ p2:CGPoint) -> CGFloat {
        return pow(pow(p1.x-p2.x, 2) + pow(p1.y-p2.y, 2), 0.5)
    }
    
    func isInside (p:CGPoint, _ cp:CGPoint) -> Bool {
        if p.x>(cp.x-self.circleRadius)
            && p.x<(cp.x+self.circleRadius)
            && p.y>(cp.y-self.circleRadius)
            && p.y<(cp.y+self.circleRadius) {
           return true
        }
        return false
    }
    
    func contains(index:Int) -> Bool {
        for i in 0..<self.selectIndexs.count {
            for j in 0..<self.selectIndexs[i].count {
                if index == self.selectIndexs[i][j] {
                    return true
                }
            }
        }
        return false
    }
    
        func processPoint(point:CGPoint) {
            var lastIndex = self.selectIndexs.count-1
            if lastIndex < 0 {
                lastIndex = 0
                self.selectIndexs.append([Int]())
            }
            for i in 0..<self.points.count {
            if (!contains(i)) {
                //if distance(point, points[i]) <= circleRadius {
                if isInside(point, points[i]) {
                    self.selectIndexs[lastIndex].append(i)
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //self.selectIndexs.removeAll(keepCapacity: false)
        self.selectIndexs.append([Int]())
        self.fingerPoint = (touches.first?.locationInView(self))!
        self.drawPoints.append([CGPoint]())
        let lastIndex = self.drawPoints.count-1
        self.drawPoints[lastIndex].append(fingerPoint)
        processPoint(fingerPoint)
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.fingerPoint = (touches.first?.locationInView(self))!
        let lastIndex = self.drawPoints.count-1
        self.drawPoints[lastIndex].append(fingerPoint)
        processPoint(fingerPoint)
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchPoint = (touches.first?.locationInView(self))!
        let lastIndex = self.drawPoints.count-1
        self.drawPoints[lastIndex].append(touchPoint)
        let lastIndex1 = self.selectIndexs.count-1
        if let pointLast = self.selectIndexs[lastIndex1].last {
            self.fingerPoint = self.points[pointLast]
        }
        self.setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    }
    
}
