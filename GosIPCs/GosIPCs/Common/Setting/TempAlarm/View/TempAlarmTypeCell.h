//
//  TempAlarmTypeCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TempAlarmModel;
@class TempAlarmTypeCell;
@protocol TempAlarmTypeCellDelegate <NSObject>
-(void) switchStateDidChange:(TempAlarmTypeCell *) cell;
@end
NS_ASSUME_NONNULL_BEGIN

@interface TempAlarmTypeCell : UITableViewCell
@property (nonatomic, strong) TempAlarmModel * dataModel;
@property (nonatomic, weak) id <TempAlarmTypeCellDelegate> delegate;
+(instancetype) cellModelWithTableView:(UITableView *)tableView
                             indexPath:(NSIndexPath *) indexPath
                                 model:(TempAlarmModel *) dataModel
                              delegate:(id<TempAlarmTypeCellDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
