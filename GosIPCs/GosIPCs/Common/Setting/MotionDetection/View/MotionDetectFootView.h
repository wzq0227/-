//
//  MotionDetectFootView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MotionDetectModel;

@protocol MotionDetectFootViewDelegate <NSObject>
- (void)motionFootViewBackData:(MotionDetectModel *)dataModel;
@end


@interface MotionDetectFootView : UIView
@property (nonatomic, strong) MotionDetectModel * modelData;   // 数据模型
@property (nonatomic, weak) id<MotionDetectFootViewDelegate> delegate;
@end
