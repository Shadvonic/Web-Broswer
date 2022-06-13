//
//  ViewController.swift
//  Web-Browser
//
//  Created by Marc Moxey on 5/18/22.
//

import UIKit
import WebKit


class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["github.com", "apple.com"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        let back = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
        
        
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))
        
        //create new UIProgressView instance
        progressView = UIProgressView(progressViewStyle: .default)
        //set layout size
        progressView.sizeToFit()
        //create new UIBarItem with a customView
        let progressButton = UIBarButtonItem(customView: progressView)
        
        
        //array of our spacer and refresh
        toolbarItems = [back, forward, spacer, progressButton, refresh]
        //set to be toolbar
        navigationController?.isToolbarHidden = false
        
        //who the observer is
        //what property you want to observer
        //which value you want
        //
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    
    @objc func openTapped(){
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        

        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        guard let url = URL(string: "https://" +  actionTitle) else { return }
        webView.load(URLRequest(url: url))
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func blockAlert() {
        let ac =
        UIAlertController(title: "Blocked", message: "This website is blocked", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //check if  website on safe list
        let url = navigationAction.request.url
        
        //unwrap value of url
        if let host = url?.host {
            //loop through all sites in list
            for website in websites {
                //check if website contain in host name
                if host.contains(website) {
                    //return positive
                    decisionHandler(.allow)
                    //safely return
                    return
                } else if (host.contains(website) && website == "tiktok.com") || (host.contains(website) && website == "youtube.com") {
                    blockAlert()
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        //return negative response
        decisionHandler(.cancel)
    }
    


    
}

