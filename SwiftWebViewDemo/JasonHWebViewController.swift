//
//  JasonHWebViewController.swift
//  SwiftWebViewDemo
//
//  Created by JasonHao on 2017/8/4.
//  Copyright © 2017年 JasonHao. All rights reserved.
//

import UIKit
import WebKit

class JasonHWebViewController: UIViewController,UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,UIGestureRecognizerDelegate {

    var wkWebV:WKWebView = WKWebView()//iOS8.0之后wkwebView
    var webV:UIWebView = UIWebView()//
    var backBarBtnItem:UIBarButtonItem = UIBarButtonItem()//返回bar
    var closeBarBtnItem:UIBarButtonItem = UIBarButtonItem()//关闭bar
    var delegate:UIGestureRecognizerDelegate?//代理
    var refreshContr:UIRefreshControl = UIRefreshControl()//刷新
    var loadingProgressV:UIProgressView = UIProgressView()//加载进度
    var reloadBtn:UIButton = UIButton()//重新加载按钮
    var canDownRefresh:Bool = Bool()//是否下拉刷新
    var url:NSString = NSString()//链接
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.createWebView()
        self.createNaviItem()
        self.loadRequst()
        
    }
    //MARK: ------ 版本适配
    func createWebView() {
        self.view.addSubview(self._reloadBtn)
        if Device_System >= 8.0 {
            self.view.addSubview(self._wkWebV)
            self.view.addSubview(self._loadingProgressV)
        }else{
            self.view.addSubview(self._webV)
        }
    }
    /**
     //swift中的get方法，可以直接varget或letget显示提示，如果使用的是get方法创建视图，调用添加到父类上的时候，要self._参数，如self._wkWebV，如此就可以看出来这个get方法的名称可以跟全局定义的参数名不一样，建议除了“_”不一样外，字母最好一样
     //letget
     let <#property name#>: <#type name#> = {
     <#statements#>
     return <#value#>
     }()
     //varget
     var <#variable name#>: <#type#> {
     <#statements#>
     }
     //vargetset
     var <#variable name#>: <#type#> {
     get {
     <#statements#>
     }
     set {
     <#variable name#> = newValue
     }
     }
     **/
    //MARK: ------ 创建webView，get方法
    var _webV: UIWebView {
        webV = UIWebView.init(frame:CGRect.init(x:0, y:Navi_Height, width:Screen_Width, height:Screen_Height-Navi_Height))
        webV.delegate = self
        
        if Device_System >= 10.0 && canDownRefresh {
            webV.scrollView.refreshControl = self._refreshContr
        }
        return webV
    }
    //MARK: ------ 创建WKWebView，get方法
    var _wkWebV: WKWebView {
        let configWkWeb:WKWebViewConfiguration = WKWebViewConfiguration.init()
        configWkWeb.preferences = WKPreferences.init()
        configWkWeb.userContentController = WKUserContentController.init()
        wkWebV = WKWebView.init(frame: CGRect.init(x: 0, y: Navi_Height, width: Screen_Width, height: Screen_Height-Navi_Height), configuration: configWkWeb)
        wkWebV.navigationDelegate = self
        wkWebV.uiDelegate = self
        //添加此属性可触发侧滑返回上一网页与下一网页操作
        wkWebV.allowsBackForwardNavigationGestures = true
        //下拉刷新
        if Device_System >= 10.0 && canDownRefresh {
            wkWebV.scrollView.refreshControl = self._refreshContr
        }
        //加载进度监听：观察wkwbview的estimatedProgress属性，从而调节进度条
        wkWebV.addObserver(self, forKeyPath: "estimatedProgress", options: [NSKeyValueObservingOptions.new], context: nil)
        
        return wkWebV
    }
    //MARK: ------ 观察者执行的方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            //取值时，这个地方跟OC中字典取值形式不一样，OC中的是change[@"new"]
            loadingProgressV.progress = change?[NSKeyValueChangeKey.newKey] as! Float
            //print(".......输出数值。。。\(loadingProgressV.progress)")
            if loadingProgressV.progress == 1.0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    self.loadingProgressV.isHidden = true
                })
            }
        }
        //print("66666666")
    }
    //MARK: ------ 创建进度
    var _loadingProgressV: UIProgressView {
        loadingProgressV = UIProgressView.init(frame: CGRect.init(x: 0, y: Navi_Height, width: Screen_Width, height: 2))
//        //如果要添加背景色，需要设置 .bar 样式，然后设置背景色，否则只会默认灰色
//        loadingProgressV.progressViewStyle = .bar
//        loadingProgressV.backgroundColor = UIColor.red
        
        loadingProgressV.progressTintColor = UIColor.green
        return loadingProgressV
    }
    //MARK: ------ 创建刷新
    var _refreshContr: UIRefreshControl {
        refreshContr = UIRefreshControl.init()
        refreshContr.addTarget(self, action: #selector(webViewReload), for: .valueChanged)
        
        return refreshContr
    }
    //刷新方法
    func webViewReload() {
        webV.reload()
        wkWebV.reload()
    }
    //创建button
    var _reloadBtn: UIButton {
        reloadBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 150))
        reloadBtn.center = self.view.center
        reloadBtn.layer.cornerRadius = 75.0
        reloadBtn.setBackgroundImage(UIImage.init(named: "placeholder_error"), for: .normal)
        reloadBtn.setTitle("您的网络有问题，请检查您的网络设置", for: .normal)
        reloadBtn.setTitleColor(UIColor.lightGray, for: .normal)
        //跟OC调用不一样了
        reloadBtn.titleEdgeInsets = UIEdgeInsetsMake(200, -50, 0, -50)
        reloadBtn.titleLabel?.numberOfLines = 0
        reloadBtn.titleLabel?.textAlignment = .center
        var rect:CGRect = reloadBtn.frame
        rect.origin.y -= 100
        reloadBtn.frame = rect
        reloadBtn.isEnabled = false
        
        return reloadBtn
    }
    //MARK: ------ 导航按钮
    func createNaviItem() {
        self.showLeftBarBtnItem()
        self.showRightBarBtnItem()
    }
    //显示左bar
    func showLeftBarBtnItem() {
        if webV.canGoBack || wkWebV.canGoBack {
            self.navigationItem.leftBarButtonItems = [self._backBarBtnItem,self._closeBarBtnItem]
        }else{
            self.navigationItem.leftBarButtonItem = self._backBarBtnItem
        }
    }
    //显示右bar
    func showRightBarBtnItem() {
        //这里可以添加一个举报
        let rightBarBtn:UIBarButtonItem = UIBarButtonItem.init(title: "举报", style: .plain, target: self, action: #selector(rightBarClick))
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    func rightBarClick() {
        print("点击了举报。。。。。。")
    }
    //创建返回bar
    var _backBarBtnItem: UIBarButtonItem {
        backBarBtnItem = UIBarButtonItem.init(title: "返回", style: .plain, target: self, action: #selector(backBarClick))
        
        return backBarBtnItem
    }
    func backBarClick() {
        if webV.canGoBack || wkWebV.canGoBack {
            webV.goBack()
            wkWebV.goBack()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    //创建关闭bar
    var _closeBarBtnItem: UIBarButtonItem {
        closeBarBtnItem = UIBarButtonItem.init(title: "关闭", style: .plain, target: self, action: #selector(closeBarClick))
        
        return closeBarBtnItem
    }
    func closeBarClick() {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: ------ 自定义导航按钮支持侧滑手势处理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.delegate = (self.navigationController?.interactivePopGestureRecognizer?.delegate)!
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self.delegate
    }
    //MARK: ------ UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (self.navigationController?.viewControllers.count)! > 1
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (self.navigationController?.viewControllers.count)! > 1
    }
    //MARK: ------ 加载请求
    func loadRequst() {
        if !(self.url.hasPrefix("http")) {
            //没有http前缀
            self.url = NSString.init(format: "http://%@", self.url)
        }

        //判断版本
        if Device_System >= 8.0 {
            wkWebV.load(URLRequest.init(url: URL.init(string: self.url as String)!))
            //print("444444444")
        }else{
            webV.loadRequest(URLRequest.init(url: URL.init(string: self.url as String)!))
        }
        
    }
    //MARK: ------ UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        webView.isHidden = false
        //不加载空白网址
        if request.url?.scheme == "about" {
            webView.isHidden = true
            return false
        }
        return true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //导航栏标题配置，这里其实用到的JS的代码
        self.navigationItem.title = webView.stringByEvaluatingJavaScript(from: "document.title")
        self.showLeftBarBtnItem()
        refreshContr.endRefreshing()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webView.isHidden = true
    }
    //MARK: ------ WKNavigationDelegate,WKUIDelegate
    //加载状态回调
    //页面开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webView.isHidden = false
        loadingProgressV.isHidden = false
        if webView.url?.scheme == "about" {
            webView.isHidden = true
        }
        //print("1111111111")
    }
    //页面加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //导航栏配置
        webView.evaluateJavaScript("document.title") { (title, error) in
            self.navigationItem.title = title as? String
        }
        
        self.showLeftBarBtnItem()
        refreshContr.endRefreshing()
        
        //print("222222222")
    }
    //页面加载失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = true
        //print("333333333")
        refreshContr.endRefreshing()
    }
    //HTTPS认证
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.previousFailureCount == 0 {
                let credential:URLCredential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential,credential)
            }else{
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge,nil)
            }
        }else{
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge,nil)
        }
    }
    
    //MARK: ------ 释放内存，类似于OC中的：-（void）dealloc
    deinit{
        wkWebV.removeObserver(self, forKeyPath: "estimatedProgress")
        wkWebV.stopLoading()
        webV.stopLoading()
        wkWebV.uiDelegate = nil
        wkWebV.navigationDelegate = nil
        webV.delegate = nil
    }
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
