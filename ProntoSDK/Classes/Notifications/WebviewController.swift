//
//  WebviewController.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import EasyPeasy

/// The WebView to open when a push notification is received
open class WebviewController: UIViewController {
    lazy var webView = WKWebView()
    private var webViewNavigationDelegate: WebviewControllerNavigationDelegate! // swiftlint:disable:this weak_delegate
    lazy var loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    lazy var errorLabel = UILabel()

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// :nodoc:
    override open func viewDidLoad() {
        super.viewDidLoad()
        _setup()
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "✕",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(_dismiss))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 30)
            ], for: .normal)

        view.clipsToBounds = false
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        loadingIndicator.hidesWhenStopped = true

        webView.easy.layout(Edges())

        errorLabel.easy.layout([
            Left(20),
            Right(20),
            Top(30),
            Height(>=0)
        ])

        loadingIndicator.easy.layout([
            CenterX(),
            Size(20),
            Top(30)
        ])
    }
    
    private func _setup() {
        if webViewNavigationDelegate != nil {
            return
        }
        webViewNavigationDelegate = WebviewControllerNavigationDelegate(webViewController: self)
        webView.navigationDelegate = webViewNavigationDelegate
    }
    
    /// Load a particular URL into the web view
    ///
    /// - Parameters:
    ///   - urlRequest: `URLRequestz
    public func load(urlRequest: URLRequest) {
        _setup()
        ProntoLogger.debug("Load url: \(urlRequest.url?.absoluteString ?? "(nil)")")
        webView.isHidden = false
        webView.load(urlRequest)
        loadingIndicator.startAnimating()
        errorLabel.isHidden = true
    }
    
    @objc
    private func _dismiss() {
        webView.stopLoading()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

private class WebviewControllerNavigationDelegate: NSObject, WKNavigationDelegate {
    fileprivate weak var webViewController: WebviewController!
    fileprivate convenience init(webViewController: WebviewController) {
        self.init()
        self.webViewController = webViewController
    }
    
    private func _show(error: Error) {
        ProntoLogger.error("Error loading url \(self.webViewController.webView.url?.absoluteString ?? ""): \(error)")
        let headerText = "Error\n\n"
        let bodyText = "Error loading page.\n\(error.localizedDescription)"
        let str = headerText + bodyText
        let attrStr = NSMutableAttributedString(string: str)
        attrStr.addAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: NSRange(location: 0, length: headerText.count))
        
        attrStr.addAttributes([
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 17)
            ], range: NSString(string: str).range(of: bodyText))
        
        webViewController.errorLabel.attributedText = attrStr
        
        webViewController.loadingIndicator.stopAnimating()
        webViewController.errorLabel.isHidden = false
        webViewController.webView.isHidden = true
    }
    
    fileprivate func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
                             withError error: Error) {
        _show(error: error)
    }
    
    fileprivate func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        _show(error: error)
    }
    
    fileprivate func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewController.loadingIndicator.stopAnimating()
    }
}
