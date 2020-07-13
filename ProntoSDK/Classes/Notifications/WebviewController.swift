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

/// The WebView to open when a push notification is received
open class WebviewController: UIViewController {
    lazy var webView = WKWebView()
    private var webViewNavigationDelegate: WebviewControllerNavigationDelegate! // swiftlint:disable:this weak_delegate
    lazy var loadingIndicator = UIActivityIndicatorView(style: .gray)
    lazy var errorLabel = UILabel()

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nibBundleOrNil)
    }

    /// :nodoc:
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
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false        
        
        NSLayoutConstraint.activate([
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        ])
        
        NSLayoutConstraint.activate([
            errorLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            errorLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 20),
            errorLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30),
            errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 20),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 20),
            loadingIndicator.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30)
        ])
    }
    
    /// :nodoc:
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        ProntoLogger?.debug("Load url: \(urlRequest.url?.absoluteString ?? "(nil)")")
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
        ProntoLogger?.error("Error loading url \(self.webViewController.webView.url?.absoluteString ?? ""): \(error)")
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
