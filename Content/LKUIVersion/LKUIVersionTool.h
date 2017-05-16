//
//  LKUICheckVersionTool.h
//  LKUI
//
//  Created by Tinker on 17/1/13.
//  Copyright © 2017年 Tinker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKUIVersionTool : NSObject

+ (void)checkVersion;

@end

@interface LKUIVersionModel : NSObject
/** 版本号 */
@property (nonatomic, copy) NSString *version;
/** 更新信息 */
@property (nonatomic, copy) NSString *releaseNotes;
/** AppId */
@property(nonatomic,copy)NSString *trackId;
/** App名称 */
@property(nonatomic,copy)NSString *trackName;
/** itunes地址 */
@property(nonatomic,copy)NSString *trackViewUrl;
/** bundleId */
@property(nonatomic,copy)NSString *bundleId;

+ (instancetype)objectForDictionary:(NSDictionary *)dictionnary;

@end
