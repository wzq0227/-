//
//  LightDurationFootView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "LightDurationFootView.h"
#import "LightDurationDayCell.h"
#import "iOSConfigSDKModel.h"
@interface LightDurationFootView ()<UICollectionViewDelegate,
UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *repeatLab;
@property (nonatomic, strong) NSArray * dataSourceArr;
@end

@implementation LightDurationFootView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.repeatLab.text = DPLocalizedString(@"LightDuration_Repeat");
    [self configCollectionView];
}
#pragma mark - setting
- (void)setLampDurationModel:(LampDurationModel *)lampDurationModel{
    _lampDurationModel = lampDurationModel;
    [self.collectionView reloadData];
}
#pragma mark - config
- (void)configCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((GOS_SCREEN_W-40)/7, self.collectionView.bounds.size.height);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"LightDurationDayCell" bundle:nil]  forCellWithReuseIdentifier:@"LightDurationDayCell"];
}
#pragma mark - function
#pragma mark == <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GosLog(@"是否打开 = %d",((self.lampDurationModel.lampDayMask&0x7f)==0));
    /// 全天关闭 = YES  就不可点击
    if (((self.lampDurationModel.lampDayMask&0x7f)==0)) {        //  不可编辑状态
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(lightDurationSelectDay:)]) {
        [self.delegate lightDurationSelectDay:indexPath.row];
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LightDurationDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LightDurationDayCell" forIndexPath:indexPath];
    BOOL isSwitchOn =  (self.lampDurationModel.lampDayMask>>indexPath.row)&1;
    cell.dayLab.text = self.dataSourceArr[indexPath.row];
    if (((self.lampDurationModel.lampDayMask&0x7f)==0)) {
        cell.dayLab.backgroundColor = GOS_COLOR_RGBA(247, 247, 247, 1);
        cell.dayLab.textColor = GOS_COLOR_RGB(0xCCCCCC);
        cell.dayLab.layer.borderColor = [GOS_COLOR_RGB(0xE6E6E6) CGColor];
        cell.dayLab.layer.borderWidth = 1.0f;
    }
    else{
        if (isSwitchOn) {
            cell.dayLab.backgroundColor = GOS_COLOR_RGB(0xFFCF24);
            cell.dayLab.textColor = [UIColor whiteColor];
        }else{
            cell.dayLab.backgroundColor = GOS_COLOR_RGBA(247, 247, 247, 1);
            cell.dayLab.textColor = GOS_COLOR_RGB(0xCCCCCC);
            cell.dayLab.layer.borderColor = [GOS_COLOR_RGB(0xE6E6E6) CGColor];
            cell.dayLab.layer.borderWidth = 1.0f;
        }
    }
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}
#pragma mark - lazy

- (NSArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = @[DPLocalizedString(@"LightDuration_Sun"),
                           DPLocalizedString(@"LightDuration_Mon"),
                           DPLocalizedString(@"LightDuration_Tue"),
                           DPLocalizedString(@"LightDuration_Wed"),
                           DPLocalizedString(@"LightDuration_Thur"),
                           DPLocalizedString(@"LightDuration_Fri"),
                           DPLocalizedString(@"LightDuration_Sat")];
    }
    return _dataSourceArr;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"LightDurationFootView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}

@end
