//  MineSetupViewModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineSetupViewModel.h"
#import "MineCellModel.h"
#import "ModifyLoginPasswordViewController.h"

@implementation MineSetupViewModel
- (NSArray *)generateTableDataArray {
    return @[
             // 修改个人登录密码
             [MineCellModel cellModelWithTitle:@"Mine_ModifyLoginPassword"
                                separatorType:MineCellSeparatorTypeNone
                                 accessoryType:MineCellAccessoryTypeArrow
                                   clickAction:^id(id hook) {
                                   return [[ModifyLoginPasswordViewController alloc] init];
                                   }],
                 
             ];
}
@end
