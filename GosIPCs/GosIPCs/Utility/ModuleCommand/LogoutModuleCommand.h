//  LogoutModuleCommand.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import "ModuleCommand.h"

NS_ASSUME_NONNULL_BEGIN

/**
 注销功能
 */
@interface LogoutModuleCommand : ModuleCommand
- (void)execute;
@end

NS_ASSUME_NONNULL_END
