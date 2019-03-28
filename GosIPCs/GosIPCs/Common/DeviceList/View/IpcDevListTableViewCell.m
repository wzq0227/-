//
//  IpcDevListTableViewCell.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/23.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "IpcDevListTableViewCell.h"

@interface IpcDevListTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *devOffLineView;
@property (weak, nonatomic) IBOutlet UIImageView *devCoverImgView;
@property (weak, nonatomic) IBOutlet UILabel *devNameLabel;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *devMessageBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *devCloudBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *devTFCardBtn;
@property (weak, nonatomic) IBOutlet EnlargeClickButton *devSettingBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgBtnRightMargin;

@end

@implementation IpcDevListTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = GOS_VC_BG_COLOR;
    [self configCoverImgView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setIpcDevListTBCellData:(DevDataModel *)ipcDevListTBCellData
{
    if (!ipcDevListTBCellData)
    {
        return;
    }
    _ipcDevListTBCellData = ipcDevListTBCellData;
    
    [self configNameLabelWithData:_ipcDevListTBCellData];
    
    [self configOfflineView:_ipcDevListTBCellData.Status];
    
    [self configCoverImageWithData:_ipcDevListTBCellData];
    
    if (StreamStoreCloud != _ipcDevListTBCellData.devCapacity.streamStoreType)
    {
        [self configCloudBtnHidden];
    }
}

-(void)setCellActionBlock:(CellClickActionBlock)cellActionBlock
{
    if (!cellActionBlock)
    {
        return;
    }
    _cellActionBlock = cellActionBlock;
}

#pragma mark -- 设置封面
- (void)configCoverImgView
{
    CGRect layerFrame = CGRectMake(0, 0, GOS_SCREEN_W - 40, [self heightOfCover]);
    self.devOffLineView.userInteractionEnabled  = NO;
    self.devCoverImgView.userInteractionEnabled = YES;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:layerFrame
                                                     byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft
                                                           cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *coverLayer        = [[CAShapeLayer alloc] init];
    coverLayer.frame                = layerFrame;
    coverLayer.path                 = bezierPath.CGPath;
    self.devCoverImgView.layer.mask = coverLayer;
    
    CAShapeLayer *offlineLayer     = [[CAShapeLayer alloc] init];
    offlineLayer.frame             = layerFrame;
    offlineLayer.path              = bezierPath.CGPath;
    self.devOffLineView.layer.mask = offlineLayer;
    
    [self.devCoverImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(tapGesAction:)]];
}

#pragma mark -- 按比例（16:9）返回 Cell 高度
- (CGFloat)heightOfCover
{
    CGFloat margin      = 20.0f;
    CGFloat scaleFactor = 9.0f/16.0f;
    CGFloat rowWidth    = GOS_SCREEN_W - margin * 2;
    CGFloat coverHeight = rowWidth * scaleFactor;
    return coverHeight;
}

#pragma mark -- 设置设备名称
- (void)configNameLabelWithData:(DevDataModel *)cellData
{
    if (!cellData)
    {
        return;
    }
    if (DevOwn_share == _ipcDevListTBCellData.DeviceOwner)  // 分享设备
    {
        self.devNameLabel.text = [NSString stringWithFormat:@"%@(%@)",_ipcDevListTBCellData.DeviceName, DPLocalizedString(@"Share")];
    }
    else
    {
        self.devNameLabel.text = _ipcDevListTBCellData.DeviceName;
    }
}

#pragma mark -- 设置不在线遮罩 View
- (void)configOfflineView:(DevStatusType)status
{
    switch (status)
    {
        case DevStatus_offLine:
        {
            self.devOffLineView.hidden = NO;
        }
            break;
            
        case DevStatus_onLine:
        {
            self.devOffLineView.hidden = YES;
        }
            break;
            
        case DevStatus_sleep:
        {
            self.devOffLineView.hidden = YES;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 设置封面
- (void)configCoverImageWithData:(DevDataModel *)cellData
{
    UIImage *coverImage = [MediaManager coverWithDevId:cellData.DeviceId
                                              fileName:nil
                                            deviceType:(GosDeviceType)cellData.DeviceType
                                              position:PositionMain];
    if (coverImage)
    {
        self.devCoverImgView.image = coverImage;
    }
    else
    {
        GosLog(@"使用默认封面：deviceID = %@， deviceType = %ld", cellData.DeviceId, cellData.DeviceType);
        self.devCoverImgView.image = GOS_IMAGE(@"Cover.jpg");
    }
}

#pragma mark -- 设置云存储回放按钮隐藏（默认显示）
- (void)configCloudBtnHidden
{
    self.devCloudBtn.hidden = YES;
    self.msgBtnRightMargin.constant = 15.0f;
}

#pragma mark - 事件中心
#pragma mark -- 封面点击事件
- (void)tapGesAction:(id)sender
{
    if (self.cellActionBlock)
    {
        self.cellActionBlock(CellClickAction_liveStream);
    }
}
#pragma mark -- 设备消息按钮事件
- (IBAction)devMessageBtnAction:(id)sender
{
    if (self.cellActionBlock)
    {
        self.cellActionBlock(CellClickAction_message);
    }
}

#pragma mark -- 设备云存储按钮事件
- (IBAction)devCloudBtnAction:(id)sender
{
    if (self.cellActionBlock)
    {
        self.cellActionBlock(CellClickAction_CloudPB);
    }
}

#pragma mark -- 设备 TF 卡录像按钮事件
- (IBAction)devTFCardBtnAction:(id)sender
{
    if (self.cellActionBlock)
    {
        self.cellActionBlock(CellClickAction_TFCardPB);
    }
}

#pragma mark -- 设备设置按钮事件
- (IBAction)devSettingBtnAction:(id)sender
{
    if (self.cellActionBlock)
    {
        self.cellActionBlock(CellClickAction_setting);
    }
}
@end
