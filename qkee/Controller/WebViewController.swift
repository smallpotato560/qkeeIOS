//
//  WebViewController.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/8/24.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    
    @IBOutlet var myProgressView: UIProgressView!
    @IBOutlet var myWebView: WKWebView!
    @IBOutlet var myView: UIView!
    var urlStr = ""
    var backsegue = ""
    

    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: CGFloat(0), y: CGFloat(-2), width: UIScreen.main.bounds.width, height: 2))
        self.progressView.tintColor = ColorFuntion.hexStringToUIColor(hex: "#fb635d")      // 進度條顏色
        self.progressView.trackTintColor = UIColor.white // 進度條背景色
        self.progressView.progress = 0
        return self.progressView
    }()
    
    lazy private var webview: WKWebView = {
            self.webview = WKWebView.init(frame: self.view.bounds)
            self.webview.uiDelegate = self
            self.webview.navigationDelegate = self
            return self.webview
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myView.addSubview(webview)
        myView.addSubview(progressView)
        
        print("url:\(urlStr)")
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webview.load(URLRequest.init(url: URL.init(string: urlStr)!))
    }
    
    @IBAction func backButtonPress(_ seder: Any) {
        self.navigationController?.popViewController(animated: true) 
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 載入進度
        if keyPath == "estimatedProgress" {
            print("當前進度: \(webview.estimatedProgress)")
            progressView.alpha = 1.0
            progressView.setProgress(Float(webview.estimatedProgress), animated: true)
            //self.myProgressView.isHidden = false
            //myProgressView.progress = Float(webview.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("開始加載")
    }
        
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("開始獲取網頁內容")
    }
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("加載完成")
        progressView.alpha = 0
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("加載失敗")
    }
}
