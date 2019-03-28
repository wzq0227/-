//  CheckNetworkHeadView.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/7.
//  Copyright © 2019 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "CheckNetResultModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface CheckNetworkHeadView : UIView
/// checkNetState
@property (nonatomic, assign) checkNetState checkNetState;
/// 设置上行下行d速度
- (void)setUploadStr:(NSString *)uploadStr
             downStr:(NSString *)downStr;
@end

NS_ASSUME_NONNULL_END
