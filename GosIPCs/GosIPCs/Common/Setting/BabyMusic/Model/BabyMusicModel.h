//  BabyMusicModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/5.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "iOSConfigSDKDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface BabyMusicModel : NSObject
/// 音乐名
@property (nonatomic, strong) NSString * titleStr;
/// 是否选中
@property (nonatomic, assign, getter=isOn) BOOL on;
/// 摇篮曲序号
@property (nonatomic, assign) LullabyNumber lullabyNumber;   
@end

NS_ASSUME_NONNULL_END
