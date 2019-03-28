//  UIWebView+LoadGif.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/4.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWebView (LoadGif)
//+(instancetype) shareWebView;
-(void) loadGifWithString:(NSString *) gifString;
@end

NS_ASSUME_NONNULL_END
