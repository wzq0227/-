//
//  GosPickerView.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "GosPickerView.h"
#import "NSString+GosSize.h"
#import "EnlargeClickButton.h"


#define TOP_VIEW_HEIGHT     40
#define PICKER_VIEW_HEIGHT  200
#define BUTTON_WIDTH        60
#define PV_DEFAULT_FRAME    CGRectMake(0, GOS_SCREEN_H, GOS_SCREEN_W, PICKER_VIEW_HEIGHT + TOP_VIEW_HEIGHT)
#define ANIMATION_DURATION  0.5f

@interface GosPickerView() <
                            UIPickerViewDataSource,
                            UIPickerViewDelegate
                           >
{
    BOOL m_isShowing;
    CGRect m_pvFrame;
    CGPoint m_originalCenter;
    NSUInteger m_selectedRow;
    NSUInteger m_selectedComponents;
}
@property (nonatomic, readwrite, strong) UIView *topView;
@property (nonatomic, readwrite, strong) EnlargeClickButton *sureBtn;     // 确定按钮
@property (nonatomic, readwrite, strong) EnlargeClickButton *cancelBtn;   // 取消按钮
@property (nonatomic, readwrite, strong) UILabel *titleLabel;   // 标题 Label
@property (nonatomic, readwrite, strong) UIPickerView *pickerView;
@property (nonatomic, readwrite, strong) NSMutableArray<NSArray*> *pvData;

@end

@implementation GosPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (0 >= frame.size.width || 0 >= frame.size.height)
    {
        frame = PV_DEFAULT_FRAME;
    }
    else
    {
        frame.origin.y += frame.size.height;
    }
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor       = GOS_WHITE_COLOR;
        self->m_pvFrame            = frame;
        self->m_originalCenter     = self.center;
        self->m_selectedRow        = 0;
        self->m_selectedComponents = 0;
        self.separateLineColor     = GOS_GRAY_COLOR;
        self.isShowSeparateLine    = YES;
        
        [self addSubview:self.topView];
        [self.topView addSubview:self.sureBtn];
        [self.topView addSubview:self.cancelBtn];
        [self.topView addSubview:self.titleLabel];
        [self addSubview:self.pickerView];
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        [rootWindow addSubview:self];
    }
    return self;
}

- (void)configWithDatas:(NSArray<NSArray *> *)pickerDatas
{
    if (!pickerDatas || 0 == pickerDatas.count)
    {
        return;
    }
    self.pvData = [pickerDatas mutableCopy];
    [self reloadPickerViewData];
}

- (void) configDefaultSelectRow:(NSInteger) row inComponent:(NSInteger) component{
    if (row <0 || component <0) {
        return;
    }
    GOS_WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF;
        [strongSelf.pickerView selectRow:row inComponent:component animated:YES];
    });
    
}
- (void)show
{
    if (YES == m_isShowing)
    {
        return;
    }
    if (self.delegate)
    {
        [self.delegate pickerViewStatus:GosPickerViewIsBeingAnimation];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        
        [rootWindow bringSubviewToFront:self];
    });
    GOS_WEAK_SELF;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         GOS_STRONG_SELF;
                         CGPoint point = strongSelf->m_originalCenter;
                         point.y -= PICKER_VIEW_HEIGHT;
                         strongSelf.center = point;
                     }
                     completion:^(BOOL finished) {
                         
                         if (YES == finished)
                         {
                             GOS_STRONG_SELF;
                             if (strongSelf.delegate)
                             {
                                 [strongSelf.delegate pickerViewStatus:GosPickerViewIsBeingShow];
                             }
                         }
                     }];
    m_isShowing = YES;
}

- (void)dismiss
{
    if (NO == m_isShowing)
    {
        return;
    }
    if (self.delegate)
    {
        [self.delegate pickerViewStatus:GosPickerViewIsBeingAnimation];
    }
    GOS_WEAK_SELF;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         
                         GOS_STRONG_SELF;
                         CGPoint point = strongSelf->m_originalCenter;
                         point.y += PICKER_VIEW_HEIGHT;
                         strongSelf.center = point;
                     }
                     completion:^(BOOL finished) {
                         
                         GOS_STRONG_SELF;
                         if (YES == finished)
                         {
                             UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
                             [rootWindow sendSubviewToBack:strongSelf];
                             
                             if (strongSelf.delegate)
                             {
                                 [strongSelf.delegate pickerViewStatus:GosPickerViewIsBeingHidden];
                             }
                         }
                     }];
    m_isShowing = NO;
}

- (void)setDelegate:(id<GosPickerViewDelegate>)delegate
{
    _delegate = delegate;
    if (self.delegate)
    {
        [self.delegate pickerViewStatus:GosPickerViewIsBeingHidden];
    }
}

- (void)setTopViewBGColor:(UIColor *)topViewBGColor
{
    _topViewBGColor = topViewBGColor;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.topView.backgroundColor = topViewBGColor;
    });
}

- (void)setPickerViewBGColor:(UIColor *)pickerViewBGColor
{
    _pickerViewBGColor = pickerViewBGColor;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.pickerView.backgroundColor = pickerViewBGColor;
    });
}

- (void)setSeparateLineColor:(UIColor *)separateLineColor
{
    _separateLineColor = separateLineColor;
    [self reloadPickerViewData];
}

- (void)setIsShowSeparateLine:(BOOL)isShowSeparateLine
{
    _isShowSeparateLine = isShowSeparateLine;
    [self reloadPickerViewData];
}

- (void)setPvTitle:(NSString *)pvTitle
{
    _pvTitle = pvTitle;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.titleLabel.text = pvTitle;
    });
}

- (void)setLeftBtnTitle:(NSString *)leftBtnTitle
{
    _leftBtnTitle = leftBtnTitle;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.cancelBtn setTitle:leftBtnTitle
                        forState:UIControlStateNormal];
    });
}

- (void)setRightBtnTitle:(NSString *)rightBtnTitle
{
    _rightBtnTitle = rightBtnTitle;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.sureBtn setTitle:rightBtnTitle
                      forState:UIControlStateNormal];
    });
}

- (void)setRowHeight:(NSUInteger)rowHeight
{
    _rowHeight = rowHeight;
    [self reloadPickerViewData];
}

- (void)reloadPickerViewData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pickerView reloadAllComponents];
    });
}

- (void)sureBtnAction
{
    if (self.delegate)
    {
        [self.delegate didSelectRow:m_selectedRow
                        inComponent:m_selectedComponents];
    }
    [self dismiss];
}

- (void)cancelBtnAction
{
    [self dismiss];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.rowHeight;
}

#pragma mark - PickerView Datasource && Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.pvData.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.pvData[component].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    ((UILabel *)[_pickerView.subviews objectAtIndex:1]).hidden = !(self.isShowSeparateLine);
    ((UILabel *)[_pickerView.subviews objectAtIndex:2]).hidden = !(self.isShowSeparateLine);
    ((UILabel *)[_pickerView.subviews objectAtIndex:1]).backgroundColor = self.separateLineColor;
    ((UILabel *)[_pickerView.subviews objectAtIndex:2]).backgroundColor = self.separateLineColor;
    
    return self.pvData[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    m_selectedRow        = row;
    m_selectedComponents = component;
}

- (void)touchesBegan:(NSSet*)touches
           withEvent:(UIEvent *)event
{
    if (YES == m_isShowing)
    {
//        [self dismiss];
    }
}

#pragma mark - 懒加载
- (UIView *)topView
{
    if (!_topView)
    {
        CGRect topViewFrame = CGRectMake(0, 0, m_pvFrame.size.width, TOP_VIEW_HEIGHT);
        _topView = [[UIView alloc] initWithFrame:topViewFrame];
        _topView.backgroundColor = GOS_WHITE_COLOR;
    }
    return _topView;
}

- (EnlargeClickButton *)sureBtn
{
    if (!_sureBtn)
    {
        CGRect sureBtnFrame      = CGRectMake(m_pvFrame.size.width - BUTTON_WIDTH, 0, BUTTON_WIDTH, TOP_VIEW_HEIGHT);
        _sureBtn                 = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.frame           = sureBtnFrame;
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sureBtn setTitle:DPLocalizedString(@"GosComm_Confirm")
                  forState:UIControlStateNormal];
        [_sureBtn setTitleColor:GOS_COLOR_RGB(0x55AFFC)
                       forState:UIControlStateNormal];
        [_sureBtn addTarget:self
                     action:@selector(sureBtnAction)
           forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

- (EnlargeClickButton *)cancelBtn
{
    if (!_cancelBtn)
    {
        CGRect cancelBtnFrame      = CGRectMake(0, 0, BUTTON_WIDTH, TOP_VIEW_HEIGHT);
        _cancelBtn                 = [EnlargeClickButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame           = cancelBtnFrame;
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelBtn setTitle:DPLocalizedString(@"GosComm_Cancel")
                    forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:GOS_COLOR_RGB(0xCCCCCC)
                         forState:UIControlStateNormal];
        [_cancelBtn addTarget:self
                       action:@selector(cancelBtnAction)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        CGRect titleLabelFrame      = CGRectMake(0, 0, m_pvFrame.size.width - 2 * BUTTON_WIDTH, TOP_VIEW_HEIGHT);
        _titleLabel                 = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.frame           = titleLabelFrame;
        _titleLabel.center          = self.topView.center;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment   = NSTextAlignmentCenter;
        _titleLabel.text            = DPLocalizedString(@"ChnageCountry");
        _titleLabel.font            = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UIPickerView *)pickerView
{
    if (!_pickerView)
    {
        CGRect pvFrame = CGRectMake(0, TOP_VIEW_HEIGHT, GOS_SCREEN_W, PICKER_VIEW_HEIGHT);
        _pickerView    = [[UIPickerView alloc] initWithFrame:pvFrame];
        _pickerView.backgroundColor = GOS_COLOR_RGB(0xF7F7F7);
        _pickerView.dataSource      = self;
        _pickerView.delegate        = self;
    }
    return _pickerView;
}

- (NSMutableArray<NSArray *> *)pvData
{
    if (!_pvData)
    {
        _pvData = [NSMutableArray arrayWithCapacity:0];
    }
    return _pvData;
}

@end
