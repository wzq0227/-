//  GosCalendarView.m
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/2.
//  Copyright © 2019年 goscam. All rights reserved.

#import "GosCalendarView.h"
#import "NSString+GosFormatDate.h"
#import "NSDate+GosDateExtension.h"

@interface GosCalendarView ()
/// calendarButton显示的日期
@property (nonatomic, copy) NSDate *currentDate;
/// 控制Bar
@property (nonatomic, strong) GosCalendarBarView *barView;
/// 事件日期
@property (nonatomic, copy) NSArray *eventsArray;

@end

@implementation GosCalendarView
#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 添加按钮
        [self addSubview:self.barView];
        [self.barView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        // 设置默认事件
        self.eventsArray = @[[NSDate date]];
        
        // 设置默认显示时间
        self.currentDate = [NSDate date];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)dealloc {
    GosLog(@"----------------- GosCalendarView dealloc ----------------");
}

#pragma mark - public method
- (void)updateDisplayDate:(NSDate *)displayDate {
    self.currentDate = displayDate;
}

- (void)updateEventsArray:(NSArray <NSDate *> *)eventsArray {
    self.eventsArray = eventsArray;
}

#pragma mark - event response
/// calendar显示按钮响应
- (void)calendarButtonDidClick:(UIButton *)sender {
    UIView *targetView = nil;
    CGRect frame;
    NSArray *eventsArray = self.eventsArray;
    
    [self.delegate calendarView:self displayDetailViewInView:&targetView frame:&frame];
    
    GOS_WEAK_SELF
    // 显示弹框
    [GosCalendarDetailView showWithTargetView:targetView
                                  attachFrame:self.frame
                                 displayframe:frame
                                  currentDate:self.currentDate
                                  eventsArray:eventsArray
                         selectedDateCallBack:^(NSDate * _Nonnull selectedDate, BOOL hasEvent) {
        GOS_STRONG_SELF
        // 更新当前日期
        strongSelf.currentDate = selectedDate;
        // 选择日期已改变
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(calendarView:selectedDateDidChanged:hasEvent:)]) {
            
            [strongSelf.delegate calendarView:strongSelf
                       selectedDateDidChanged:selectedDate
                                     hasEvent:hasEvent];
        }
    }];
}

/// 退后 日
- (void)backwardButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    
    NSDate *date = [self fetchPreviousEventsDateWithCurrentDate:_currentDate];
    // 后退没有事件日
    if (!date) return ;
    
    self.currentDate = date;
    
    // 显示日期更改
    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:displayDateDidChanged:)]) {
        [_delegate calendarView:self displayDateDidChanged:self.currentDate];
    }
}

/// 前进 日
- (void)forwardButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    
    NSDate *date = [self fetchNextEventsDateWithCurrentDate:_currentDate];
    // 前进没有事件日
    if (!date) return ;
    // 前进超过系统日期
    if ([date isDateGreaterThanNowaday]) return ;
    
    self.currentDate = date;
    
    // 显示日期更改
    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:displayDateDidChanged:)]) {
        [_delegate calendarView:self displayDateDidChanged:self.currentDate];
    }
}


#pragma mark - private method
- (NSDate *)fetchPreviousEventsDateWithCurrentDate:(NSDate *)currentDate {
    NSUInteger index = [self.eventsArray indexOfObject:currentDate];
    
    if (index == 0) {
        return nil;
    } else {
        return [self.eventsArray objectAtIndex:index-1];
    }
}

- (NSDate *)fetchNextEventsDateWithCurrentDate:(NSDate *)currentDate {
    NSUInteger index = [self.eventsArray indexOfObject:currentDate];
    
    if (index == [self.eventsArray count]) {
        return nil;
    } else {
        return [self.eventsArray objectAtIndex:index+1];
    }
}


#pragma mark - getters and setters
- (void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    
    GOS_WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        GOS_STRONG_SELF
        // 更新显示
        [strongSelf.barView.calenderButton setTitle:[NSString stringWithDate:currentDate format:whippletreeDateFormatString]
                                     forState:UIControlStateNormal];
    });
    
//    // 显示日期更改
//    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:displayDateDidChanged:)]) {
//        [_delegate calendarView:self displayDateDidChanged:currentDate];
//    }
}

- (GosCalendarBarView *)barView {
    if (!_barView) {
        _barView = [[GosCalendarBarView alloc] initWithFrame:CGRectZero];
        [_barView.calenderButton addTarget:self action:@selector(calendarButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_barView.backwardButton addTarget:self action:@selector(backwardButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_barView.forwardButton addTarget:self action:@selector(forwardButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _barView;
}

- (void)setEventsArray:(NSArray *)eventsArray {
    if (![eventsArray isKindOfClass:[NSArray class]]) return ;
    
    BOOL existToday = NO;
    for (NSDate *event in eventsArray) {
        if ([event isTheSameDayAsDate:[NSDate date]]) {
            // 确保currentDate是数据元素
            if ([self.currentDate isTheSameDayAsDate:[NSDate date]]) {
                self.currentDate = event;
            }
            existToday = YES;
            break;
        }
    }
    if (existToday) {
        _eventsArray = eventsArray;
    } else {
        NSDate *date = [NSDate date];
        if ([self.currentDate isTheSameDayAsDate:[NSDate date]]) {
            self.currentDate = date;
        }
        _eventsArray = [eventsArray arrayByAddingObject:date];
    }
}

@end


#pragma mark - GosCalendarBarView
@interface GosCalendarBarView ()
/// 中间显示日期的按钮
@property (nonatomic, readwrite, strong) UIButton *calenderButton;
/// 后退按钮
@property (nonatomic, readwrite, strong) UIButton *backwardButton;
/// 前进按钮
@property (nonatomic, readwrite, strong) UIButton *forwardButton;

@end

@implementation GosCalendarBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:GOS_COLOR_RGB(0xF7F7F7)];
        
        [self addSubview:self.calenderButton];
        [self addSubview:self.backwardButton];
        [self addSubview:self.forwardButton];
        
        [self.calenderButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self);
            make.height.equalTo(self);
            make.width.equalTo(self).multipliedBy(.5);
        }];
        
        [self.backwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.calenderButton.mas_left).offset(-10);
            make.height.centerY.equalTo(self.calenderButton);
            make.width.equalTo(@(50));
        }];
        
        [self.forwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.calenderButton.mas_right).offset(10);
            make.height.centerY.equalTo(self.calenderButton);
            make.width.equalTo(self.backwardButton);
        }];
    }
    return self;
}

- (UIButton *)calenderButton {
    if (!_calenderButton) {
        _calenderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_calenderButton setImage:GOS_IMAGE(@"icon_calendar") forState:UIControlStateNormal];
        [_calenderButton setTitleColor:GOS_COLOR_RGB(0x1A1A1A) forState:UIControlStateNormal];
        _calenderButton.titleLabel.font = GOS_FONT(14);
        _calenderButton.imageEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    }
    return _calenderButton;
}

- (UIButton *)backwardButton {
    if (!_backwardButton) {
        _backwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backwardButton setImage:GOS_IMAGE(@"icon_backward") forState:UIControlStateNormal];
    }
    return _backwardButton;
}

- (UIButton *)forwardButton {
    if (!_forwardButton) {
        _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forwardButton setImage:GOS_IMAGE(@"icon_forward") forState:UIControlStateNormal];
    }
    return _forwardButton;
}

@end

#pragma mark - GosCalendarDetailView
@interface GosCalendarDetailView () <UICollectionViewDataSource, UICollectionViewDelegate>
/// 控制Bar
@property (nonatomic, strong) GosCalendarBarView *barView;
/// 周视图
@property (nonatomic, strong) UIView *weekView;
/// 周显示名
@property (nonatomic, strong) NSArray *weekName;
/// collection view
@property (nonatomic, strong) UICollectionView *detailCollectionView;
/// collection data source
@property (nonatomic, strong) NSMutableArray *collectionDataArray;

@property (nonatomic, assign) CGFloat barViewHeight;

@end

@implementation GosCalendarDetailView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // add subview
        [self addSubview:self.barView];
        [self addSubview:self.weekView];
        [self addSubview:self.detailCollectionView];
        
        // reload data
        [self reloadData];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 控制Bar frame
    self.barView.frame = CGRectMake(0, 0, self.frame.size.width, _barViewHeight);
    
    // 设置周视图frame
    self.weekView.frame = CGRectMake(0, CGRectGetMaxY(self.barView.frame), self.frame.size.width, self.frame.size.height * 0.1);
    
    // 移除周视图的子视图
    [self.weekView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 添加一周显示
    float labelWidth = self.frame.size.width / 7;
    float labelHeight = self.weekView.frame.size.height;
    for (int i = 0; i < [self.weekName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * labelWidth, 0, labelWidth, labelHeight)];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = GOS_COLOR_RGB(0x1A1A1A);
        label.text = DPLocalizedString([self.weekName objectAtIndex:i]);
        [self.weekView addSubview:label];
    }
    
    // 设置collection frame
    self.detailCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.weekView.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.weekView.frame));
}


#pragma mark - public method
+ (void)showWithTargetView:(UIView *)targetView
               attachFrame:(CGRect)attachFrame
              displayframe:(CGRect)displayframe
               currentDate:(NSDate *)currentDate
               eventsArray:(NSArray<NSDate *> *)eventsArray
      selectedDateCallBack:(GosCalendarDetailViewSelectedBlock)selectedDateCallBack {
    GosCalendarDetailView *detailView = [[GosCalendarDetailView alloc] init];
    detailView.barViewHeight = attachFrame.size.height;
    detailView.frame = displayframe;
    detailView.eventsArray = eventsArray;
    detailView.selectedDate = currentDate;
    detailView.currentDate = currentDate;
    detailView.callback = selectedDateCallBack;
    
    [targetView addSubview:detailView];
}

- (void)dismiss {
    [self removeFromSuperview];
}


#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [GosCalendarDetailViewCell cellWithCollectionView:collectionView
                                                   indexPath:indexPath
                                                       model:self.collectionDataArray[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 刷新
    GosCalendarDetailViewCellModel *model = [self.collectionDataArray objectAtIndex:indexPath.item];
    model.selected = !model.isSelected;
    // 取消其他选择
    NSMutableArray *temp = [NSMutableArray arrayWithObject:indexPath];
    for (int i = 0; i < [self.collectionDataArray count]; i++) {
        if (i == indexPath.item) continue;
        
        GosCalendarDetailViewCellModel *item = [self.collectionDataArray objectAtIndex:i];
        if (item.isSelected) {
            item.selected = NO;
            [temp addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        };
    }
    // 刷新
    [collectionView reloadItemsAtIndexPaths:[temp copy]];
    
    // 回调已选择cell数据
    if (self.callback)
        self.callback(model.date, model.isHasEvent);
    
    [self dismiss];
}

#pragma mark - event response
/// calendar显示按钮响应
- (void)calendarButtonDidClick:(UIButton *)sender {
    [self dismiss];
}

/// 退后 月
- (void)backwardButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    
    NSDate *date = [_currentDate dateInMonthChanged:NO];
    // 判断events
    NSDate *firstEvent = [_eventsArray firstObject];
    // 无日期 不可后退
    if (![firstEvent isKindOfClass:[NSDate class]]) return ;
    // 不可少于时间当月第一天
    if ([date isDateLessThanLimitMonthWithDate:firstEvent]) return ;
    
    self.currentDate = date;
}

/// 前进 月
- (void)forwardButtonDidClick:(id)sender {
    GosLog(@"%s", __PRETTY_FUNCTION__);
    
    NSDate *date = [_currentDate dateInMonthChanged:YES];
    // 不可超过当月最后一天
    if ([date isDateGreaterThanLimitMonthWithDate:[NSDate date]]) return ;
    
    self.currentDate = date;
}


#pragma mark - private method
/// 共同刷新方法
- (void)reloadData {
    [self.barView.calenderButton setTitle:[NSString stringWithDate:_currentDate format:whippletreeYMDateFormatString]
                                 forState:UIControlStateNormal];
    
    // 更新collection layout currentDate
    ((GosCalenderDetailViewLayout *)self.detailCollectionView.collectionViewLayout).currentDate = _currentDate;
    // 重载数据
    self.collectionDataArray = [[self modelArrayWithCurrentDate:_currentDate selectedDate:self.selectedDate enableEvents:!self.disableEvents eventsArray:self.eventsArray] mutableCopy];
    [_detailCollectionView reloadData];
}

- (NSArray *)modelArrayWithCurrentDate:(NSDate *)currentDate
                          selectedDate:(NSDate *)selectedDate
                          enableEvents:(BOOL)enableEvents
                           eventsArray:(NSArray <NSDate *> *_Nullable)eventsArray {
    // 获取当月的天数
    NSInteger monthDays = [currentDate monthDays];
    
    // 将每天的模型组装
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:monthDays];
    for (int i = 0; i < monthDays; i++) {
        NSInteger day = i+1;
        NSDate *dayDate = [currentDate dateWithDay:day];
        NSString *text = [NSString stringWithFormat:@"%zd", day];
        // 选择日期是否是同一天
        BOOL isSelected = [selectedDate isTheSameDayAsDate:dayDate];
        // 如果事件有效，则判断数组是否存在同一天的数据；否则都默认有事件
        BOOL hasEvent = enableEvents? [dayDate isDateExistSameDayIn:eventsArray] : YES;
        // 如果事件有效，则根据是否有事件来判断是否可用；否则都是可用的
        BOOL disable = enableEvents ? !hasEvent : NO;
        // 超过当前日期都是灰色
        if ([dayDate isDateGreaterThanNowaday]) disable = YES;
        
        [temp addObject:
         [GosCalendarDetailViewCellModel modelWithDate:dayDate
                                                 text:text
                                              selected:isSelected
                                              hasEvent:hasEvent
                                               disable:disable]];
        
    }
    
    return [temp copy];
}


#pragma mark - getters and setters
- (UICollectionView *)detailCollectionView {
    if (!_detailCollectionView) {
        GosCalenderDetailViewLayout *layout = [[GosCalenderDetailViewLayout alloc] init];
        layout.currentDate = self.currentDate;
        _detailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _detailCollectionView.backgroundColor = [UIColor whiteColor];;
        _detailCollectionView.dataSource = self;
        _detailCollectionView.delegate = self;
        
    }
    return _detailCollectionView;
}

- (void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    
    [self reloadData];
}

- (UIView *)weekView {
    if (!_weekView) {
        _weekView = [[UIView alloc] init];
        _weekView.backgroundColor = [UIColor whiteColor];
    }
    return _weekView;
}

- (NSMutableArray *)collectionDataArray {
    if (!_collectionDataArray) {
        _collectionDataArray = [NSMutableArray arrayWithCapacity:31];
    }
    return _collectionDataArray;
}

- (NSArray *)weekName {
    if (!_weekName) {
    _weekName = @[
                  @"Sun",
                  @"Mon",
                  @"Tues",
                  @"Wed",
                  @"Thur",
                  @"Fri",
                  @"Sat"
                  ];
    }
    return _weekName;
}

- (GosCalendarBarView *)barView {
    if (!_barView) {
        _barView = [[GosCalendarBarView alloc] initWithFrame:CGRectZero];
        [_barView.calenderButton addTarget:self action:@selector(calendarButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_barView.backwardButton addTarget:self action:@selector(backwardButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_barView.forwardButton addTarget:self action:@selector(forwardButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _barView;
}

@end

#pragma mark - GosCalendarDetailViewCellModel
@interface GosCalendarDetailViewCellModel ()
/// 标题颜色
@property (nonatomic, readwrite, copy) UIColor *textColor;
@end

@implementation GosCalendarDetailViewCellModel
- (instancetype)init {
    if (self = [super init]) {
        _hasEvent = YES;
    }
    return self;
}


#pragma mark - public method
/// 初始化
+ (instancetype)modelWithDate:(NSDate *)date
                        text:(NSString *)text
                     selected:(BOOL)selected
                     hasEvent:(BOOL)hasEvent
                      disable:(BOOL)disable {
    GosCalendarDetailViewCellModel *model = [[GosCalendarDetailViewCellModel alloc] init];
    model.date = date;
    model.text = text;
    model.selected = selected;
    model.hasEvent = hasEvent;
    model.disable = disable;
    return model;
}


#pragma mark - equal method
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return NO;
    GosCalendarDetailViewCellModel *model = object;
    
    return [model.date isEqualToDate:self.date];
}


#pragma mark - private method
/// 根据选择与事件状态设置颜色
- (void)setupColorWithSelected:(BOOL)selected hasEvent:(BOOL)hasEvent disable:(BOOL)disable {
    // 没有事件    -> 0xCCCCCC
    // 有事件未选择 -> 0x1A1A1A
    // 有事件已选择 -> 0xFFFFFF
    self.textColor = disable ? GOS_COLOR_RGB(0xCCCCCC) : (!hasEvent ? GOS_COLOR_RGB(0xCCCCCC) : (selected ? GOS_COLOR_RGB(0xFFFFFF) : GOS_COLOR_RGB(0x1A1A1A)));
}


#pragma mark - getters and setters
- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    [self setupColorWithSelected:_selected hasEvent:_hasEvent disable:_disable];
}
- (void)setHasEvent:(BOOL)hasEvent {
    _hasEvent = hasEvent;
    
    [self setupColorWithSelected:_selected hasEvent:_hasEvent disable:_disable];
}

- (void)setDisable:(BOOL)disable {
    _disable = disable;
    
    [self setupColorWithSelected:_selected hasEvent:_hasEvent disable:_disable];
}

@end


#pragma mark - GosCalendarDetailViewCell
@interface GosCalendarDetailViewCell ()
/// 选择时的样式
@property (nonatomic, strong) CAShapeLayer *selectShapeLayer;
/// text
@property (nonatomic, strong) CATextLayer *cellTextLayer;
/// cell模型
@property (nonatomic, strong) GosCalendarDetailViewCellModel *cellModel;

@end

@implementation GosCalendarDetailViewCell
// cell id
static NSString *kGosCalendarDetailViewCellID = @"kGosCalendarDetailViewCellID";

#pragma mark - public method
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView
                             indexPath:(NSIndexPath *)indexPath
                                 model:(GosCalendarDetailViewCellModel *)model {
    // register cell
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:kGosCalendarDetailViewCellID];
    
    GosCalendarDetailViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kGosCalendarDetailViewCellID forIndexPath:indexPath];
    if (!cell) {
        cell = [[GosCalendarDetailViewCell alloc] initWithFrame:CGRectZero];
    }
    cell.cellModel = model;
    return cell;
}

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        // add subview
        [self.contentView.layer addSublayer:self.cellTextLayer];
        
        // adjust frame
        self.cellTextLayer.frame = CGRectMake(0, (self.contentView.frame.size.height - self.cellTextLayer.fontSize)/2.0, self.contentView.frame.size.width, self.cellTextLayer.fontSize);
        
    }
    return self;
}

#pragma mark - private method
- (UIBezierPath *)selectShapeLayerPath {
    // draw cycle path
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.contentView.frame.size.width * 0.5, self.contentView.frame.size.height * 0.5)
                                          radius:MAX(self.frame.size.width, self.frame.size.height) * 0.3
                                      startAngle:0
                                        endAngle:2 * M_PI
                                       clockwise:YES];
}

#pragma mark - getters and setters
- (void)setCellModel:(GosCalendarDetailViewCellModel *)cellModel {
    _cellModel = cellModel;
    
    // user interaction enable
    self.userInteractionEnabled = cellModel.isDisable ? NO : YES;
    
    // text layer
    self.cellTextLayer.string = cellModel.text;
    self.cellTextLayer.foregroundColor = [cellModel.textColor CGColor];
    
    // shape layer
    if ([self.selectShapeLayer superlayer]) [self.selectShapeLayer removeFromSuperlayer];
    // 选择后添加shape layer
    if (cellModel.isSelected) {
        [self.contentView.layer insertSublayer:self.selectShapeLayer below:self.cellTextLayer];
        self.selectShapeLayer.path = [self selectShapeLayerPath].CGPath;
    }
}

- (CAShapeLayer *)selectShapeLayer {
    if (!_selectShapeLayer) {
        _selectShapeLayer = [CAShapeLayer layer];
        _selectShapeLayer.fillColor = GOS_COLOR_RGB(0x55C7FC).CGColor;
        _selectShapeLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    return _selectShapeLayer;
}

- (CATextLayer *)cellTextLayer {
    if (!_cellTextLayer) {
        _cellTextLayer = [CATextLayer layer];
        _cellTextLayer.alignmentMode = kCAAlignmentCenter;
        _cellTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _cellTextLayer.foregroundColor = GOS_COLOR_RGB(0x1A1A1A).CGColor;
        _cellTextLayer.contentsGravity = kCAGravityCenter;
        // set font size
        UIFont *font = [UIFont systemFontOfSize:14];
        _cellTextLayer.fontSize = font.pointSize;
        // set font
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
        _cellTextLayer.font = fontRef;
        CGFontRelease(fontRef);
    }
    return _cellTextLayer;
}

@end


#pragma mark - GosCalenderDetailViewLayout : UICollectionViewLayout
@interface GosCalenderDetailViewLayout ()
@property (nonatomic, assign) NSInteger weekStartAtMonth;
@property (nonatomic, strong) NSMutableArray *attributeElements;
@end

@implementation GosCalenderDetailViewLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributeElements;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    self.weekStartAtMonth = [self.currentDate weekStartAtMonth]-1;
    
    [self.attributeElements removeAllObjects];
    
    for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [self.attributeElements addObject:attr];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = self.collectionView.bounds.size.width / 7;
    CGFloat h = self.collectionView.bounds.size.height / 6;
    CGFloat startX = _weekStartAtMonth * w;
    
    CGFloat x;
    CGFloat y;
    if(indexPath.item < 7 - _weekStartAtMonth) {
        x = indexPath.item % 7 * w + startX;
        y = 0;
    }else {
        x = (indexPath.item + _weekStartAtMonth) % 7 * w;
        y = (indexPath.item + _weekStartAtMonth) / 7 * h;
    }
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGRect rect = CGRectMake(x, y, w, h);
    attr.frame = rect;
    return attr;
}

- (NSMutableArray *)attributeElements {
    if (!_attributeElements) {
        _attributeElements = [NSMutableArray array];
    }
    return _attributeElements;
}
@end


