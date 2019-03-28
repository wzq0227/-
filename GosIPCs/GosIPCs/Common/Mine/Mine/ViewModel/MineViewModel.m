//  MineViewModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineViewModel.h"
#import "MineCellModel.h"
#import "AboutViewController.h"
#import "FeedbackViewController.h"
#import "MineSetupViewController.h"
#import "MessageCenterViewController.h"
#import "ExperienceCenterViewController.h"
#import "CloudStoreViewController.h"
#import "MineWebViewController.h"
#import "MessageListViewController.h"

@implementation MineViewModel
- (NSArray *)generateTableDataArray {
    return @[
             @[
                 // 体验中心
                 [MineCellModel cellModelWithMark:MineCellMarkExperienceCenter title:@"Mine_ExperienceCenter" separatorType:MineCellSeparatorTypeBottom accessoryType:MineCellAccessoryTypeArrow clickAction:^id (id hook) {
                     return [[ExperienceCenterViewController alloc] init];
                 }],
                 // 消息中心
                 [MineCellModel cellModelWithMark:MineCellMarkMessageCenter title:@"Mine_MessageCenter" separatorType:MineCellSeparatorTypeBoth accessoryType:MineCellAccessoryTypeArrow clickAction:^id (id hook) {
//                     return [[MessageCenterViewController alloc] init];
                     MessageListViewController *vc = [[MessageListViewController alloc] init];
                     vc.isOnlyShowOnDevMsg = NO;
                     return vc;
                 }],
                 // 云服务订阅
                 [MineCellModel cellModelWithMark:MineCellMarkCloudSubscription title:@"Mine_CloudSubscription" separatorType:MineCellSeparatorTypeTop accessoryType:MineCellAccessoryTypeArrow clickAction:nil]
                 ],
             @[
                 // 意见反馈
                 [MineCellModel cellModelWithMark:MineCellMarkAdviceFeedback title:@"Mine_AdviceFeedback" separatorType:MineCellSeparatorTypeBottom accessoryType:MineCellAccessoryTypeArrow clickAction:^id (id hook) {
                     return [[FeedbackViewController alloc] init];
                 }],
                 // FAQ
                 [MineCellModel cellModelWithMark:MineCellMarkFAQ title:@"Mine_FAQ" separatorType:MineCellSeparatorTypeBoth accessoryType:MineCellAccessoryTypeArrow clickAction:^id (id hook) {
                     return [[MineWebViewController alloc] initWithMineWebDestination:MineWebDestinationFAQ];
                 }],
                 // 关于
                 [MineCellModel cellModelWithMark:MineCellMarkAbout title:@"Mine_About" separatorType:MineCellSeparatorTypeTop accessoryType:MineCellAccessoryTypeArrow clickAction:^id (id hook) {
                     return [[AboutViewController alloc] init];
                 }],
                 ],
             @[
                 // 设置
                 [MineCellModel cellModelWithMark:MineCellMarkMineSetup title:@"Mine_Setup" separatorType:MineCellSeparatorTypeNone accessoryType:MineCellAccessoryTypeArrow clickAction:^id (id hook) {
                     return [[MineSetupViewController alloc] init];
                 }],
                 ],
             ];
}
@end
