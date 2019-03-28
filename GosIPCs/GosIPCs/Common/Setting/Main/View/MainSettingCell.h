//
//  MainSettingCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainSettingModel;
@class MainSettingCell;
@protocol MainSettingCellDelegate <NSObject>
@optional;
-(void) cellSwitchDidChangeState:(MainSettingCell *) settingCell;

@end
@interface MainSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (nonatomic, strong) MainSettingModel * cellModel;
@property (nonatomic, weak) id<MainSettingCellDelegate> delegate;

+ (instancetype)cellModelWithTableView:(UITableView *) tableView
                             indexPath:(NSIndexPath *) indexPath
                                 model:(MainSettingModel *) cellModel
                              delegate:(id<MainSettingCellDelegate>) delegate;




@end
