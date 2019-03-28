//  ThirdAccessViewModel.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/7.
//  Copyright © 2018 goscam. All rights reserved.

#import "ThirdAccessViewModel.h"


@implementation ThirdAccessViewModel
#pragma mark - 处理三方接入数据
+ (NSArray *)initDataArrWithAbility:(AccessThirdPartySupport) thirdPartySupport{
    NSMutableArray * mutArr = [[NSMutableArray alloc] init];
    
    if ( (thirdPartySupport &0x2) == AccessThirdPartySupport_Show
        || (thirdPartySupport &0x1) == AccessThirdPartySupport_Echo){
        ThirdAccessModel * model = [[ThirdAccessModel alloc] init];
        model.imgStr = @"logo_alexa";
        model.jumpBtnStr = DPLocalizedString(@"ThirdParty_Btn_Alexa_Title");
        model.alexaStr = [NSURL URLWithString:@"https://skills-store.amazon.com/deeplink/dp/B07D74ZW4W?deviceType=app&share&refSuffix=ss_copy"];
        model.settingStr = [NSURL URLWithString:@"http://ulifecam.com/userguide"];
        [mutArr addObject:model];
    }
    
     if ((thirdPartySupport & 0x4 ) == AccessThirdPartySupport_GoogleHome ) {
         ThirdAccessModel * model = [[ThirdAccessModel alloc] init];
         model.imgStr = @"logo_google_assistant";
         model.jumpBtnStr = DPLocalizedString(@"ThirdParty_Btn_GoogleHome_Title");
         model.alexaStr = [NSURL URLWithString:@"https://skills-store.amazon.com/deeplink/dp/B07D74ZW4W?deviceType=app&share&refSuffix=ss_copy"];
         model.settingStr = [NSURL URLWithString:@"http://ulifecam.com/userguide"];
         [mutArr addObject:model];
     }
    return mutArr;
}
@end
