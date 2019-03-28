//
//  MotionDetectSwitchCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MotionDetectModel;
@class VoiceMonitonModel;
@protocol MotionDetectSwitchDelegate <NSObject>
- (void)MotionDetectSwitchDidChange:(BOOL)isOn;
@end
NS_ASSUME_NONNULL_BEGIN

@interface MotionDetectSwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *monitSwitch;
@property (nonatomic, strong) VoiceMonitonModel * cellModel;   // 数据模型，声音和运动共用
@property (nonatomic, weak) id <MotionDetectSwitchDelegate> delegate;
/**
 运动检测方法
 */
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        indexPath:(NSIndexPath *) indexPath
                        cellModel:(VoiceMonitonModel *) cellModel
                         delegate:(id<MotionDetectSwitchDelegate>) delegate;



@end

NS_ASSUME_NONNULL_END
