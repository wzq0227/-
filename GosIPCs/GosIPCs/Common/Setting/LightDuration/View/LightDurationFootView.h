//
//  LightDurationFootView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LampDurationModel;

@protocol LightDurationFootViewDelegate <NSObject>

-(void) lightDurationSelectDay:(int) selectDay;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LightDurationFootView : UIView
/// 代理
@property (nonatomic, weak) id<LightDurationFootViewDelegate> delegate;
/// 模型
@property (nonatomic, strong) LampDurationModel * lampDurationModel;
@end

NS_ASSUME_NONNULL_END
