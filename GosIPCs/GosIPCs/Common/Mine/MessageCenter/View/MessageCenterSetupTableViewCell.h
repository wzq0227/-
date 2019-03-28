//  MessageCenterSetupTableViewCell.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/5.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@protocol MessageCenterSetupTableViewCellDelegate <NSObject>

@end
NS_ASSUME_NONNULL_BEGIN
@class MessageCenterSetupCellModel;
@interface MessageCenterSetupTableViewCell : UITableViewCell
@property (nonatomic, weak) id<MessageCenterSetupTableViewCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView model:(MessageCenterSetupCellModel *)model target:(id<MessageCenterSetupTableViewCellDelegate>)target;

+ (CGFloat)cellHeightWithModel:(MessageCenterSetupCellModel *)model;
@end

NS_ASSUME_NONNULL_END
