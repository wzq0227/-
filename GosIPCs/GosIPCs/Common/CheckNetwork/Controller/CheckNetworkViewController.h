//
//  CheckNetworkViewController.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/19.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckNetworkViewController : UIViewController
/// 重新登录 = YES   重新登录 = NO
@property (nonatomic, assign, getter=isLoginAgain) BOOL loginAgain;
@end

NS_ASSUME_NONNULL_END
