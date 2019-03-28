//
//  SensitivitySettingCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSConfigSDK.h"
@class MotionDetectModel;

@protocol SensitivitySettingDelegate <NSObject>

-(void)sensitivitySettingDidUpdate:(DetectLevel)tlevel;

@end
@interface SensitivitySettingCell : UITableViewCell
@property (nonatomic, assign) DetectLevel tlevel;   // 灵敏度
@property (nonatomic, weak) id <SensitivitySettingDelegate> delegate;
+ (instancetype)cellModelWithTableView:(UITableView *)tableView
                             indexPath:(NSIndexPath *) indexPath
                           detectLevel:(DetectLevel) tlevel
                              delegate:(id<SensitivitySettingDelegate>) delegate;

@end
