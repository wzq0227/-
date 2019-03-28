//
//  RegisterViewController.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegisterViewController : UIViewController

@property (nonatomic, readwrite, assign) LoginServerArea loginArea;
@property (nonatomic, readwrite, assign) BOOL hasNetwork;   // 是否有网络连接

@end

NS_ASSUME_NONNULL_END
