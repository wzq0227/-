//  MineWebViewModel.m
//  Goscom
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineWebViewModel.h"

@implementation MineWebViewModel
- (void)loadMineWebDestination:(MineWebDestination)destination title:(NSString *__autoreleasing  _Nullable *)title url:(NSURL *__autoreleasing  _Nullable *)url {
    NSString *tempTitle = nil;
    NSString *tempUrlString = nil;
    
    switch (destination) {
        case MineWebDestinationUnknown:
            tempTitle = @"Mine_UnknownWeb";// FIXME: 此时是否要加翻译呢——未知网页
            tempUrlString = nil;
            break;
        case MineWebDestinationUserAgreement:
            tempTitle = @"Mine_UserAgreement";
            tempUrlString = [NSString userAgreementURLString];
            break;
        case MineWebDestinationFAQ:
            tempTitle = @"Mine_FAQ";
            tempUrlString = [NSString faqURLString];
            break;
        default:
            break;
    }
    
    *title = DPLocalizedString(tempTitle);
    *url = [NSURL URLWithString:tempUrlString];
}
@end



@implementation NSString (GosURLString)

+ (NSString *)userAgreementURLString {
    return @"http://ulifecam.com/common/user-agreements.html";
}

+ (NSString *)faqURLString {
    return @"http://www.ulifecam.com/FAQ/index.htm";
}

@end
