//
//  MoniterAreaCell.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/22.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "MoniterAreaCell.h"
#import "MoniterAreaCollectionCell.h"
#import "iOSConfigSDK.h"
#import "MediaManager.h"
@interface MoniterAreaCell()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>
@end


@implementation MoniterAreaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self configCollectionView];
}

+ (instancetype)cellModelWithTableView:(UITableView *)tableView
                             indexPath:(NSIndexPath *)indexPath
                             cellModel:(MotionDetectModel *)cellModel
                                 bgImg:(UIImage *) bgImg
                              delegate:(id<MoniterAreaCellDelegate>)delegate{
    [tableView registerNib:[UINib nibWithNibName:@"MoniterAreaCell" bundle:nil] forCellReuseIdentifier:@"MoniterAreaCell"];
    MoniterAreaCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MoniterAreaCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.cellModel = cellModel;
    cell.delegate = delegate;
    cell.bgImgg = bgImg;
    return cell;
}

- (void)setCellModel:(MotionDetectModel *)cellModel{
    _cellModel = cellModel;
    [self.areaCollectionView reloadData];
}
- (void)setBgImgg:(UIImage *)bgImgg{
    _bgImgg = bgImgg;
    //    self.areaCollectionView.backgroundColor = [UIColor colorWithPatternImage:self.bgImgg];
    self.bgImg.image = bgImgg;
    [self.areaCollectionView reloadData];
}
#pragma mark -- config
- (void) configCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    float collectionWidth = ([UIScreen mainScreen].bounds.size.width - 12*2) /4.0f;
    float collectionHeight = collectionWidth / 16 *9;
    flowLayout.itemSize = CGSizeMake(collectionWidth, collectionHeight); //(32,18)
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    [self.areaCollectionView registerNib:[UINib nibWithNibName:@"MoniterAreaCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"MoniterAreaCollectionCell"];
    
    self.areaCollectionView.collectionViewLayout = flowLayout;
    self.areaCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.areaCollectionView.delegate = self;
    self.areaCollectionView.dataSource = self;
    self.areaCollectionView.backgroundColor = [UIColor clearColor];
    
}
#pragma mark -- function

#pragma mark -- actionFunction
- (void)sendMoniterAreaSettingRequestWithPostion:(int )selectPosition{
    BOOL hasSelectedPosition = (self.cellModel.enable >> selectPosition) & 1;
    int  selectValue = hasSelectedPosition ? (self.cellModel.enable & (~(1 << selectPosition))) : (self.cellModel.enable | (1 << selectPosition)) ;
    self.cellModel.enable = selectValue;
    __weak typeof(self) ws =self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.areaCollectionView reloadData];
    });
}

#pragma mark -- delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self sendMoniterAreaSettingRequestWithPostion:indexPath.row];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MoniterAreaCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoniterAreaCollectionCell" forIndexPath:indexPath];
    BOOL isSelected = (self.cellModel.enable >> indexPath.row)&1;
    if (!isSelected) {     //  未选中状态
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView.alpha = 1;
        for (UIView *view in cell.lineViewArray) {
            view.backgroundColor = [UIColor lightGrayColor];
        }
    }else{                 //  选中
        cell.backgroundColor = GOS_COLOR_RGBA(201, 247, 212, 1);
        cell.alpha = 0.8;
        for (UIView *view in cell.lineViewArray) {
            view.backgroundColor = [UIColor redColor];
        }
    }
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4*4;
}
#pragma mark -- lifestyle
#pragma mark -- lazy

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
