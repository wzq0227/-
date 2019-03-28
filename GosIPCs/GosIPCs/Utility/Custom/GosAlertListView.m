//  GosAlertListView.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosAlertListView.h"

@interface GosAlertListView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *alertTableView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, copy) NSArray *tableDataArray;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *cancelText;
@end

@implementation GosAlertListView
#pragma mark - public class method
+ (instancetype)alertTableShowWithTitle:(NSString *)title
                                 cancel:(NSString *)cancel
                              dataArray:(NSArray *)dataArray
                            textKeyPath:(NSString *)keyPath
                               callback:(GosAlertListViewCallBack)callback {
    GosAlertListView *alert = [[GosAlertListView alloc] init];
    alert.titleText = title;
    alert.cancelText = cancel;
    alert.callback = callback;
    alert.tableDataArray = [GosAlertListCellModel convertFromDataArray:dataArray withTextKeyPath:keyPath];
    // 构建控件
    [alert buildComponents];
    // 显示
    [alert show];
    return alert;
}
+ (instancetype)alertTableShowWithTitle:(NSString *)title
                                 cancel:(NSString *)cancel
                              dataArray:(NSArray *)dataArray
                            textKeyPath:(NSString *)keyPath
                               delegate:(id<GosAlertListViewDelegate>)delegate {
    GosAlertListView *alert = [[GosAlertListView alloc] init];
    alert.titleText = title;
    alert.cancelText = cancel;
    alert.delegate = delegate;
    alert.tableDataArray = [GosAlertListCellModel convertFromDataArray:dataArray withTextKeyPath:keyPath];
    // 构建控件
    [alert buildComponents];
    // 显示
    [alert show];
    return alert;
}
#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    }
    return self;
}
#pragma mark - show and dismiss method
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
#pragma mark - build components
// 构建控件
- (void)buildComponents {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.alertTableView];
    if (self.cancelText) {
        [self.contentView addSubview:self.cancelButton];
    }
}
#pragma mark - layout subviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sz = [UIScreen mainScreen].bounds.size;
    CGFloat cx = 53;
    CGFloat cw = MIN(sz.width, sz.height) - cx*2;
    CGFloat lh = 57;
    CGFloat cellH = self.alertTableView.rowHeight;
    CGFloat maxTableH = MAX(sz.width, sz.height) - lh - 50*2;
    self.titleLabel.frame = CGRectMake(0, 0, cw, lh);
    
    CGFloat th = 0;
    if ([self.tableDataArray count] * cellH > maxTableH) {
        th = maxTableH;
        self.alertTableView.scrollEnabled = YES;
    } else {
        th = [self.tableDataArray count] * cellH;
        self.alertTableView.scrollEnabled = NO;
    }
    
    self.alertTableView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), cw, th);
    [self.alertTableView reloadData];
    CGFloat ch = CGRectGetMaxY(self.alertTableView.frame);
    
    if (_cancelButton && _cancelButton.superview) {
        CGFloat cancelH = 40;
        self.cancelButton.frame = CGRectMake(0, CGRectGetMaxY(self.alertTableView.frame), cw, cancelH);
        ch = CGRectGetMaxY(self.cancelButton.frame);
    }
    
    CGFloat cy = (MAX(sz.width, sz.height) - ch) / 2.0;
    self.contentView.frame = CGRectMake(cx, cy, cw, ch);
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GosAlertListCell cellWithTableView:tableView model:self.tableDataArray[indexPath.row]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // delegate
    if (_delegate && [_delegate respondsToSelector:@selector(gosAlertListView:didClick:index:)]) {
        [_delegate gosAlertListView:self didClick:self.tableDataArray[indexPath.row] index:indexPath.row];
    }
    // call back
    if (self.callback) {
        self.callback(indexPath.row, self.tableDataArray[indexPath.row]);
    }
    
    [self dismiss];
}
#pragma mark - event response
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    UIView *hitView = [self hitTest:point withEvent:event];
    
    // 在contentView外面就消失
    if (![hitView isEqual:self.contentView]) {
        [self dismiss];
    }
}
- (void)cancelButtonDidClick:(id)sender {
    // delegate
    if (_delegate && [_delegate respondsToSelector:@selector(gosAlertListView:didClick:index:)]) {
        [_delegate gosAlertListView:self didClick:nil index:-1];
    }
    // call back
    if (self.callback) {
        self.callback(-1, nil);
    }
    
    [self dismiss];
}
#pragma mark - getters and setters
- (UITableView *)alertTableView {
    if (!_alertTableView) {
        _alertTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _alertTableView.delegate = self;
        _alertTableView.dataSource = self;
        _alertTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _alertTableView.separatorInset = UIEdgeInsetsMake(0, 25, 0, 25);
        _alertTableView.rowHeight = [GosAlertListCell cellHeightWithModel:nil];
    }
    return _alertTableView;
}
- (NSArray *)tableDataArray {
    if (!_tableDataArray) {
        _tableDataArray = [NSArray array];
    }
    return _tableDataArray;
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
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = GOS_FONT(18);
        _titleLabel.textColor = GOS_COLOR_RGB(0x1A1A1A);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}
- (void)setTitleText:(NSString *)titleText {
    _titleText = DPLocalizedString(titleText);
    self.titleLabel.text = _titleText;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitleColor:GOS_COLOR_RGB(0x999999) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (void)setCancelText:(NSString *)cancelText {
    if (IS_EMPTY_STRING(DPLocalizedString(cancelText))) { return ; }
    
    _cancelText = DPLocalizedString(cancelText);
    [self.cancelButton setTitle:_cancelText forState:UIControlStateNormal];
}
@end



#pragma mark - GosAlertListCellModel
@implementation GosAlertListCellModel
+ (NSArray<GosAlertListCellModel *> *)convertFromDataArray:(NSArray *)dataArray withTextKeyPath:(NSString *)keyPath {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[dataArray count]];
    for (id data in dataArray) {
        GosAlertListCellModel *cellModel = [[GosAlertListCellModel alloc] init];
        if (keyPath) {
            // 如果有keyPath就用
            cellModel.text = [[data valueForKey:keyPath] isKindOfClass:[NSString class]]?[data valueForKey:keyPath]:nil;
        } else if ([data isKindOfClass:[NSString class]]) {
            // 没有keyPath但是data是String的时候就直接用data
            cellModel.text = data;
        }
        // 必须有显示才加进去
        if (cellModel.text) {
            cellModel.extraData = data;
            [result addObject:cellModel];
        }
    }
    return [result copy];
}
@end



#pragma mark - pragmaGosAlertListCell
@interface GosAlertListCell ()
@property (nonatomic, strong) UILabel *alertTextLabel;
@property (nonatomic, strong) GosAlertListCellModel *cellModel;
@end
@implementation GosAlertListCell
#pragma mark - public method
+ (instancetype)cellWithTableView:(UITableView *)tableView model:(GosAlertListCellModel *)model {
    static NSString *const kGosAlertListCellID = @"kGosAlertListCellID";
    [tableView registerClass:[self class] forCellReuseIdentifier:kGosAlertListCellID];
    
    GosAlertListCell *cell = [tableView dequeueReusableCellWithIdentifier:kGosAlertListCellID];
    if (!cell) {
        cell = [[GosAlertListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGosAlertListCellID];
    }
    cell.cellModel = model;
    return cell;
}
+ (CGFloat)cellHeightWithModel:(GosAlertListCellModel *)model {
    return 39.0;
}
#pragma mark - initialization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if (_alertTextLabel || _alertTextLabel.superview) {
            [_alertTextLabel removeFromSuperview];
        }
        [self.contentView addSubview:self.alertTextLabel];
        
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.alertTextLabel.frame = self.contentView.bounds;
}
#pragma mark - getters and setters
- (void)setCellModel:(GosAlertListCellModel *)cellModel {
    _cellModel = cellModel;
    self.alertTextLabel.text = cellModel.text;
}
- (UILabel *)alertTextLabel {
    if (!_alertTextLabel) {
        _alertTextLabel = [[UILabel alloc] init];
        _alertTextLabel.textAlignment = NSTextAlignmentCenter;
        _alertTextLabel.font = GOS_FONT(16);
        _alertTextLabel.textColor = GOS_COLOR_RGB(0x1A1A1A);
    }
    return _alertTextLabel;
}
@end
