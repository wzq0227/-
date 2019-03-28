//
//  CountDownCover.h
//  ULife3.5
//
//  Created by shenyuanluo on 2018/5/17.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FinishBlock)(BOOL isTimeEnd);

@interface CountDownCover : UIView


+ (void)showTime:(NSInteger)cdDuration
          finish:(FinishBlock)block;

+ (void)dismiss;

@end
