//  BabyMusicViewModel.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/5.
//  Copyright © 2018 goscam. All rights reserved.

#import "BabyMusicViewModel.h"
#import "iOSConfigSDK.h"
#import "BabyMusicModel.h"

@implementation BabyMusicViewModel

#pragma mark - 初始化TableArr
+ (NSArray *)initDataWithAbility:(AbilityModel *)abilityModel{
    if (!abilityModel) {
        return nil;
    }
    NSMutableArray * dataSouceArr = [NSMutableArray new];
    NSArray * musicTitleArr;
    NSArray * musicMarkArr;
    switch (abilityModel.lullabyDevType) {
        case LullabyDev_unSupport:{      //  不支持摇篮曲
            musicTitleArr = @[@"unKnow"];
            musicMarkArr = @[@(LullabyNum_unknow)];
        }break;
        case LullabyDev_5886HAB:{         // 5886HAB 系列设备
            musicTitleArr = @[@"twinkle piano",@"little Mozart",@"relax",@"nature",@"Brahms lullaby",@"bedtime lullaby"];
            musicMarkArr = @[@(Lullaby5886HABNum_twinklePiano),@(Lullaby5886HABNum_littleMozart),@(Lullaby5886HABNum_relax),@(Lullaby5886HABNum_nature),@(Lullaby5886HABNum_BrahmsLullaby),@(Lullaby5886HABNum_bedtimeLullaby)];
        }break;
        case LullabyDev_GD8208KE:{        // GD8202KE 系列设备
            musicTitleArr = @[@"I don't want to miss a thing",@"Holiday",@"Jolene",@"Rain",@"Waves",@"Pink Noise"];
            musicMarkArr = @[@(LullabyGD8202KENum_IDontWantToMissAThing),@(LullabyGD8202KENum_Holiday),@(LullabyGD8202KENum_Jolene),@(LullabyGD8202KENum_Rain),@(LullabyGD8202KENum_Waves),@(LullabyGD8202KENum_PinkNoise)];
        }break;
        case LullabyDev_VOXX:{            // VOXX 系列设备
             musicTitleArr = @[@"I don't want to miss a thing",@"Holiday",@"Jolene",@"Rain",@"Waves",@"Pink Noise"];
             musicMarkArr = @[@(LullabyVOXXNum_IDontWantToMissAThing),@(LullabyVOXXNum_Holiday),@(LullabyVOXXNum_Jolene),@(LullabyRCANum_Rain),@(LullabyVOXXNum_Waves),@(LullabyVOXXNum_PinkNoise)];
        }break;
        case LullabyDev_RCA:{             // RCA 系列设备
            musicTitleArr = @[@"Campfire",@"CountryAmbience",@"Jolene",@"Rain",@"Waves",@"WhiteNoise"];
            musicMarkArr = @[@(LullabyRCANum_Campfire),@(LullabyRCANum_CountryAmbience),@(LullabyRCANum_Heartbeat),@(LullabyRCANum_Rain),@(LullabyRCANum_Waves),@(LullabyRCANum_WhiteNoise)];
        }break;
        case LullabyDev_T5810HCA:{        // T5810HCA 系列设备
            musicTitleArr = @[@"birds sream nature forest loop",@"Brahms lullaby",@"relax",@"twinkle piano"];
            musicMarkArr = @[@(LullabyT5810HCANum_BirdsStreamNatureForestLoop),@(LullabyT5810HCANum_BrahmsLullaby),@(LullabyT5810HCANum_Relax),@(LullabyT5810HCANum_twinklePiano)];
        }break;
        default:
            break;
    }
    
    for (int i=0; i < musicTitleArr.count; i++) {
        BabyMusicModel * model = [[BabyMusicModel alloc] init];
        model.titleStr = musicTitleArr[i];
        model.on = NO;
        model.lullabyNumber = [musicMarkArr[i] integerValue];
        [dataSouceArr addObject:model];
    }
    return dataSouceArr;
}

#pragma mark - 返回选中摇篮曲的状态
+ (NSArray *)modifySelectData:(NSArray *) tableArr
                lullabyNumber:(LullabyNumber) lullabyNumber{
    if (!tableArr || tableArr.count < 1 || !lullabyNumber) {
        return @[];
    }
    for (int i=0; i<tableArr.count; i++) {
        BabyMusicModel * model = tableArr[i];
        model.on = NO;
        if (model.lullabyNumber == lullabyNumber) {
            model.on = YES;
        }
    }
    return tableArr;
}

#pragma mark - tableview点击切换歌曲
+ (void)modifyChangeBabyMusic:(NSArray *) tableArr
                     withIndex:(NSInteger) index
                 lullabyNumber:(LullabyNumber) lullabyNumber{
    if (!tableArr || tableArr.count <0 || !lullabyNumber) {
        return;
    }
    for (int i=0; i < tableArr.count; i++) {
        BabyMusicModel * model = tableArr[i];
        model.on = NO;
        if (index == i) {
            model.on = YES;
            lullabyNumber = model.lullabyNumber;
        }
    }
}
@end
