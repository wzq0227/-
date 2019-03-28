//  CheckNetworkFootView.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/7.
//  Copyright © 2019 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "CheckNetResultModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface CheckNetworkFootView : UIView
/// 检测状态
@property (nonatomic, assign) checkNetState checkNetState;
/// NOTE: 重新测试 重新添加
@property (weak, nonatomic) IBOutlet UIButton *addAgainBtn;
/// 信息反馈
@property (weak, nonatomic) IBOutlet UIButton *feedBackInfoBtn;
/// 重新登录 = YES   重新登录 = NO
@property (nonatomic, assign, getter=isLoginAgain) BOOL loginAgain;
@end

NS_ASSUME_NONNULL_END
