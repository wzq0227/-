//  MineCellModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineCellModel.h"

@implementation MineCellModel
+ (instancetype)cellModelWithTitle:(NSString *)title separatorType:(MineCellSeparatorType)separatorType accessoryType:(MineCellAccessoryType)accessoryType clickAction:(MineCellClickActionBlock)cellAction {
    return [MineCellModel cellModelWithMark:0 title:title separatorType:separatorType accessoryType:accessoryType clickAction:cellAction];
}
+ (instancetype)cellModelWithMark:(NSInteger)mark
                            title:(NSString *)title
                   separatorType:(MineCellSeparatorType)separatorType
                    accessoryType:(MineCellAccessoryType)accessoryType
                      clickAction:(MineCellClickActionBlock)cellAction {
    
    MineCellModel *model = [[MineCellModel alloc] init];
    model.cellMark = mark;
    model.titleText = DPLocalizedString(title);
    model.separatorType = separatorType;
    model.accessoryType = accessoryType;
    model.cellClickActionBlock = [cellAction copy];
    return model;
}

@end
