//  GosAlertView.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/19.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosAlertView.h"


@interface GosAlertView ()
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *messageText;

@property (nonatomic, copy) NSAttributedString *attributeTitleText;
@property (nonatomic, copy) NSAttributedString *attributeMessageText;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, copy) UILabel *titleLabel;
@property (nonatomic, copy) UILabel *messageLabel;

@property (nonatomic, copy) NSMutableArray <GosAlertAction *> *alertActions;
@property (nonatomic, strong) NSMutableArray <UIButton *> *buttons;
@property (nonatomic, strong) NSMutableArray <UIView *> *verticalLines;
@property (nonatomic, strong) NSMutableArray <UIView *> *horizontalLines;
@end

@implementation GosAlertView
#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    }
    return self;
}

#pragma mark - public method
+ (GosAlertView *)alertShowWithAttributeTitle:(NSAttributedString *)attributeTitle attributemessage:(NSAttributedString *)attributeMessage cancelAction:(GosAlertAction *)cancelAction otherActions:(GosAlertAction *)otherActions, ... {
    GosAlertView *alert = [[GosAlertView alloc] init];
    if (attributeTitle) { alert.attributeTitleText = attributeTitle; }
    
    if (attributeMessage) { alert.attributeMessageText = attributeMessage; }
    
    if (cancelAction) { [alert.alertActions addObject:cancelAction]; }
    
     if (otherActions) { [alert.alertActions addObject:otherActions]; }
    
    va_list argList;
    va_start(argList, otherActions);
    id arg;
    while ((arg = va_arg(argList, id))) {
        if ([arg isKindOfClass:[GosAlertAction class]]) {
            [alert.alertActions addObject:arg];
        }
    }
    va_end(argList);
    
    // 组装组件
    [alert buildComponents];
    
    [alert show];
    return alert;
}
+ (GosAlertView *)alertShowWithTitle:(NSString *)title message:(NSString *)message cancelAction:(GosAlertAction *)cancelAction otherActions:(GosAlertAction *)otherActions, ... {
    GosAlertView *alert = [[GosAlertView alloc] init];
    if (title) { alert.titleText = DPLocalizedString(title); }
    
    if (message) { alert.messageText = DPLocalizedString(message); }
    
    if (cancelAction) {[alert.alertActions addObject:cancelAction]; }
    
    if (otherActions) { [alert.alertActions addObject:otherActions]; }
    
    va_list argList;
    va_start(argList, otherActions);
    id arg;
    while ((arg = va_arg(argList, id))) {
        if ([arg isKindOfClass:[GosAlertAction class]]) {
            [alert.alertActions addObject:arg];
        }
    }
    va_end(argList);
    
    // 组装组件
    [alert buildComponents];
    
    [alert show];
    return alert;
}

#pragma mark - show and dismiss
- (void)show {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self showWithAnimation];
}
- (void)showWithAnimation {
    // TODO: 显示动画
}
- (void)dismiss {
    [self removeFromSuperview];
    [self dismissWithAnimation];
}
- (void)dismissWithAnimation {
    // TODO: 隐藏动画
}
#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize sz = [UIScreen mainScreen].bounds.size;
    CGFloat y = 20;
    CGFloat cx = 53;
    CGFloat cw = MIN(sz.width, sz.height) - cx*2;
    CGFloat margin = 20;
    
    if (_titleLabel) {
        CGFloat x = 17;
        CGFloat w = cw - 2*x;
        CGFloat h = [self getTheStringHeight:self.attributeTitleText withWidht:w];
        _titleLabel.frame = CGRectMake(x, y, w, h);
        y = CGRectGetMaxY(_titleLabel.frame)+margin;
    }
    
    if (_messageLabel) {
        CGFloat x = 17;
        CGFloat w = cw - 2*x;
        CGFloat h = [self getTheStringHeight:self.attributeMessageText withWidht:w];
        _messageLabel.frame = CGRectMake(x, y, w, h);
        y = CGRectGetMaxY(_messageLabel.frame)+margin;
    }
    
    CGFloat tempY = y;
    
    CGFloat bh = 45.0;
    for (int i = 0; i < [self.buttons count]; i++) {
        CGFloat bw = [self.buttons count] == 2 ? cw/2.0 : cw;
        CGFloat x = [self.buttons count] == 2 ? (i % 2 == 0 ? 0 : bw) : 0;
        UIButton *btn = self.buttons[i];
        btn.frame = CGRectMake(x, y, bw, bh);
        
        y = [self.buttons count] == 2 ? (i % 2 == 0 ? y : y+bh) : y+bh;
    }
    
    for (int i = 0; i < [self.horizontalLines count]; i++) {
        CGFloat x = 25.0;
        CGFloat w = cw - 2*x;
        CGFloat h = 1.0;
        UIView *line = self.horizontalLines[i];
        line.frame = CGRectMake(x, tempY + bh*i, w, h);
    }
    
    for (int i = 0; i < [self.verticalLines count]; i++) {
        CGFloat w = 1.0;
        CGFloat x = (cw - w) / 2.0;
        CGFloat h = 25.0;
        UIView *line = self.verticalLines[i];
        line.frame = CGRectMake(x, tempY+(bh-h)/2.0, w, h);
    }
    
    _contentView.frame = CGRectMake(cx, (sz.height - y)/2.0, cw, y);
    
}
#pragma mark - private method
- (CGFloat)getTheStringHeight:(NSAttributedString *)attributeString withWidht:(CGFloat)width {
    return [attributeString boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
}

#pragma mark - build components
- (void)buildComponents {
    [self addSubview:self.contentView];
    
    if (self.attributeTitleText) {
        [self.contentView addSubview:self.titleLabel];
    } else {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }
    
    
    if (self.attributeMessageText) {
        [self.contentView addSubview:self.messageLabel];
    } else {
        [_messageLabel removeFromSuperview];
        _messageLabel = nil;
    }
    
    for (int i = 0; i < [self.alertActions count]; i++) {
        GosAlertAction *action = self.alertActions[i];
        UIButton *btn = [self buildButtonWithAttributeTitle:action.attributeText tag:i];
        [self.contentView addSubview:btn];
        [self.buttons addObject:btn];
        // 当按钮数大于等于3个时就每一行都有竖线，另外至少有一根线
        if ([self.alertActions count] >= 3 || [self.horizontalLines count] == 0) {
            UIView *horizontalLine = [self buildHorizontalLine];
            [self.contentView addSubview:horizontalLine];
            [self.horizontalLines addObject:horizontalLine];
        }
        // 只有两个按钮时才需要一个竖线
        if (i % 2 == 0 && [self.alertActions count] == 2) {
            UIView *verticalLine = [self buildVerticalLine];
            [self.contentView addSubview:verticalLine];
            [self.verticalLines addObject:verticalLine];
        }
    }
}

- (UIView *)buildHorizontalLine {
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = GOS_COLOR_RGB(0xF2F2F2);
    return line;
}
- (UIView *)buildVerticalLine {
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = GOS_COLOR_RGB(0xF2F2F2);
    return line;
}
- (UIButton *)buildButtonWithAttributeTitle:(NSAttributedString *)attributeString tag:(NSUInteger)tag {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setAttributedTitle:attributeString forState:UIControlStateNormal];
    [btn setTag:tag];
    [btn addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - event response
- (void)buttonDidClick:(UIButton *)sender {
    __weak GosAlertAction *action = self.alertActions[sender.tag];
    if (action.clickAction) {
        action.clickAction(action);
    }
    
    [self dismiss];
    
}

#pragma mark - getters and setters
- (NSMutableArray<GosAlertAction *> *)alertActions {
    if (!_alertActions) {
        _alertActions = [NSMutableArray array];
    }
    return _alertActions;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 10.0;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}
- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    self.attributeTitleText = [[NSAttributedString alloc] initWithString:titleText attributes:@{NSFontAttributeName:GOS_BOLD_FONT(17), NSForegroundColorAttributeName:GOS_COLOR_RGB(0x1A1A1A), NSParagraphStyleAttributeName:paragraph}];
}
- (void)setMessageText:(NSString *)messageText {
    _messageText = messageText;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    paragraph.alignment = NSTextAlignmentLeft;
    self.attributeMessageText = [[NSAttributedString alloc] initWithString:messageText attributes:@{NSFontAttributeName:GOS_FONT(14), NSForegroundColorAttributeName:GOS_COLOR_RGB(0x1A1A1A), NSParagraphStyleAttributeName:paragraph}];
}
- (void)setAttributeTitleText:(NSAttributedString *)attributeTitleText {
    _attributeTitleText = attributeTitleText;
    
    self.titleLabel.attributedText = attributeTitleText;
}
- (void)setAttributeMessageText:(NSAttributedString *)attributeMessageText {
    _attributeMessageText = attributeMessageText;
    
    self.messageLabel.attributedText = attributeMessageText;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}
- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}
- (NSMutableArray<UIButton *> *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}
- (NSMutableArray<UIView *> *)horizontalLines {
    if (!_horizontalLines) {
        _horizontalLines = [NSMutableArray array];
    }
    return _horizontalLines;
}
- (NSMutableArray<UIView *> *)verticalLines {
    if (!_verticalLines) {
        _verticalLines = [NSMutableArray array];
    }
    return _verticalLines;
}
@end


@interface GosAlertAction ()
@property (nonatomic, readwrite, copy) NSAttributedString *attributeText;
@end
@implementation GosAlertAction
+ (GosAlertAction *)actionWithText:(NSString *)text
                             style:(GosAlertActionStyle)style
                       clickAction:(AlertClickAction)clickAtion {
    GosAlertAction *action = [[GosAlertAction alloc] init];
    action.text = DPLocalizedString(text);
    action.style = style;
    action.clickAction = clickAtion;
    return action;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    [self updateWithStyle:_style text:text];
}
- (void)setStyle:(GosAlertActionStyle)style {
    _style = style;
    
    if (_text) {
        [self updateWithStyle:style text:_text];
    }
}
- (void)updateWithStyle:(GosAlertActionStyle)style text:(NSString *)text {
    NSAttributedString *attrStr = nil;
    switch (style) {
        case GosAlertActionStyleDefault:
        case GosAlertActionStyleCancel:
            attrStr = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:GOS_FONT(16), NSForegroundColorAttributeName:GOS_COLOR_RGB(0x999999)}];
            break;
        case GosAlertActionStyleBlue:
            attrStr = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:GOS_FONT(16), NSForegroundColorAttributeName:GOS_COLOR_RGB(0x55AFFC)}];
            break;
            
        default:
            break;
    }
    
    _attributeText = attrStr;
}
@end
