//
//  BabyMusicVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AbilityModel;
NS_ASSUME_NONNULL_BEGIN

/**
 音乐播放界面
 */
@interface BabyMusicVC : UIViewController
@property (nonatomic, strong) NSString * deviceID;   // 设备ID
@property (nonatomic, strong) AbilityModel * abilityModel;   // 能力集
@end

NS_ASSUME_NONNULL_END
