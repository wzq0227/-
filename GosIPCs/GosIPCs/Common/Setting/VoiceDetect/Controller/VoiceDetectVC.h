//
//  VoiceDetectVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DevDataModel;
NS_ASSUME_NONNULL_BEGIN
/**
 声音检测界面
 */
@interface VoiceDetectVC : UIViewController

/// 数据模型
@property (nonatomic, strong) DevDataModel * devDataModel;
@end

NS_ASSUME_NONNULL_END
