//  ExperienceCenterViewModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "ExperienceCenterViewModel.h"
#import "ExperienceCenterCellModel.h"
#import "VRPlayViewController.h"

@implementation ExperienceCenterViewModel
- (NSArray *)generateTableDataArray {
    return @[
             [ExperienceCenterCellModel cellModelWithCellType:ExperienceCenterCellTypeVR360 cellTurnToVCBlock:^UIViewController *{
                 VRPlayViewController *vc = [[VRPlayViewController alloc] initWithDisplayType:VRPlayViewControllerDisplayTypeVR360];

                 return vc;
             }],
             [ExperienceCenterCellModel cellModelWithCellType:ExperienceCenterCellTypeVR180 cellTurnToVCBlock:^UIViewController *{
                 VRPlayViewController *vc = [[VRPlayViewController alloc] initWithDisplayType:VRPlayViewControllerDisplayTypeVR180];
                 
                 return vc;
             }],
             ];
}
@end
