//  MessageCenterTableViewCell.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/4.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MessageCenterCellModel;

@interface MessageCenterTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(MessageCenterCellModel *)model;
+ (CGFloat)cellHeightWithModel:(MessageCenterCellModel *)model;
@end

NS_ASSUME_NONNULL_END
