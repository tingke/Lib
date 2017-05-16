//
//  ViewController.m
//  LKUIWebView
//
//  Created by Tinker on 2017/5/16.
//  Copyright © 2017年 Tinker. All rights reserved.
//

#import "ViewController.h"
#import "LKUIWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showUIWebView:(UIButton *)sender {
    
    LKUIWebViewController *vc = [[LKUIWebViewController alloc]init];
    vc.url = @"http://www.baidu.com";
    vc.canPullDownRefresh = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)showWKWebView:(UIButton *)sender {
    
    LKUIWebViewController *vc = [[LKUIWebViewController alloc]init];
    vc.url = @"http://www.baidu.com";
    vc.canPullDownRefresh = YES;
    vc.version = 10.0;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
