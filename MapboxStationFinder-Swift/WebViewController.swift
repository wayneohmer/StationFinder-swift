//
//  WebViewController.swift
//  MapboxStationFinder-Swift
//
//  Created by Wayne Ohmer on 5/12/15.
//  Copyright (c) 2015 Wayne Ohmer. All rights reserved.
//


class WebViewController: UIViewController {
    
    internal var stationURL:NSURL?
    var webView: UIWebView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = UIWebView(frame: self.view.bounds)
        self.webView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.view.addSubview(self.webView!)

        let request = NSURLRequest(URL: self.stationURL!)
        self.webView.loadRequest(request)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action:"doneButtonPressed:")
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
