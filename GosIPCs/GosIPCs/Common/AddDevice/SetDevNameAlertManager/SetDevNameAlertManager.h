//
//  SetDevNameAlertManager.h
//  Goscom
//
//  Created by 罗乐 on 2019/1/3.
//  Copyright © 2019 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DevDataModel;

@interface SetDevNameAlertManager : NSObject
@property (nonatomic, strong) DevDataModel *deviceModel;

@property (nonatomic, strong) void (^resultBlock)(BOOL isSuccess);

- (void)showRenameAlertWithViewController:(UIViewController *)vc;
@end
