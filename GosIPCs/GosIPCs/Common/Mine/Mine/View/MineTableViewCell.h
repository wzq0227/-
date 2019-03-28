//  MineTableViewCell.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MineCellModel;

@interface MineTableViewCell : UITableViewCell

/**
 初始化cell方法

 @param tableView tableView
 @param model MineCellModel
 @return MineTableViewCell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView model:(MineCellModel *)model;

+ (CGFloat)cellHeightWithModel:(MineCellModel *_Nullable)model;
@end

NS_ASSUME_NONNULL_END
