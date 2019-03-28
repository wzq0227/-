//
//  ThirdAccessCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ThirdAccessModel;

@protocol ThirdAccessCellDelegate <NSObject>
@optional;
- (void)thirdAccessJumpClick:(NSURL *) jumpUrl;
@end

NS_ASSUME_NONNULL_BEGIN
@interface ThirdAccessCell : UITableViewCell
/// 代理
@property (nonatomic, weak) id<ThirdAccessCellDelegate> delegate;
/// 数据模型
@property (nonatomic, strong) ThirdAccessModel * cellModel;
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        indexPath:(NSIndexPath *) indexPath
                        cellModel:(ThirdAccessModel *) cellModel
                         delegate:(id<ThirdAccessCellDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
