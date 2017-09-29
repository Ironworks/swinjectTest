//
//  ViewController.swift
//  SwinjectTest
//
//  Created by Trevor Doodes on 20/08/2017.
//  Copyright © 2017 Ironworks Media Limited. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.snp.makeConstraints { (make) in
            make.edges.equalTo(view.superview!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

