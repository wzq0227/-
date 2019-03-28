//  MineViewModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "MineViewModelDelegate.h"

typedef NS_ENUM(NSInteger, MineCellMark) {
    MineCellMarkExperienceCenter,   // 体验中心
    MineCellMarkMessageCenter,      // 消息中心
    MineCellMarkCloudSubscription,  // 云服务订阅
    MineCellMarkAdviceFeedback,     // 意见反馈
    MineCellMarkFAQ,                // FAQ
    MineCellMarkAbout,              // 关于
    MineCellMarkMineSetup,          // 设置
    MineCellMarkLogout,             // 注销
};

NS_ASSUME_NONNULL_BEGIN

@interface MineViewModel : NSObject <MineViewModelDelegate>

- (NSArray *)generateTableDataArray;

@end

NS_ASSUME_NONNULL_END
