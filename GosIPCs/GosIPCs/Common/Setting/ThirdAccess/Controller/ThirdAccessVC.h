//
//  ThirdAccessVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AbilityModel;

NS_ASSUME_NONNULL_BEGIN

/**
 第三方接入界面
 */
@interface ThirdAccessVC : UIViewController
/// 设备能力集
@property (nonatomic, strong) AbilityModel * abilityModel;
@end

NS_ASSUME_NONNULL_END
