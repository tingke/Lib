//
//  NSBundle+Version.m
//  QSWY-Saler
//
//  Created by Tinker on 2017/5/16.
//  Copyright © 2017年 Tinker. All rights reserved.
//

#import "NSBundle+Version.h"
#import <StoreKit/StoreKit.h>

@implementation NSBundle (Version)

- (void)checkVersion{

    // 获取当前版本号
    NSString *currentVersion = [[self infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    // 获取AppStore中版本号
    NSString *bundleId = [[self infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *urlString= [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@",bundleId];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *session = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *searchResult = [dict objectForKey:@"resultCount"];
            switch (searchResult.integerValue) {
                case 0:
                    NSLog(@"AppStore上没有找到此应用！");
                    break;
                case 1:{
                    NSDictionary *versionDict = [[dict objectForKey:@"results"] firstObject];
                    // 版本号
                    NSString *lastVersion = [versionDict objectForKey:@"version"];
                    // 更新信息
                    NSString *releaseNotes= [versionDict objectForKey:@"releaseNotes"];
                    // itunes地址
                    NSString *trackViewUrl= [versionDict objectForKey:@"trackViewUrl"];
                    if ([currentVersion compare:lastVersion options:NSNumericSearch] == NSOrderedAscending) {
                        // 提示更新
                        [self showAlertWithDescription:releaseNotes url:trackViewUrl];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }];
    [session resume];
}

- (void)showAlertWithDescription:(NSString *)desc url:(NSString *)url{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:desc preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂时忽略" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:doneAction];
    [[UIViewController topViewController] presentViewController:alert animated:YES completion:nil];
}

/**
 应用内打开AppStore
 */
+ (void)openInStoreProductViewControllerForAppId:(NSString *)appId
{
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [[UIViewController topViewController] presentViewController:storeProductVC animated:YES completion:nil];
        }
    }];
}

#pragma mark SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
