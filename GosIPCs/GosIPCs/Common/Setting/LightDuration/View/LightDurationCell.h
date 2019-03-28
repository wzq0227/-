//
//  LightDurationCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LampDurationModel;
@class LightDurationModel;

@protocol LightDurationCellDelegate <NSObject>
- (void)LightDurationSwitch:(BOOL) isOn;
@end

NS_ASSUME_NONNULL_BEGIN

@interface LightDurationCell : UITableViewCell
@property (nonatomic, weak) id<LightDurationCellDelegate> delegate;
@property (nonatomic, strong) LightDurationModel * cellModel;
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        indexPath:(NSIndexPath *) indexPath
                        cellModel:(LightDurationModel *) cellModel
                         delegate:(id<LightDurationCellDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
