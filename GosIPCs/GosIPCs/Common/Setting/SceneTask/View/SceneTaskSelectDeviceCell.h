//  SceneTaskSelectDeviceCell.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@class SceneTaskModel;
NS_ASSUME_NONNULL_BEGIN

@interface SceneTaskSelectDeviceCell : UITableViewCell
/// cell模型
@property (nonatomic, strong) SceneTaskModel * cellModel;
+ (instancetype) cellWithTableView:(UITableView *) tableView
                    cellModel:(SceneTaskModel *) cellModel;
@end

NS_ASSUME_NONNULL_END
