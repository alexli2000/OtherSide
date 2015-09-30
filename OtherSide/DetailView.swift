//
//  WebView.swift
//  OtherSide
//
//  Created by Alexander Li on 2015-09-15.
//  Copyright © 2015 Alexander Li. All rights reserved.
//

import UIKit
import WebKit

class DetailView: UIViewController, WKUIDelegate {

    var webView: WKWebView?
    var searchText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addWebView()
        addBackButton()
    }
    
    func addWebView() {
        self.webView = WKWebView(frame: self.view.bounds)
        view.addSubview(webView!)
        webView?.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.google.com/search?q=\(searchText)")!))
    }
    
    func addBackButton() {
        let backButton = UIButton(frame: CGRectMake(20, 20, 50, 50))
        backButton.setImage(UIImage(named: "Map Marker-100"), forState: .Normal)
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.layer.cornerRadius = backButton.frame.width / 2
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.redColor().CGColor
        backButton.addTarget(self, action: "dismissWebView", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)
    }
    
    func dismissWebView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
