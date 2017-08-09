//
//  ViewController.swift
//  SwiftWebViewDemo
//
//  Created by JasonHao on 2017/8/4.
//  Copyright © 2017年 JasonHao. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIWebViewDelegate {

    var loadingProgressV:UIProgressView = UIProgressView()//加载进度
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        
        let btn:UIButton = UIButton.init(frame: CGRect.init(x: 60, y: 100, width: 100, height: 100))
        btn.setTitle("跳转百度", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    func btnClick() {
        let jasonWVC:JasonHWebViewController = JasonHWebViewController()
        jasonWVC.url = "https://www.baidu.com"
        jasonWVC.canDownRefresh = true
        self.navigationController?.pushViewController(jasonWVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

