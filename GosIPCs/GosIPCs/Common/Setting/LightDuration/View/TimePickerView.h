//  TimePickerView.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "LightDurationVC.h"
@class LampDurationModel;
@protocol TimePickerViewDelegate <NSObject>

-(void) timePickerFinish;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TimePickerView : UIView
/// 代理
@property (nonatomic, weak) id<TimePickerViewDelegate> delegate;
/// ttable数组数据
@property (nonatomic, strong) NSArray * tableDataArr;
/// 灯照时长模型
@property (nonatomic, strong) LampDurationModel * lampDurationModel;
/// 开始/结束时间
@property (nonatomic, assign) OnOffTimeType onOffTimeType;
+ (instancetype)sharePickerViewWithTimeType:(OnOffTimeType) onOffTimeType
                               tableDataArr:(NSArray *) tableDataArr
                          lampDurationModel:(LampDurationModel *) lampDurationModel
                                   delegate:(id<TimePickerViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
