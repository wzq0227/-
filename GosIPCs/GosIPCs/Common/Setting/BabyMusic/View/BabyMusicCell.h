//
//  BabyMusicCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/28.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BabyMusicModel;
NS_ASSUME_NONNULL_BEGIN

@interface BabyMusicCell : UITableViewCell
@property (nonatomic, strong) BabyMusicModel * cellModel;  
+ (instancetype)cellWithTableView:(UITableView *)tableView
                             indexPath:(NSIndexPath *) indexPath
                            cellModel:(BabyMusicModel *) cellModel;

@end

NS_ASSUME_NONNULL_END
