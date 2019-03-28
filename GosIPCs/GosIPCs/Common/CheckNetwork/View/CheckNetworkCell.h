//  CheckNetworkCell.h
//  Goscom
//
//  Create by 匡匡 on 2019/1/7.
//  Copyright © 2019 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@class CheckNetResultModel;
NS_ASSUME_NONNULL_BEGIN

@interface CheckNetworkCell : UITableViewCell
/// cell数据模型
@property (nonatomic, strong) CheckNetResultModel * cellModel;
+ (instancetype)cellWithTableView:(UITableView *) tableView
                         indexPath:(NSIndexPath *) indexPath
                         cellModel:(CheckNetResultModel *) cellModel;

@end

NS_ASSUME_NONNULL_END
