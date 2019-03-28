//
//  KKAlertView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/29.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KKAlertView;

//@protocol KKAlertViewDelegate <NSObject>
//
//- (void)alertView:(KKAlertView *)alertView
//    clickedButtonAtIndex:(NSInteger)buttonIndex;
//
//@end



NS_ASSUME_NONNULL_BEGIN

@interface KKAlertView : UIView
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *contentView;

+ (instancetype) shareView;

// Show the alert view in current window
- (void)show;

// Hide the alert view
- (void)hide;
@end

NS_ASSUME_NONNULL_END
