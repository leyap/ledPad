//
//  ViewController.swift
//  ledPad
//
//  Created by LeeYaping on 1/13/16.
//  Copyright © 2016 lisper. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var ble = DFBle.sharedInstance
    var myview:LedPadView = LedPadView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ble.beginScan();
        self.view = myview
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        self.view.addSubview(button)
        button.addTarget(self, action: "action:", forControlEvents: UIControlEvents.TouchUpInside)
        button.backgroundColor = UIColor.greenColor()
        button.setTitle("test", forState: UIControlState.Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //send action
    func action(sender:UIButton) {
        ble.sendCommand(self.myview.selectIndexs)
        print(self.myview.selectIndexs)
        print(ble.peripherals)
    }

}

