//  ShareWithFriendsHeadView.m
//  Goscom
//
//  Create by 匡匡 on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.

#import "ShareWithFriendsHeadView.h"
#import "ShareWithFriendsModel.h"

@interface ShareWithFriendsHeadView ()
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;  //  确认按钮
@property (weak, nonatomic) IBOutlet UILabel *haveShareProLab;  //  已经分享用户
@property (weak, nonatomic) IBOutlet UIButton *editBtn;     //  编辑按钮
/// 是否编辑
@property (nonatomic, assign) BOOL isEdit;
@end

@implementation ShareWithFriendsHeadView


- (void)awakeFromNib{
    [super awakeFromNib];
    [self.editBtn setTitle:DPLocalizedString(@"GosComm_Edit") forState:UIControlStateNormal];
    [self.accountTextField setPlaceholder:DPLocalizedString(@"DevShare_InputUserName")];
    self.haveShareProLab.text = DPLocalizedString(@"DevShare_Title_SharedUsers");
    [self.confirmBtn setTitle:DPLocalizedString(@"GosComm_Confirm") forState:UIControlStateNormal];
    self.confirmBtn.layer.cornerRadius = 18.0f;
    self.confirmBtn.clipsToBounds = YES;
    self.haveShareProLab.hidden = YES;
    self.editBtn.hidden = YES;
    
    self.accountTextField.layer.cornerRadius = 3.0f;
    self.accountTextField.layer.borderWidth = 1.0f;
    self.accountTextField.layer.borderColor = GOS_COLOR_RGBA(230, 230, 230, 1).CGColor;
    UILabel * leftView = [[UILabel alloc] initWithFrame:CGRectMake(10,0,7,26)];
    leftView.backgroundColor = [UIColor clearColor];
    self.accountTextField.leftView = leftView;
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    self.accountTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}

- (void)setDataArr:(NSMutableArray<ShareWithFriendsModel *> *)dataArr{
    _dataArr = dataArr;
    self.haveShareProLab.hidden = _dataArr.count>0?NO:YES;
    self.editBtn.hidden = _dataArr.count>0?NO:YES;
}
#pragma mark - actionFunction
- (IBAction)actionConfirmClick:(UIButton *)sender {
    if (self.accountTextField.text.length < 1) { // 如果未输入账号
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareFriendsConfirm:)]) {
        [self.delegate shareFriendsConfirm:self.accountTextField.text];
    }
    self.accountTextField.text = @"";
}
- (IBAction)actionEditClick:(UIButton *)sender {
    self.isEdit =! self.isEdit;
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GOS_STRONG_SELF;
        NSString * butTitle = strongSelf.isEdit?DPLocalizedString(@"GosComm_Cancel"):DPLocalizedString(@"GosComm_Edit");
         [strongSelf.editBtn setTitle:butTitle forState:UIControlStateNormal];
    });
    [self.dataArr enumerateObjectsUsingBlock:^(ShareWithFriendsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isEdit =! obj.isEdit;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareFriendsEdit:)]) {
        [self.delegate shareFriendsEdit:YES];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"ShareWithFriendsHeadView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, GOS_SCREEN_W, 250);
    }
    return self;
}

@end
