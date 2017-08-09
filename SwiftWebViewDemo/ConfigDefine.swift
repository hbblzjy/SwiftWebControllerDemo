//
//  ConfigDefine.swift
//  SwiftWebViewDemo
//
//  Created by JasonHao on 2017/8/4.
//  Copyright © 2017年 JasonHao. All rights reserved.
//

import Foundation
import UIKit

//屏幕宽
let Screen_Width:CGFloat = UIScreen.main.bounds.size.width
//屏幕高
let Screen_Height:CGFloat = UIScreen.main.bounds.size.height
//导航高
let Navi_Height:CGFloat = 64
//当前版本，类型转换，要找对正确类型，然后执行此类型下的方法
let Device_System:CGFloat = CGFloat((UIDevice.current.systemVersion as NSString).floatValue)
