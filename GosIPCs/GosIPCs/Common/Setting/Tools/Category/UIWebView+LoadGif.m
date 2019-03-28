//  UIWebView+LoadGif.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/4.
//  Copyright © 2018 goscam. All rights reserved.

#import "UIWebView+LoadGif.h"

@implementation UIWebView (LoadGif)
//+(instancetype)shareWebView{
//    
//}
-(void)loadGifWithString:(NSString *)gifString{
    NSString *path = [[NSBundle mainBundle] pathForResource:gifString
                                                     ofType:@"gif"];
    NSURL *url = [NSURL URLWithString:path];
    self.contentScaleFactor       = [UIScreen mainScreen].scale;
    self.opaque                   = NO;
    self.scalesPageToFit          = YES;
    self.scrollView.scrollEnabled = NO;
    self.backgroundColor          = [UIColor clearColor];
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}
@end
