//
//  LKUICheckVersionTool.m
//  LKUI
//
//  Created by Tinker on 17/1/13.
//  Copyright © 2017年 Tinker. All rights reserved.
//

#import "LKUIVersionTool.h"
#import <StoreKit/StoreKit.h>

@interface LKUIVersionTool ()

@end

@implementation LKUIVersionTool

+ (void)checkVersion{
    
    // 获取当前版本号
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    // 获取AppStore中版本号
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
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
                    LKUIVersionModel *model = [LKUIVersionModel objectForDictionary:versionDict];
                    NSString *lastVersion = model.version;
                    if ([currentVersion compare:lastVersion options:NSNumericSearch] == NSOrderedAscending)    {   // 提示更新
                        [self showAlertWithModel:model];
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

+ (void)showAlertWithModel:(LKUIVersionModel *)model{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:model.releaseNotes preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:model.trackViewUrl]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.trackViewUrl]];
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

@implementation LKUIVersionModel

+ (instancetype)objectForDictionary:(NSDictionary *)dictionnary{
    return [LKUIVersionModel mj_objectWithKeyValues:dictionnary];
}

@end
