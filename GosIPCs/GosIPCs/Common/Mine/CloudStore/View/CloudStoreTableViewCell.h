//  CloudStoreTableViewCell.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CloudStoreCellModel;
@interface CloudStoreTableViewCell : UITableViewCell
/// 初始化
+ (instancetype)cellWithTableView:(UITableView *)tableView model:(CloudStoreCellModel *)model;
/// 返回cell高度
+ (CGFloat)cellHeightWithModel:(CloudStoreCellModel *_Nullable)model;
@end

NS_ASSUME_NONNULL_END
