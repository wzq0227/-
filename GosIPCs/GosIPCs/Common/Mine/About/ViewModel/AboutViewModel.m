//  AboutViewModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "AboutViewModel.h"
#import "MineCellModel.h"
#import "MineWebViewController.h"

@implementation AboutViewModel
- (NSArray *)generateTableDataArray {
    return @[
             // 用户协议
             [MineCellModel cellModelWithText:@"UserAgreement" accessoryType:UITableViewCellAccessoryDisclosureIndicator cellTurnToBlock:^UIViewController *{
                 return [[MineWebViewController alloc] initWithMineWebDestination:MineWebDestinationUserAgreement];
             } cellClickActionBlock:nil],
             ];
}
@end
