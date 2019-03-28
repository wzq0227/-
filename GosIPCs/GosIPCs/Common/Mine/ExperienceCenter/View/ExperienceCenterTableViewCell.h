//  ExperienceCenterTableViewCell.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ExperienceCenterCellModel;
@interface ExperienceCenterTableViewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView model:(ExperienceCenterCellModel *)model;

+ (CGFloat)cellHeightWithModel:(ExperienceCenterCellModel *)model;
@end

NS_ASSUME_NONNULL_END
