//
//  ViewController.m
//  10.3新特性：更换应用图标
//
//  Created by Tinker on 2017/4/1.
//  Copyright © 2017年 Tinker. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*注意事项：
 1.更换图片的备用图片不能放置在Assets里
 2.info.plist里添加相关信息
 3.保持文件名的一致性
 */

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    
    if ([UIApplication sharedApplication].supportsAlternateIcons) {
        NSLog(@"系统支持更换App图标");
    }else{
        NSLog(@"系统不支持更换App图标");
    }
    
    // 获取更换备用图标的名称<没有设置为备用图标则为nil>
    NSString *iconName = [UIApplication sharedApplication].alternateIconName;
    NSLog(@"iconName:%@",iconName);
    
//    iconName = @"newIcon";
    
    if (iconName) {
        // 设置回原图标
        [[UIApplication sharedApplication] setAlternateIconName:nil completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"error:%@",error);
            }
        }];
        
    }else{
        // 设置为备用图标
        [[UIApplication sharedApplication] setAlternateIconName:@"newIcon" completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"error:%@",error);
            }
        }];
    }
}


@end
