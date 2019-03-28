//
//  AddSensorHeadView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSensorTypeModel.h"
#import "iOSConfigSDKDefine.h"
@protocol AddSensorHeadViewDelegate <NSObject>

-(void) AddSensorWithType:(GosIOTType) gosIOTType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AddSensorHeadView : UIView

@property (nonatomic, weak) id<AddSensorHeadViewDelegate> delegate;   // 代理
/// type
@property (nonatomic, assign) GosIOTType gosIOTType;
+ (AddSensorHeadView *)headViewWithTypeModel:(AddSensorTypeModel *)sensorTypeModel
                                     delegate:(id<AddSensorHeadViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
