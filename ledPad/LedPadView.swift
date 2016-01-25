//
//  LedPadView.swift
//  ledPad
//
//  Created by LeeYaping on 1/13/16.
//  Copyright © 2016 lisper. All rights reserved.
//

import UIKit

class LedPadView: UIView {
    
    //
    var lastSelectPoint:Int?
    var isGetPoint:Bool = false
    //所有点对象映射
    var points:[CGPoint] = [CGPoint]()
    //
    var pointData:[[[Int]]] = [[[Int]]]()
    //
    var deletedIndexs:[[Int]] = [[Int]]()
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
    var sideDistance:CGFloat = 20
    //两个圆边与边的距离
    var circleSideDistance:CGFloat = 40
    //边长...
    var sideLength:CGFloat!
    
    let homeDir = NSHomeDirectory()
    var docPath:String!
    var lastPointRadius:CGFloat!
    
    let backColor = UIColor(red: 40/255, green: 60/255, blue: 50/255, alpha: 1)
    let buttonNornalColor = UIColor(red: 60/255, green: 90/255, blue: 70/255, alpha: 1)
    let buttonApplicationColor = UIColor(red: 60/255, green: 190/255, blue: 70/255, alpha: 1)
    let pointNormalColor = UIColor(red: 40/255, green: 60/255, blue: 50/255, alpha: 1)
    let pointStrokeColor = UIColor(red: 40/255, green: 50/255, blue: 50/255, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let screenW = UIScreen.mainScreen().bounds.width
        print("screenWidth = \(screenW)")
        self.backgroundColor = UIColor(red: 70/255, green: 80/255, blue: 60/255, alpha: 1)
        circleRadius = (screenW-self.circleSideDistance*CGFloat(self.ledLength-1)-self.sideDistance*2.0) / CGFloat(self.ledLength*2)
        circleRadius = 5
        sideLength = screenW-self.sideDistance*2
        centerDistance = (sideLength - circleRadius*2)/CGFloat(self.ledLength-1)
        self.lastPointRadius = self.centerDistance/2
        firstPointX = sideDistance + circleRadius
        firstPointY = 140
        print("R = \(circleRadius)")
        fillPoints()
        createButton("Clear", action: "clearActive:", frame:  CGRect(x: sideDistance, y: self.firstPointY+sideLength + 40, width: 70, height: 40))
        createButton("Undo", action: "undoActive:", frame:  CGRect(x: sideDistance + 70 + 10, y: self.firstPointY+sideLength + 40, width: 70, height: 40))
        createButton("Redo", action: "redoActive:", frame:  CGRect(x: sideDistance + 70 * 2 + 10 * 2, y: self.firstPointY+sideLength + 40, width: 70, height: 40))
        createButton("OK", action: "okActive:", frame:  CGRect(x: sideDistance + 70 * 3 + 10 * 3, y: self.firstPointY+sideLength + 40, width: 50, height: 40))
        createButton("Load", action: "loadActive:", frame:  CGRect(x: sideDistance + 70 * 3 + 10 * 3, y: self.firstPointY+sideLength + 40 + 60, width: 70, height: 40))
        
       let docPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        docPath = docPaths[0]+"/ledData.json"
        //docPath = NSHomeDirectory()+"/Documents"
        print(docPath)
        //let data = NSData()
        //data.writeToFile(docPath, atomically: true)
        loadData()
    }
    
    func saveData() {
        print(selectIndexs)
        print(pointData)
        var jsonData = Array<AnyObject> ()
        for i in 0..<pointData.count {
            var p = [[Int]]()
            var data = Dictionary<String, AnyObject> ()
            data["name"] = "led\(i)"
            data["uuid"] = i
            for j in 0..<pointData[i].count {
                p.append([Int]())
                for k in 0..<pointData[i][j].count {
                    let d1 = pointData[i][j][k]
                    p[j].append(d1)
                }
            }
            data["data"] = p
            jsonData.append(data)
        }
        print(jsonData)
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions()) else {
           return
        }
        data.writeToFile(docPath, atomically: true)
        
    }
    
    func loadData() {
        if !NSFileManager().fileExistsAtPath(docPath) {
            print("erro no file")
            return
        }
        let data = NSData(contentsOfFile: docPath)
        if data == nil {
            print("erro data is nil")
            return
        }
        var jsonData:AnyObject?
        do {
            jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
        } catch let error as NSError {
            print(error)
            return
        }
        
        let jsonArray = jsonData as! NSArray
        pointData = [[[Int]]]()
        print("number = \(jsonArray.count)")
        for i in 0..<jsonArray.count {
            var dic = jsonArray[i] as! Dictionary<String, AnyObject>
            pointData.append(dic["data"] as! [[Int]])
        }
    }
    
    func randomLoad () {
        if pointData.count == 0 {
            return
        }
        let randomIndex = arc4random_uniform(UInt32(pointData.count-1))
        selectIndexs = pointData[Int(randomIndex)]
        fixEndPoint()
        self.setNeedsDisplay()
    }
    
    func createButton(name:String, action: Selector, frame: CGRect) {
        let button = UIButton(type: UIButtonType.Custom)
        button.frame = frame
        button.backgroundColor = backColor
        button.adjustsImageWhenHighlighted = true
        button.setTitle(name, forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(28)
        button.setTitleColor(buttonNornalColor, forState: UIControlState.Normal)
        button.setTitleColor(buttonApplicationColor, forState: UIControlState.Highlighted)
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)
    }
    
    func buttonAnimation (button:UIButton) {
        UIButton.setAnimationRepeatAutoreverses(true)
        UIButton.animateWithDuration(0.1, animations: { () -> Void in
            button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            }) { (finish) -> Void in
                button.backgroundColor = self.backColor
        }
    }
    
    func clearActive(sender:UIButton) {
        if (!self.selectIndexs.isEmpty) {
            self.selectIndexs.removeAll(keepCapacity: false)
            self.deletedIndexs.removeAll(keepCapacity: false)
            self.lastSelectPoint = nil
            self.setNeedsDisplay()
        }
        buttonAnimation(sender)
    }
    
    func undoActive(sender:UIButton) {
        if (!self.selectIndexs.isEmpty) {
            self.deletedIndexs.append(self.selectIndexs.last!)
            self.selectIndexs.removeLast()
            self.lastSelectPoint = nil
            self.setNeedsDisplay()
            fixEndPoint()
        }
        buttonAnimation(sender)
    }
    
    func redoActive(sender:UIButton) {
        if (!self.deletedIndexs.isEmpty) {
            self.selectIndexs.append(self.deletedIndexs.last!)
            self.deletedIndexs.removeLast()
            self.setNeedsDisplay()
            fixEndPoint()
        }
        buttonAnimation(sender)
    }
    
    func okActive(sender:UIButton) {
        print("in okActive")
        if selectIndexs.count == 0 {
            print("error no data for save")
            return
        }
        pointData.append(self.selectIndexs)
        saveData()
        self.selectIndexs.removeAll(keepCapacity: false)
        self.deletedIndexs.removeAll(keepCapacity: false)
        self.setNeedsDisplay()
        buttonAnimation(sender)
    }
    
    func loadActive (sender:UIButton) {
        print("in loadActive")
        randomLoad()
        buttonAnimation(sender)
    }
    
    func fixEndPoint () {
        let lastIndex = self.selectIndexs.count-1
        if lastIndex < 0 {
            return
        }
        if let pointLast = self.selectIndexs[lastIndex].last {
            self.lastSelectPoint = pointLast
        }
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
            if (lastSelectPoint != nil && lastSelectPoint >= 0) {
                drawLine(points[self.selectIndexs[lastIndex].last!], p2: points[self.lastSelectPoint!])
                let point = self.points[lastSelectPoint!]
                let context = UIGraphicsGetCurrentContext()
                UIColor.redColor().setStroke()
                CGContextSetLineWidth(context, 2.0)
                CGContextAddArc(context, point.x, point.y, +self.lastPointRadius, 0, CGFloat(M_PI*2), 1)
                CGContextStrokePath(context)
            }
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
        bp.lineJoinStyle = .Round
        bp.moveToPoint(p1)
        bp.addLineToPoint(p2)
        UIColor.greenColor().setStroke()
        bp.stroke()
    }
    
    func drawLines(lines:[CGPoint], color:UIColor) {
        if (lines.count < 2) {
            return
        }
        let bp = UIBezierPath()
        bp.lineWidth = 4
        bp.lineCapStyle = .Round
        bp.lineJoinStyle = .Round
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
            pointNormalColor.setFill()
            pointStrokeColor.setStroke()
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
        let dist = self.centerDistance/2
        if p.x>=(cp.x-dist)
            && p.x<=(cp.x+dist)
            && p.y>=(cp.y-dist)
            && p.y<=(cp.y+dist) {
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
    
    func processBegin(point:CGPoint) {
        var lastIndex = self.selectIndexs.count-1
        if lastIndex < 0 {
            lastIndex = 0
            self.selectIndexs.append([Int]())
        }
        for i in 0..<self.points.count {
            //if isInside(point, points[i])
            if distance(point, points[i]) < self.centerDistance/2 {
                print("i=\(i), f=\(lastSelectPoint)")
                if self.lastSelectPoint != nil && self.lastSelectPoint == i {
                    isGetPoint = true
                    self.lastSelectPoint = i
                } else {
                    if (!contains(i)) {
                        self.selectIndexs.append([Int]())
                        self.selectIndexs[lastIndex+1].append(i)
                        self.lastSelectPoint = i
                        isGetPoint = true
                    }
                }
            }
        }
    }
    
    func processMove(point:CGPoint) {
        var lastIndex = self.selectIndexs.count-1
        if lastIndex < 0 {
            lastIndex = 0
            self.selectIndexs.append([Int]())
        }
        for i in 0..<self.points.count {
            if (!contains(i)) {
                if distance(point, points[i]) < self.centerDistance/2 {
                    self.lastSelectPoint = i
                }
            }
        }
    }
    
    func processEnd(point:CGPoint) {
        var lastIndex = self.selectIndexs.count-1
        if lastIndex < 0 {
            lastIndex = 0
            self.selectIndexs.append([Int]())
        }
        for i in 0..<self.points.count {
            if (!contains(i)) {
                if distance(point, points[i]) < self.centerDistance/2 {
                    self.lastSelectPoint = i
                }
            }
        }
        if self.lastSelectPoint != nil {
            self.selectIndexs[lastIndex].append(self.lastSelectPoint!)
        }
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.deletedIndexs.removeAll(keepCapacity: false)
        let fingerPoint = (touches.first?.locationInView(self))!
        processBegin(fingerPoint)
        self.lastPointRadius = self.centerDistance
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let fingerPoint = (touches.first?.locationInView(self))!
        if isGetPoint {
            processMove(fingerPoint)
        } else {
            processBegin(fingerPoint)
        }
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let fingerPoint = (touches.first?.locationInView(self))!
        processEnd(fingerPoint)
        isGetPoint = false
        self.lastPointRadius = self.centerDistance/2
        self.setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.setNeedsDisplay()
    }
}
