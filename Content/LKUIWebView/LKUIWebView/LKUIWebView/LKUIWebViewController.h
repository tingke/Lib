//
//  LKUIWebViewController.h
//  LKUIWebView
//
//  Created by Tinker on 2017/5/16.
//  Copyright © 2017年 Tinker. All rights reserved.
//
/*解决的问题：
 1.版本适配（UIWebView&&WKWebView）
 2.导航按钮快捷设置（返回&&关闭）
 3.修复自定义导航按钮侧滑手势失效问题
 4.侧滑手势返回上层网页功能 - UIWebView手势失效
 5.网页加载进度显示 - WKWebView监听进度,UIWebView制作假进度
 6.网页下拉刷新 - iOS10.0以后支持下拉刷新
 7.请求异常占位图*/

#import <UIKit/UIKit.h>

@interface LKUIWebViewController : UIViewController

@property (nonatomic, strong) NSString *url;

@property (nonatomic, assign) BOOL canPullDownRefresh;

@property (nonatomic, assign) CGFloat version;  // 测试属性

@end
