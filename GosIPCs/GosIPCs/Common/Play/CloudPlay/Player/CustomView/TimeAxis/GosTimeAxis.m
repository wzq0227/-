//  GosTimeAxis.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxis.h"
#import "GosTimeAxisView.h"
#import "GosTimeAxisRule.h"
#import "GosTimeAxisSegments.h"
#import "GosTimeAxis+Deceleration.h"
#import "GosTimeAxis+Generator.h"
#import "GosTimeAxisRuleGenerator.h"
#import "GosTimeAxisRuleRenderer.h"
#import "GosTimeAxisLayerRenderer.h"

@interface GosTimeAxis ()
/// 真正的时间轴视图
@property (nonatomic, strong) GosTimeAxisView *axisView;
/// 临时时间戳
@property (nonatomic, assign) NSTimeInterval tempTimeInterval;
/// 临时比例
@property (nonatomic, assign) CGFloat tempScale;
/// 当前的时间戳
@property (nonatomic, readwrite, assign) __block NSTimeInterval currentTimeInterval;
/// 当前的比例
@property (nonatomic, readwrite, assign) CGFloat currentScale;
/// 移动状态
@property (nonatomic, readwrite, assign, getter=isPaning) __block BOOL paning;
/// 捏合状态
@property (nonatomic, readwrite, assign, getter=isPinching) BOOL pinching;
/// 移动手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
/// 捏合手势
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
/// 刻度尺
@property (nonatomic, readwrite, copy) GosTimeAxisRule *rule;
/// 分段
@property (nonatomic, readwrite, copy) GosTimeAxisSegments *segments;

@end
@implementation GosTimeAxis

#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configComponent];
        
        [self configAppearance];
        
        [self configObservers];
    }
    return self;
}
- (void)dealloc {
    [self removeObservers];
    
    GosLog(@"---------- GosTimeAxis dealloc ----------");
}
- (void)configComponent {
    self.backgroundColor = [UIColor whiteColor];
    _currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    
    [self addSubview:self.axisView];
    
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.pinchGesture];
}
- (void)configAppearance {
    // 数据生产器
    _timeAxisGenerator = [[GosTimeAxisRuleGenerator alloc] initWithSize:self.axisView.frame.size];
    // 渲染类
    _timeAxisRenderer = [[GosTimeAxisRuleRenderer alloc] initWithSize:self.axisView.frame.size];
    
    [self updateTimeAxisViewWithGenerator:_timeAxisGenerator renderer:_timeAxisRenderer];
}
- (void)configObservers {
    [self addObserver:self forKeyPath:@"currentTimeInterval" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"currentScale" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"paning" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"pinching" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeObservers {
    [self removeObserver:self forKeyPath:@"currentTimeInterval"];
    [self removeObserver:self forKeyPath:@"currentScale"];
    [self removeObserver:self forKeyPath:@"paning"];
    [self removeObserver:self forKeyPath:@"pinching"];
}



#pragma mark - public method
- (void)updateWithDataArray:(NSArray<GosTimeAxisData *> *)dataArray {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakself updateTimeAxisDataWithDataArray:dataArray generator:weakself.timeAxisGenerator];
        [weakself.axisView setDataArray:dataArray];
        [weakself updateAxisViewDisplay];
    });
}

- (void)appendWithDataArray:(NSArray<GosTimeAxisData *> *)dataArray {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakself updateTimeAxisDataWithDataArray:dataArray generator:weakself.timeAxisGenerator];
        NSMutableArray *result = [NSMutableArray arrayWithArray:weakself.axisView.dataArray];
        [result addObjectsFromArray:dataArray];
        [weakself.axisView setDataArray:[result copy]];
        [weakself updateAxisViewDisplay];
    });
}

- (void)updateWithCurrentTimeInterval:(NSTimeInterval)currentTimeInterval {
    // 意义在外部赋值，不应受限（非无限情况下调用self.currentTimeInterval会限制当天赋值)
    // 而_currentTimeInterval不会触发setCurrentTimeInterval方法以及observer
    _currentTimeInterval = currentTimeInterval;
    self.currentTimeInterval = currentTimeInterval;
}

- (void)seekNextDataFromTimestamp:(NSTimeInterval)timestamp {
    [self seekNextDataSectionFromTimeInterval:timestamp dataArray:self.axisView.dataArray];
}

- (GosTimeAxisData *)findDataForTimestamp:(NSTimeInterval)timestamp onlyInternal:(BOOL)onlyInternal {
    return [self findDataSectionForTimeInterval:timestamp dataArray:self.axisView.dataArray onlyInternal:onlyInternal];
}

- (NSArray <GosTimeAxisData *> *)findSerialDataForTimestamp:(NSTimeInterval)timestamp {
    return [self findSerialDataSectionForTimeInterval:timestamp dataArray:self.axisView.dataArray];
}

- (void)updateWithExtraDataArray:(NSArray *)dataArray {
    NSAssert((_delegate && [_delegate respondsToSelector:@selector(convertExtraDataModel:)]), @"使用此方法必须实现代理方法convertExtraDataModel:");
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:dataArray.count];
    // 转化为GosTimeAxisData
    for (id element in dataArray) {
        GosTimeAxisData *convertedData = [_delegate convertExtraDataModel:element];
        if (convertedData && [convertedData isKindOfClass:[GosTimeAxisData class]]) {
            [temp addObject:convertedData];
        }
    }
    [self updateWithDataArray:[temp copy]];
}

- (void)updateWithExtraDataArray:(NSArray *)dataArray convertMethod:(GosTimeAxisData * _Nonnull (^)(id _Nonnull))convertMethod {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:dataArray.count];
    // 转化为GosTimeAxisData
    for (id element in dataArray) {
        GosTimeAxisData *convertedData = convertMethod(element);
        if (convertedData && [convertedData isKindOfClass:[GosTimeAxisData class]]) {
            [temp addObject:convertedData];
        }
    }
    [self updateWithDataArray:[temp copy]];
}

- (void)updateWithRuleAttribute:(NSDictionary<GosAttributeNameKey,id> *)attribute {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.rule.drawAttributes];
    [temp addEntriesFromDictionary:attribute];
    
    self.rule.drawAttributes = [temp copy];
    
    [self updateAxisViewDisplay];
}

- (void)updateWithSegementHourAttribute:(NSDictionary<GosAttributeNameKey,id> *)hourAttr
                        secondAttribute:(NSDictionary<GosAttributeNameKey,id> *)secondAttr
                   displayTimeAttribute:(NSDictionary<NSAttributedStringKey,id> *)displayTimeAttr {
    NSMutableDictionary *hourTemp = [self.segments.hourScaleDrawAttributes mutableCopy];
    NSMutableDictionary *secondTemp = [self.segments.secondScaleDrawAttributes mutableCopy];
    NSMutableDictionary *timeTemp = [self.segments.displayTimeDrawAttributes mutableCopy];
    
    [hourTemp addEntriesFromDictionary:hourAttr];
    [secondTemp addEntriesFromDictionary:secondAttr];
    [timeTemp addEntriesFromDictionary:displayTimeAttr];
    
    self.segments.hourScaleDrawAttributes = [hourTemp copy];
    self.segments.secondScaleDrawAttributes = [secondTemp copy];
    self.segments.displayTimeDrawAttributes = [timeTemp copy];
    
    [self updateAxisViewDisplay];
}

- (void)zoomToMax {
    if (self.currentScale != self.segments.maximumScale) {
        self.currentScale = self.segments.maximumScale;
    }
}

- (void)zoomToMin {
    if (self.currentScale != self.segments.minimumScale) {
        self.currentScale = self.segments.minimumScale;
    }
}

#pragma mark - private update method
/// 布局子类
- (void)layoutSubviews {
    [super layoutSubviews];
    GosLog(@"布局一次");
    self.axisView.frame = self.bounds;
    self.timeAxisGenerator.viewSize = self.axisView.frame.size;
    
    [self updateTimeAxisViewWithGenerator:self.timeAxisGenerator renderer:self.timeAxisRenderer];
}

/// 统一更新绘制方法
- (void)updateAxisViewDisplay {
    __weak typeof(self)weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.axisView setNeedsDisplay];
    });
}

/// 通过GosTimeAxisGenerator/GosTimeAxisRenderer更新绘制
- (void)updateTimeAxisViewWithGenerator:(GosTimeAxisGenerator *)generator renderer:(GosTimeAxisRenderer *)renderer {
    if (renderer) {
        // 更新渲染类
        self.axisView.renderer = renderer;
    }
    if (generator) {
        // 更新gender的同时更新你懂的
        self.axisView.appearanceArray = [self updateAppearanceArrayWithGenerator:generator timeAxisRule:&_rule timeAxisSegments:&_segments];
        
        // 更新数据，响应观察者更新绘图
        self.currentTimeInterval = _rule.currentTimeInterval;
        self.currentScale = _segments.currentScale;
    } else {
        // 手动更新绘图
        [self updateAxisViewDisplay];
    }
}
/// 更新当前时间算法
- (void)updateCurrentTimeIntervalFromTime:(NSTimeInterval)from direction:(GosTimeAxisDirection)direction offset:(CGPoint)offset viewSize:(CGSize)viewSize {
    
    CGFloat optimisticOffset = (direction == GosTimeAxisDirectionHorizontal)?offset.x:offset.y;
    CGFloat optimisticViewSize = (direction == GosTimeAxisDirectionHorizontal)?viewSize.width:viewSize.height;
    
    // 必须在主线程更新值，否则减速可能无法响应
    __weak typeof(self) weakself = self;
    NSTimeInterval tempTime = from - (optimisticOffset * 1.0 / [self.segments pixelOfASecondWithViewWidth:optimisticViewSize]);
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.currentTimeInterval = tempTime;
    });
}


#pragma mark - private help method
/// 从当前数据点获取连续的数据
- (NSArray <GosTimeAxisData *> *)findSerialDataSectionForTimeInterval:(NSTimeInterval)targetTimeInterval dataArray:(NSArray <GosTimeAxisData *> *)dataArray {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:1];
    // 默认 认定数组是按照时间排好序的
    for (int i = 0; i < [dataArray count]; i++) {
        GosTimeAxisData *subData = [dataArray objectAtIndex:i];
        // 当前时间戳所在的数据
        if (subData.startTimeInterval <= targetTimeInterval
            && subData.endTimeInterval >= targetTimeInterval) {
            GosLog(@"%s 从时间戳%.0f 找到数据", __PRETTY_FUNCTION__, targetTimeInterval);
            [result addObject:subData];
        }
        
        if ([result count] < 1) continue;

        GosTimeAxisData *lastInArray = [result lastObject];
        // 判断数组中的最后一个值是否与后面的数据存在连续
        if (subData.startTimeInterval == lastInArray.endTimeInterval) {
            [result addObject:subData];
        } else if (subData.startTimeInterval > lastInArray.endTimeInterval) {
            break;
        }

    }
    
    return [result copy];
}

/// 查找当前数据点
- (GosTimeAxisData *)findDataSectionForTimeInterval:(NSTimeInterval)targetTimeInterval dataArray:(NSArray <GosTimeAxisData *> *)dataArray onlyInternal:(BOOL)onlyInternal {
    if (onlyInternal) {
        // 必须是区间内
        for (int i = 0; i < [dataArray count]; i++) {
            GosTimeAxisData *subData = [dataArray objectAtIndex:i];
            if (subData.startTimeInterval <= targetTimeInterval
                && subData.endTimeInterval >= targetTimeInterval) {
                GosLog(@"%s 从时间戳%.0f 找到数据", __PRETTY_FUNCTION__, targetTimeInterval);
                return subData;
                
            }
        }
    } else {
        // 非区间内
        for (int i = 0; i < [dataArray count]; i++) {
            GosTimeAxisData *subData = [dataArray objectAtIndex:i];
            if ((subData.startTimeInterval <= targetTimeInterval
                && subData.endTimeInterval >= targetTimeInterval)
                || (subData.startTimeInterval > targetTimeInterval)) {
                GosLog(@"%s 从时间戳%.0f 找到数据", __PRETTY_FUNCTION__, targetTimeInterval);
                return subData;
                
            }
        }
    }
    GosLog(@"%s 从时间戳%.0f 没找到数据", __PRETTY_FUNCTION__, targetTimeInterval);
    return nil;
}

/// 查找下一个数据点
- (void)seekNextDataSectionFromTimeInterval:(NSTimeInterval)targetTimeInterval dataArray:(NSArray <GosTimeAxisData *> *)dataArray {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL exist = NO;
        GosTimeAxisData *existModel = nil;
        for (int i = 0; i < [dataArray count]; i++) {
            GosTimeAxisData *subData = [dataArray objectAtIndex:i];
            
            if (subData.startTimeInterval >= targetTimeInterval) {
                exist = YES;
                existModel = subData;
                break;
            }
        }
        if (exist && existModel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(timeAxis:didSeekedNextDataSection:fromPositionTimestamp:)]) {
                    [weakself.delegate timeAxis:weakself didSeekedNextDataSection:[existModel copy] fromPositionTimestamp:targetTimeInterval];
                }
            });
        } else if (!exist) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.delegate timeAxis:weakself didNotSeekNextDataFromPositionTimestamp:targetTimeInterval];
            });
        }
        
    });
}

/// 判断在停止拖动的情况下，数据数组是否存在包含当前时间的数据项
- (void)judgeExistDataInTheInterval:(NSTimeInterval)targetTimeInterval fromDataArray:(NSArray <GosTimeAxisData *> *)dataArray withPanState:(BOOL)isPaning {
    if (isPaning == YES || !dataArray) return;
    
    if ([dataArray count] == 0) return ;
    
    // 异步处理数组
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        @synchronized (self) {
            BOOL exist = NO;
            GosTimeAxisData *existModel = nil;
            for (int i = 0; i < [dataArray count]; i++) {
                GosTimeAxisData *subData = [dataArray objectAtIndex:i];
                
                if (subData.startTimeInterval > targetTimeInterval) break;
                
                if (subData.startTimeInterval <= targetTimeInterval && subData.endTimeInterval >= targetTimeInterval) {
                    exist = YES;
                    existModel = subData;
                    
                    break;
                }
            }
            if (exist && existModel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(timeAxis:didEndedAtDataSection:positionTimestamp:)]) {
                        [weakself.delegate timeAxis:weakself didEndedAtDataSection:[existModel copy] positionTimestamp:targetTimeInterval];
                    }
                });
            } else if (!exist) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.delegate timeAxis:weakself didEndedAtPostionWithoutData:targetTimeInterval];
                });
            }
//        }
    });
}



#pragma mark - observer changed method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTimeInterval"] || [keyPath isEqualToString:@"currentScale"]) {
        _rule.currentTimeInterval = _currentTimeInterval;
        _segments.currentScale = _currentScale;
        // 这里通知当前时间改变
        [self updateAxisViewDisplay];
    }
    // 代理的发出
    if ([keyPath isEqualToString:@"currentTimeInterval"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(timeAxis:didChangedTimeInterval:)]) {
            [_delegate timeAxis:self didChangedTimeInterval:_currentTimeInterval];
        }
        // 判断停止时是否存在数据
        [self judgeExistDataInTheInterval:_currentTimeInterval fromDataArray:self.axisView.dataArray withPanState:self.isPaning];
        
    } else if ([keyPath isEqualToString:@"currentScale"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(timeAxis:didChangedScale:)]) {
            [_delegate timeAxis:self didChangedScale:_currentScale];
        }
    } else if ([keyPath isEqualToString:@"paning"]) {
        
        if (self.isPaning) {
            if (_delegate && [_delegate respondsToSelector:@selector(timeAxisDidBeginScrolling:)]) {
                [_delegate timeAxisDidBeginScrolling:self];
            }
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(timeAxisDidEndScrolling:)]) {
                [_delegate timeAxisDidEndScrolling:self];
            }
        }
    } else if ([keyPath isEqualToString:@"pinching"]) {
        
        if (self.isPinching) {
            if (_delegate && [_delegate respondsToSelector:@selector(timeAxisDidBeginPinching:)]) {
                [_delegate timeAxisDidBeginPinching:self];
            }
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(timeAxisDidEndPinching:)]) {
                [_delegate timeAxisDidEndPinching:self];
            }
        }
    }
}
#pragma mark - gesture recongnizer method
/// 单手拖动响应
- (void)panAction:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            self.paning = YES;
            _tempTimeInterval = _currentTimeInterval;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [sender translationInView:sender.view];
            [self updateCurrentTimeIntervalFromTime:_tempTimeInterval direction:_rule.axisDirection offset:point viewSize:self.axisView.frame.size];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // 松手后的速度——即理论上脱手后能达到的偏移距离，乘以0.5是怕你飘了~
            CGPoint velocity = [sender velocityInView:sender.view];
            velocity.x *= 0.2;
            velocity.y *= 0.2;
            CGSize viewSize = self.axisView.frame.size;
            // 更新temp的值 指向松手后的点
            _tempTimeInterval = _currentTimeInterval;
            
            // 模拟减速效果
            __weak typeof(self) weakself = self;
            [self deceleratingAnimateWithVelocityPoint:velocity action:^(CGPoint deceleratingSpeedPoint, BOOL stop) {
                
                if (stop) {
                    weakself.paning = NO;
                }
                
                // deceleratingSpeedPoint是衰减速度，与velocity的意思一样，它是由velocity值慢慢衰减到0的
                // 两个的差值即每隔一定时间的变化量 与 手势状态UIGestureRecognizerStateChanged反馈的效果一致
                [weakself updateCurrentTimeIntervalFromTime:weakself.tempTimeInterval direction:weakself.rule.axisDirection offset:CGPointMake(velocity.x - deceleratingSpeedPoint.x, velocity.y - deceleratingSpeedPoint.y) viewSize:viewSize];
            }];
            break;
        }
        default:
            self.paning = NO;
            break;
    }
}
/// 两手指捏合响应
- (void)pinchAction:(UIPinchGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            _tempScale = _currentScale;
            self.pinching = YES;
            break;
        case UIGestureRecognizerStateChanged:
            self.currentScale = _tempScale + sender.scale - 1;
            break;
        default:
            self.pinching = NO;
            break;
    }
}

#pragma mark - getters and setters
- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        _panGesture.maximumNumberOfTouches = 1;
    }
    return _panGesture;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    }
    return _pinchGesture;
}

- (GosTimeAxisView *)axisView {
    if (!_axisView) {
        _axisView = [[GosTimeAxisView alloc] initWithFrame:self.bounds];
    }
    return _axisView;
}

- (void)setCurrentTimeInterval:(NSTimeInterval)currentTimeInterval {
    if (self.isInfinitely) {
        // 无限滚动 直接复制
        _currentTimeInterval = currentTimeInterval;
        return ;
    }
    // 非无限滚动，则限制在一天内
    // 00:00:00
    NSTimeInterval dayInBegin = [[[NSCalendar currentCalendar] dateFromComponents:[[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate dateWithTimeIntervalSince1970:_currentTimeInterval]]] timeIntervalSince1970];
    // 23:59:59
    NSTimeInterval dayInEnd = dayInBegin + 24*60*60-1;
    
    if (currentTimeInterval >= dayInBegin
        && currentTimeInterval <= dayInEnd) {
        _currentTimeInterval = currentTimeInterval;
        
    } else if (currentTimeInterval < dayInBegin) {
        _currentTimeInterval = dayInBegin;
        [self manuallyStopDeceleratingInvokeInMain];
        
    } else if (currentTimeInterval > dayInEnd) {
        _currentTimeInterval = dayInEnd;
        [self manuallyStopDeceleratingInvokeInMain];
        
    }
}

- (void)setCurrentScale:(CGFloat)currentScale {
    // 优化比例值
    if (_segments) {
        [_segments optimiseScale:&currentScale];
    }
    _currentScale = currentScale;
}

- (void)setInfinitely:(BOOL)infinitely {
    _infinitely = infinitely;
    
    // 更新segement的无限状态
    self.segments.infinitely = infinitely;
}

- (void)setTimeAxisRenderer:(GosTimeAxisRenderer *)timeAxisRenderer {
    _timeAxisRenderer = timeAxisRenderer;
    
    [self updateTimeAxisViewWithGenerator:nil renderer:timeAxisRenderer];
}

- (void)setTimeAxisGenerator:(GosTimeAxisGenerator *)timeAxisGenerator {
    _timeAxisGenerator = timeAxisGenerator;
    
    [self updateTimeAxisViewWithGenerator:timeAxisGenerator renderer:nil];
}

- (void)manuallyStopDeceleratingContinueDealInMain {
    // 更新变量
    self.paning = NO;
    self.currentTimeInterval = _rule.currentTimeInterval;
}
@end
