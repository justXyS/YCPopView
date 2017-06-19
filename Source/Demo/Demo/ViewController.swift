//
//  ViewController.swift
//  Demo
//
//  Created by xiaoyuan on 2017/6/17.
//  Copyright © 2017年 YC. All rights reserved.
//

import UIKit
import YCPopView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func click() {
        let alertView = AlertView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        alertView.backgroundColor = UIColor.red
        alertView.show(in: view, posistion: .top(style: .moveIn(bounce: true, alignment: .original)))
    }
}

