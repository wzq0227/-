//  MineWebViewController.h
//  Goscom
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "MineWebViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MineWebViewController : UIViewController
/// 目标网页标记
@property (nonatomic, readonly, assign) MineWebDestination mineWebDestination;

/**
 初始化方法

 @param destination 目标网页标记
 @return MineWebViewController
 */
- (instancetype)initWithMineWebDestination:(MineWebDestination)destination;
@end

NS_ASSUME_NONNULL_END
