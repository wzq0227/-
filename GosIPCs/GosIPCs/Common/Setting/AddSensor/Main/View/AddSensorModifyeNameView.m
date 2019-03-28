//
//  AddSensorModifyeNameView.m
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "AddSensorModifyeNameView.h"
#import "KKAlertView.h"
@interface AddSensorModifyeNameView()
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *conformBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputTF;

@end
@implementation AddSensorModifyeNameView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.layer.cornerRadius = 5.0f;
    self.clipsToBounds = YES;
    [self.cancelBtn setTitle:DPLocalizedString(@"GosComm_Cancel") forState:UIControlStateNormal];
    [self.conformBtn setTitle:DPLocalizedString(@"GosComm_Confirm") forState:UIControlStateNormal];
}
#pragma mark - 取消点击
- (IBAction)actionCancelClick:(id)sender {
    KKAlertView * alert = (KKAlertView *)self.superview;
    [alert hide];
}
#pragma mark - 确认点击
- (IBAction)actionConfirmClick:(UIButton *)sender {
    if (self.inputTF.text.length < 1) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyNameWithNewName:)]) {
        [self.delegate modifyNameWithNewName:self.inputTF.text];
    }
    KKAlertView * alert = (KKAlertView *)self.superview;
    [alert hide];
}
-(void)setPlaceTitle:(NSString *)placeTitle{
    if (placeTitle) {
        [self.inputTF setPlaceholder:placeTitle];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"AddSensorModifyeNameView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, 270, 170);
    }
    return self;
}
@end
