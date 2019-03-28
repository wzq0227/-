//
//  MoniterAreaCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MotionDetectModel;

@protocol MoniterAreaCellDelegate <NSObject>
- (void)moniterSelectAreaBack:(MotionDetectModel *)cellModel;
@end


@interface MoniterAreaCell : UITableViewCell
@property (nonatomic, strong) MotionDetectModel * cellModel;   // 数据模型
@property (nonatomic, weak) id <MoniterAreaCellDelegate> delegate;
@property (nonatomic, strong) UIImage * bgImgg;   // 背景img
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UICollectionView *areaCollectionView;
@property (weak, nonatomic) IBOutlet UIView *lineView;

//@property(nonatomic,strong)SelectAreaBlock selectAreaBlock;

+ (instancetype)cellModelWithTableView:(UITableView *)tableView
                             indexPath:(NSIndexPath *) indexPath
                             cellModel:(MotionDetectModel *) cellModel
                                 bgImg:(UIImage *) bgImg
                              delegate:(id <MoniterAreaCellDelegate>) delegate;


@end
