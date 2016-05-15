//
//  WebViewController.swift
//  fiti
//
//  Created by Matthew Mayer on 18/02/2016.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class WebViewController: BaseViewController {
    @IBOutlet weak var webView:UIWebView!;
    var url:NSURL!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .Blue
        setLocalizedTitle("FAQ")
        webView.loadRequest(NSURLRequest(URL: url))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
