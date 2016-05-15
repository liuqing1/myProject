//
//  ViewController.swift
//  MockAlipay
//
//  Created by Matthew Mayer on 08/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lbl:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        changeURL()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changeURL"), name: "URL", object: nil)
    }
    func changeURL() {
        if let ad = UIApplication.sharedApplication().delegate as? AppDelegate {
            lbl.text = ad.URL
        }
    }
    @IBAction func didAccept() {
        UIApplication.sharedApplication().openURL(NSURL(string:"fiti:dummyacceptpayment")!)
    }
    @IBAction func didReject() {
        UIApplication.sharedApplication().openURL(NSURL(string:"fiti:dummyrejectpayment")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

