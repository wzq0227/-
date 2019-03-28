//  ExperienceCenterViewModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MineViewModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExperienceCenterViewModel : NSObject <MineViewModelDelegate>

- (NSArray *)generateTableDataArray;

@end

NS_ASSUME_NONNULL_END
