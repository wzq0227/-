//
//  MsgSettingListTableViewCell.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgSettingModel.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^PushSwitchActionBlock)(BOOL isOn);

@interface MsgSettingListTableViewCell : UITableViewCell

@property (nonatomic, readwrite, strong) MsgSettingModel *msgSettingListCellData;
@property (nonatomic, readwrite, assign) BOOL isHiddenSeperateLine;
@property (nonatomic, readwrite, copy) PushSwitchActionBlock switchAction;

@end

NS_ASSUME_NONNULL_END
