//  MessageCenterSetupViewModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/26.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MessageCenterSetupViewModel.h"
#import "MessageCenterSetupCellModel.h"
#import "GosDevManager.h"

@implementation MessageCenterSetupViewModel
- (MessageCenterSetupCellModel *)convertDataBaseToCellModel:(DevDataModel *)dataBase {
    MessageCenterSetupCellModel *model = [[MessageCenterSetupCellModel alloc] init];
    
    return model;
    
}
- (NSArray *)generateTableDataArray {
    return [NSArray array];
}
@end
