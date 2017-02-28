//
//  ViewController.swift
//  webVCTest
//
//  Created by Jeremy Petter on 2/27/17.
//  Copyright © 2017 Jeremy Petter. All rights reserved.
//

import UIKit
import WebKit
class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {

    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "The Internet"

        toolbarItems = [backButtonItem, forwardButtonItem]
        setNavigationButtonStates()

        let myURL = URL(string: "http://metalab.co")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)

        view.addSubview(statusBarBackgroundView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(false, animated: animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: - Actions

    func back(sender: UIBarButtonItem) {
        webView.goBack()
    }

    func forward(sender: UIBarButtonItem) {
        webView.goForward()
    }

    //MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.panGestureRecognizer.velocity(in: view).y != 0 else {
            return
        }

        enum ScrollViewDirection { case up, down }

        let scrollDirection: ScrollViewDirection = {
            return scrollView.panGestureRecognizer.velocity(in: view).y > 0 ? .up : .down
        }()

        navigationController?.setNavigationBarHidden(scrollDirection == .up, animated: true)
        navigationController?.setToolbarHidden(scrollDirection == .up, animated: true)
        UIApplication.shared.isStatusBarHidden = scrollDirection == .up
        setStatusBarBackground(hidden: scrollDirection == .down)
    }

    //MARK: - WKWebViewControllerDelegate

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        setStatusBarBackground(hidden: true)
        setNavigationButtonStates()
    }

    //MARK: - Accessors

    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.scrollsToTop = true
        webView.scrollView.delegate = self
        return webView
    }()

    lazy var backButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(back))
    }()

    lazy var forwardButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(forward))
    }()

    lazy var statusBarBackgroundView: UIView = {
        var frame = UIApplication.shared.statusBarFrame
        frame.size.height = 0

        let view = UIView(frame: frame)
        view.backgroundColor = .blue
        return view
    }()


    //MARK: - Helper Methods

    func setNavigationButtonStates() {
        backButtonItem.isEnabled = webView.canGoBack
        forwardButtonItem.isEnabled = webView.canGoForward
    }

    func setStatusBarBackground(hidden: Bool) {
        var frame = UIApplication.shared.statusBarFrame
        if hidden == true {
            frame.size.height = 0
        }
        UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration)) {
            self.statusBarBackgroundView.frame = frame
        }
    }

}
