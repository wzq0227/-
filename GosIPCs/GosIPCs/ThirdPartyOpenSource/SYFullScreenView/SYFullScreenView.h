//
//  SYFullScreenView.h
//  SYFullScreenViewExample
//
//  Created by shenyuanluo on 2017/8/22.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SYFullScreenViewDeleaget <NSObject>
- (void)curDevOrientation:(UIDeviceOrientation)orientation;
@end


@interface SYFullScreenView : UIView
@property (nonatomic, readwrite, weak) id<SYFullScreenViewDeleaget>delegate;

@end
