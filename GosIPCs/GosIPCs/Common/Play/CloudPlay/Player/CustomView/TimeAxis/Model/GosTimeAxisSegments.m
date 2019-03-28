//  GosTimeAxisSegments.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/27.
//  Copyright © 2018年 goscam. All rights reserved.

#import "GosTimeAxisSegments.h"

@interface GosTimeAxisSegments ()
/// 最小比例，默认为1.0
@property (nonatomic, readwrite, assign) CGFloat minimumScale;
/// 最大比例，限制最小为2.0
@property (nonatomic, readwrite, assign) CGFloat maximumScale;

/// 斜率数组
@property (nonatomic, copy) NSArray *slopeArray;
/// 系数数组
@property (nonatomic, copy) NSArray *coefficientArray;
/// 一小时分段数
@property (nonatomic, readwrite, assign) NSUInteger segmentOfSecond;
/// 分段比例——正确的放大比例
@property (nonatomic, readwrite, assign) CGFloat segmentOfScale;
/// 分段对应的显示类型
@property (nonatomic, readwrite, assign) SegmentDisplayTimeType segmentOfTimeType;

@end

@implementation GosTimeAxisSegments
#pragma mark - initialization
- (instancetype)init {
    if (self = [super init]) {
        _currentScale = 1.0;
        _minimumScale = 1.0;
        _segmentInfoArray = @[[SegmentInfoModel oneScaleInfoModel]];
    }
    return self;
}

#pragma mark - visitor method
- (void)acceptVisitor:(id<GosTimeAxisVisitor>)visitor {
    [visitor visitTimeAxisSegments:self];
}


#pragma mark - public method
/// 获取每秒的像素
- (CGFloat)pixelOfASecondWithViewWidth:(CGFloat)width {
    return ((width/self.visibleOfMaxHoursInOneScale)*self.segmentOfScale)/MAX_SECONDS_IN_AN_HOUR;
}

/// 获取分段显示时间
- (NSString *)optimiseTimeStringDisplayFromHour:(NSInteger)hour minute:(NSInteger)minute {
    
    NSMutableString *result = [NSMutableString string];
    if (_segmentOfTimeType & SegmentDisplayTimeTypeHour) {
        [result appendFormat:@"%02zd", _infinitely ? (hour > 23 ? hour - 24 : (hour < 0 ? hour + 24 : hour)) : (hour)];
    }
    if (_segmentOfTimeType & SegmentDisplayTimeTypeMinute) {
        [result appendFormat:@":%02zd", minute / 60];
    }
    if (_segmentOfTimeType & SegmentDisplayTimeTypeSecond) {
        [result appendFormat:@":%02zd", minute % 60];
    }
    return [result copy];
}
/// 优化比例
- (void)optimiseScale:(CGFloat *)scale {
    if (*scale < _minimumScale) {
        *scale = _minimumScale;
    } else if (*scale > _maximumScale) {
        *scale = _maximumScale;
    }
}

#pragma mark - private method
/// 优化segmentInfoArray
- (void)optimiseSegmentInfoArray:(NSArray <SegmentInfoModel *> *__strong*)segmentInfoArray {
    NSMutableArray *temp = [NSMutableArray array];
    // 去重
    for (SegmentInfoModel *model in *segmentInfoArray) {
        GosLog(@"遍历model - %@", model);
        if (![temp containsObject:model]) {
            GosLog(@"添加model - %@", model);
            [temp addObject:model];
        }
    }
    // 判断是否存在1.0比例的模型
    SegmentInfoModel *oneScaleModel = [SegmentInfoModel oneScaleInfoModel];
    if (![temp containsObject:oneScaleModel]) {
        [temp addObject:oneScaleModel];
    }
    
    // 排序
    [temp sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    *segmentInfoArray = [temp copy];
}
/// 根据当前比例与segmentInfoArray 更新值分段比例，小时分段数，分段显示类型
- (void)updateSegmentsWithCurrentScale:(CGFloat)currentScale segmentInfoArray:(NSArray <SegmentInfoModel *> *)segmentInfoArray {
    
    for (int i = 0; i < [self.segmentInfoArray count]-1; i++) {
        if (currentScale >= segmentInfoArray[i].scaleMatchASegmentOfSeconds.x
            && currentScale < segmentInfoArray[i+1].scaleMatchASegmentOfSeconds.x) {
            // 得到区间，计算segmentScale，取segmentHour
            self.segmentOfScale = [self usePiecewiseFunctionForCaculateYPointWithXPoint:currentScale slope:[_slopeArray[i] floatValue] coefficient:[_coefficientArray[i] floatValue]];
            self.segmentOfSecond = (NSUInteger)segmentInfoArray[i].scaleMatchASegmentOfSeconds.y;
            self.segmentOfTimeType = segmentInfoArray[i].displayTimeType;
            break;
        } else if (currentScale == [segmentInfoArray lastObject].scaleMatchASegmentOfSeconds.x) {
            
            // 得到区间，计算segmentScale，取segmentHour
            self.segmentOfScale = [self usePiecewiseFunctionForCaculateYPointWithXPoint:currentScale slope:[_slopeArray[[self.segmentInfoArray count]-2] floatValue] coefficient:[_coefficientArray[[self.segmentInfoArray count]-2] floatValue]];
            self.segmentOfSecond = (NSUInteger)[segmentInfoArray lastObject].scaleMatchASegmentOfSeconds.y;
            self.segmentOfTimeType = [segmentInfoArray lastObject].displayTimeType;
            break;
        }
        continue;
    }
}
/// 更新最小比例与最大比例
- (void)updateScalesWithSegmentInfoArray:(NSArray <SegmentInfoModel *> *)segmentInfoArray {
    
    self.minimumScale = [segmentInfoArray firstObject].scaleMatchASegmentOfSeconds.x;
    self.maximumScale = [segmentInfoArray lastObject].scaleMatchASegmentOfSeconds.x;
}
#pragma mark - Piecewise Function 分段函数
/// 生成分段函数
- (void)generatorPiecewiseFunctionWithSegmentInfoArray:(NSArray <SegmentInfoModel *> *)segmentInfoArray {
    NSArray *xPoints;
    NSArray *yPoints;
    
    // 生成x,y points
    [self generatePiecewiseFunctionXYPointsFromSegmentInfoArray:segmentInfoArray forXPoints:&xPoints yPoints:&yPoints];
    
    NSArray *slopes;
    NSArray *coefficients;
    // 生成斜率，系数
    [self generatePiecewiseFunctionParametersWithXPoints:xPoints yPoints:yPoints forSlopes:&slopes coefficients:&coefficients];
    
    // 赋值给全局变量
    _slopeArray = slopes;
    _coefficientArray = coefficients;
}
/// 生成分段函数的点集
- (void)generatePiecewiseFunctionXYPointsFromSegmentInfoArray:(NSArray <SegmentInfoModel *> *)segmentInfoArray forXPoints:(NSArray *__strong*)xPoints yPoints:(NSArray *__strong*)yPoints {
    // scale==1.0时的second值
    float secondsOfOneScale = MAX_SECONDS_IN_AN_HOUR;
    for (SegmentInfoModel *model in segmentInfoArray) {
        // 取出scale==1.0时的second值
        if (model.scaleMatchASegmentOfSeconds.x == 1.0) {
            secondsOfOneScale = model.scaleMatchASegmentOfSeconds.y;
            break;
        }
    }
    
    // xPoints
    NSMutableArray *xPointsTemp = [NSMutableArray arrayWithCapacity:[segmentInfoArray count]];
    
    // yPoints
    NSMutableArray *yPointsTemp = [NSMutableArray arrayWithCapacity:[segmentInfoArray count]];
    for (int i = 0; i < [segmentInfoArray count]; i++) {
        SegmentInfoModel *model = segmentInfoArray[i];
        GosLog(@"%d - (%.2f, (%.2f/%.2f=%.2f))", i, model.scaleMatchASegmentOfSeconds.x, secondsOfOneScale, model.scaleMatchASegmentOfSeconds.y, secondsOfOneScale/model.scaleMatchASegmentOfSeconds.y);
        // x
        [xPointsTemp addObject:@(segmentInfoArray[i].scaleMatchASegmentOfSeconds.x)];
        // y
        NSUInteger seconds = segmentInfoArray[i].scaleMatchASegmentOfSeconds.y;
        float y = secondsOfOneScale / seconds * 1.0;
        [yPointsTemp addObject:@(y)];
    }
    for (int i = 0; i < xPointsTemp.count; i++) {
        GosLog(@"生成点(%@, %@)", xPointsTemp[i], yPointsTemp[i]);
    }
    *xPoints = [xPointsTemp copy];
    *yPoints = [yPointsTemp copy];
}
/// 生成分段函数的参数——斜率，系数
- (void)generatePiecewiseFunctionParametersWithXPoints:(NSArray *)xPoints yPoints:(NSArray *)yPoints forSlopes:(NSArray *__strong*)slopes coefficients:(NSArray *__strong*)coefficients {
    NSAssert([xPoints count] == [yPoints count], @"x与y数组的元素数量必须相等");
    NSUInteger count = [xPoints count];
    // 斜率数组
    NSMutableArray *slopesTemp = [NSMutableArray arrayWithCapacity:count];
    // 系数数组
    NSMutableArray *coefficientsTemp = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count-1; i++) {
        // 得到两点的x,y坐标
        float y0 = [yPoints[i] floatValue];
        float y1 = [yPoints[i+1] floatValue];
        float x0 = [xPoints[i] floatValue];
        float x1 = [xPoints[i+1] floatValue];
        
        float slope = (y1 - y0)/(x1 - x0);
        float coefficient = y0 - (x0) * slope;
        
        [slopesTemp addObject:@(slope)];
        [coefficientsTemp addObject:@(coefficient)];
    }
    
    *slopes = [slopesTemp copy];
    *coefficients = [coefficientsTemp copy];
}
/// 使用分段函数计算 Y = x * 斜率 + 系数
- (float)usePiecewiseFunctionForCaculateYPointWithXPoint:(float)xPoint slope:(float)slope coefficient:(float)coeffieient {
    return xPoint * slope + coeffieient;
}


#pragma mark - getters and setters
- (void)setCurrentScale:(CGFloat)currentScale {
    // 优化比例值
    [self optimiseScale:&currentScale];
    
//    if (currentScale == _currentScale) return ;
    
    _currentScale = currentScale;
    
    // 更新值
    [self updateSegmentsWithCurrentScale:currentScale segmentInfoArray:self.segmentInfoArray];
}

- (void)setSegmentInfoArray:(NSArray<SegmentInfoModel *> *)segmentInfoArray {
    NSAssert([segmentInfoArray count] > 0, @"segmentInfoArray不能为空");
    
    // 优化数组
    [self optimiseSegmentInfoArray:&segmentInfoArray];
    
    _segmentInfoArray = segmentInfoArray;
    
    // 更新值
    [self updateScalesWithSegmentInfoArray:segmentInfoArray];
    // 生成分段函数
    [self generatorPiecewiseFunctionWithSegmentInfoArray:segmentInfoArray];
}

- (NSDictionary *)hourScaleDrawAttributes {
    if (!_hourScaleDrawAttributes) {
        _hourScaleDrawAttributes = [NSDictionary dictionary];
    }
    return _hourScaleDrawAttributes;
}
- (NSDictionary *)secondScaleDrawAttributes {
    if (!_secondScaleDrawAttributes) {
        _secondScaleDrawAttributes = [NSDictionary dictionary];
    }
    return _secondScaleDrawAttributes;
}
- (NSDictionary *)displayTimeDrawAttributes {
    if (!_displayTimeDrawAttributes) {
        _displayTimeDrawAttributes = [NSDictionary dictionary];
    }
    return _displayTimeDrawAttributes;
}


@end

#pragma mark - SegmentInfoModel 分段信息模型
@implementation SegmentInfoModel
#pragma mark - initialization
+ (SegmentInfoModel *)segmentInfoModelWithScale:(CGFloat)scale seconds:(CGFloat)seconds displayTimeType:(SegmentDisplayTimeType)displayTimeType {
    SegmentInfoModel *model = [[SegmentInfoModel alloc] init];
    model.scaleMatchASegmentOfSeconds = CGPointMake(scale, seconds);
    model.displayTimeType = displayTimeType;
    return model;
}
+ (SegmentInfoModel *)oneScaleInfoModel {
    SegmentInfoModel *model = [[SegmentInfoModel alloc] init];
    model.scaleMatchASegmentOfSeconds = CGPointMake(1.0, 3600.0);
    model.displayTimeType = SegmentDisplayTimeTypeHourAndMinute;
    return model;
}
- (instancetype)init {
    if (self = [super init]) {
        // 默认显示小时与分钟
        _displayTimeType = SegmentDisplayTimeTypeHourAndMinute;
    }
    return self;
}
#pragma mark - setters
- (void)setScaleMatchASegmentOfSeconds:(CGPoint)scaleMatchASegmentOfSeconds {
    CGFloat scale = scaleMatchASegmentOfSeconds.x;
    CGFloat seconds = scaleMatchASegmentOfSeconds.y;
    // 限定scale取值范围 (0<=~无穷);
    NSAssert(scale > 0, @"scale必须大于0");
    
    // 限定seconds取值范围 (0<~<=MAX_SECONDS_IN_AN_HOUR)
    if (seconds > MAX_SECONDS_IN_AN_HOUR || seconds <= 0) {
        seconds = MAX_SECONDS_IN_AN_HOUR;
    }
    _scaleMatchASegmentOfSeconds = CGPointMake(scale, seconds);
}
#pragma mark - compare method
- (NSComparisonResult)compare:(SegmentInfoModel *)otherModel {
    
    NSAssert([otherModel isKindOfClass:[self class]], @"otherModel是%@非%@类型无法比较", NSStringFromClass([otherModel class]), NSStringFromClass([self class]));
    
    if (self.scaleMatchASegmentOfSeconds.x > otherModel.scaleMatchASegmentOfSeconds.x) {
        return NSOrderedDescending;
    } else if (self.scaleMatchASegmentOfSeconds.x < otherModel.scaleMatchASegmentOfSeconds.x) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}
#pragma mark - equal method
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return NO;
    
    SegmentInfoModel *model = object;
    // 判断scale相等即为相等
    if (self.scaleMatchASegmentOfSeconds.x == model.scaleMatchASegmentOfSeconds.x) return YES;
    
    return NO;
}



@end
