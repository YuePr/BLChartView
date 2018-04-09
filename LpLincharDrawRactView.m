//
//  LpLincharDrawRactView.m
//  BLChartView
//
//  Created by YuePr.Guangz on 2016/11/28.
//  Copyright © 2016年 YuePr.Guangz. All rights reserved.
//

#import "LpLincharDrawRactView.h"
@interface LpLincharDrawRactView(){
    float lineFactor;
    float lineSpacing;
    float horizontalPadding;
    float riseTime ;
    float retentionTime;
    float fallTime;
    float slotTime;
    Byte currentState;
    CGPoint firstPoint;
    CGPoint currentPoint;
    CGPoint lastPoint;
    CGPoint startPoint;
    CGPoint endPoint;
    float scaleSpacing;
    float stateElapsedTime;
    
}



@property(nonatomic,strong)UIBezierPath *                   paintDottedLine;
@property(nonatomic,strong)UIBezierPath *                   paintScale;
@property(nonatomic,strong)UIBezierPath *                   paintScaleLarge;
@property(nonatomic,strong)UIBezierPath *                   paintScaleText;
@property(nonatomic,strong)UIBezierPath *                   paintBrokenLine;
@property(nonatomic,strong)UIBezierPath *                   paintPointWhite;
@property(nonatomic,strong)UIBezierPath *                   paintVerticalLine;
@property(nonatomic,strong)UIBezierPath *                   framePaint;
@property(nonatomic,strong)NSArray<NSString *>*                    scaleText;
@property(nonatomic,strong)NSMutableArray *                        pastPointQueue;
@property(nonatomic,strong)NSMutableArray *                        forecastPointQueue;
@property(nonatomic,strong)NSMutableArray *                        pointQueue;


@property(nonatomic,strong) CAShapeLayer *                          brokenLineLayer;
@property(nonatomic,strong)CAShapeLayer *                           paint_LineLayer;

@property(nonatomic,strong)CAShapeLayer *                           solidShapeLayer ;
@property(nonatomic,strong)CAShapeLayer *                           largeScaleLayer ;
@property(nonatomic,strong)CAShapeLayer *                           verticalLineLayer;



@end


@implementation LpLincharDrawRactView
float MAX_SCALE = 30;


struct DDPoint {
    float  x;
    float  y;
};
typedef struct DDPoint DDPoint;
    
-(instancetype)init{
    if (self=[super init]) {
        
        
        DDPoint po ;
        po.x = -12;
        po.y = -9;
        NSString *strrrr = [NSString stringWithFormat:@"%f",po.x];
        DLog(@"%@",[NSString stringWithFormat:@"%f",po.x]);
        DLog(@"%f",[strrrr floatValue])
        
        
        
        horizontalPadding = 10.0f;
        lineFactor = 15.f;
        lineSpacing = 24.0f;
        _scaleText = @[@"-30s",@"-20s",@"-10s",NSLocalizedString(@"current_time", nil),@"10s",@"20s",@"30s"];
        _paintDottedLine = [UIBezierPath bezierPath];
//        _paintDottedLine.lineCapStyle = kCALineCapButt;
        _paintDottedLine.lineWidth = lineFactor*0.08f;
        
        _paintScale = [UIBezierPath bezierPath];
        _paintScale.lineWidth = lineFactor*0.1f;
        
        _paintScaleLarge = [UIBezierPath bezierPath];
        _paintScaleLarge.lineWidth = lineFactor *0.2f;
        
        _paintScaleText = [UIBezierPath bezierPath];
        
        _pastPointQueue = [NSMutableArray array];
        _forecastPointQueue = [NSMutableArray array];
        _pointQueue = [NSMutableArray array];
        
        currentState = KPHASE_WAIT;

        stateElapsedTime = 0;
        firstPoint = CGPointMake(0, 0);
        currentPoint = CGPointMake(0, 0);
        lastPoint = CGPointMake(MAX_SCALE, 0);
        startPoint = CGPointMake(0, 0);
        endPoint = CGPointMake(0, 0);
        scaleSpacing = (SCREEN_WIDTH-2*horizontalPadding)/(2 * MAX_SCALE);
       
    }
    self.backgroundColor = RGB(240, 240, 240);
    return self;
}



-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (self.brokenLineLayer) {
        [self.brokenLineLayer removeFromSuperlayer];
    }
    if (self.paint_LineLayer) {
        [self.paint_LineLayer removeFromSuperlayer];
    }
    if (self.solidShapeLayer) {
        [self.solidShapeLayer removeFromSuperlayer];
    }
    if (self.largeScaleLayer) {
        [self.largeScaleLayer removeFromSuperlayer];
    }
   CGContextClearRect(UIGraphicsGetCurrentContext(), self.frame);
    self.clearsContextBeforeDrawing = YES;
    [self drawBrokenLine];
    [self drawCoordinate];
    [self drawData];
    
    
//    DLog(@"0000000000000000000000000drawRectdrawRectdrawRect")
    }
-(void)drawCoordinate{
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    //    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    UIBezierPath*  path = [UIBezierPath bezierPath];
    CGContextSetLineWidth(currentContext, 0.5f);
    path.lineWidth = 0.5f;
    CGFloat arr[] = {3,3};
    for (int i=0; i<3; ++i) {
        float hheight = lineSpacing*(i+1);
        [path moveToPoint:CGPointMake(horizontalPadding,hheight)];
        [path addLineToPoint:CGPointMake(SCREEN_WIDTH-horizontalPadding, hheight)];
        CGContextSetStrokeColorWithColor(currentContext, [UIColor grayColor].CGColor);
        //设置虚线排列的宽度间隔:下面的arr中的数字表示先绘制3个点再绘制1个点
        //下面最后一个参数“2”代表排列的个数。
        CGContextSetLineDash(currentContext, 0, arr, 2);
        //            CGContextClosePath(currentContext);
        [path stroke];
    }

    float y = lineSpacing * 4;
    CAShapeLayer *solidShapeLayer = [CAShapeLayer layer];
    CAShapeLayer *largeScaleLayer = [CAShapeLayer layer];
    CGMutablePathRef solidShapePath =  CGPathCreateMutable();
    CGMutablePathRef  largeScalePath = CGPathCreateMutable();
    [solidShapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [solidShapeLayer setStrokeColor:[[UIColor grayColor] CGColor]];
    solidShapeLayer.lineWidth = 0.7f ;
    CGPathMoveToPoint(solidShapePath, NULL, 0, y);
    CGPathAddLineToPoint(solidShapePath, NULL, SCREEN_WIDTH,y);
    
    [solidShapeLayer setPath:solidShapePath];
    CGPathRelease(solidShapePath);
    [self.layer addSublayer:solidShapeLayer];
    
    
    
#pragma mark - 绘制大小刻度
    [largeScaleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [largeScaleLayer setStrokeColor:[[UIColor grayColor] CGColor]];
    largeScaleLayer.lineWidth = 1.0f ;
    
    for (int i = (int) -MAX_SCALE; i<=(int)MAX_SCALE; ++i) {
        float postX = SCREEN_WIDTH/2.f + i*scaleSpacing;
//        DLog(@"[i = %d],[SCREEN_WIDTH = %f],[postX =  %f],[y = %f],[y-scaleSpacing =  %f],[y-scaleSpacing/2.f = %f]",i,SCREEN_WIDTH,postX,y,y-scaleSpacing,y-scaleSpacing/2.f);
        
        if (0==(i % 10)) {
            
            
            
            CGPathMoveToPoint(largeScalePath, NULL, postX, y);
            CGPathAddLineToPoint(largeScalePath, NULL, postX, y-scaleSpacing);
            
            }else{
                
                CGPathMoveToPoint(largeScalePath, NULL, postX, y);
                CGPathAddLineToPoint(largeScalePath, NULL, postX, y-scaleSpacing/2.0f);
        }
        
    }
    [largeScaleLayer setPath:largeScalePath];
    CGPathRelease(largeScalePath);
    [self.layer addSublayer:largeScaleLayer];
#pragma mark - 绘制文字
    
    float scaleTextPaddingTpp = 10.0f;
    NSMutableDictionary *scaleTextDict = [NSMutableDictionary dictionary];
    scaleTextDict[NSForegroundColorAttributeName] = [UIColor grayColor];
    scaleTextDict[NSFontAttributeName] = [UIFont systemFontOfSize:11.0f];
    for (int i=0; i<_scaleText.count; ++i) {
        float textPostX = horizontalPadding +i*10*scaleSpacing-([_scaleText[i] sizeWithAttributes:scaleTextDict ].width/2);
        
        //3.绘制到View中
        [_scaleText[i] drawAtPoint:CGPointMake(textPostX , y+scaleTextPaddingTpp) withAttributes:scaleTextDict];
    }
    
    
    
    self.largeScaleLayer = largeScaleLayer;
    self.solidShapeLayer = solidShapeLayer;

}

-(void)drawBrokenLine{
    
    
    
    
    CGContextRef currentContextt = UIGraphicsGetCurrentContext();
    CAShapeLayer *brokenLineLayer = [CAShapeLayer layer];
    CGMutablePathRef  brokenLinePath = CGPathCreateMutable();
    CGContextBeginPath(currentContextt);
    [brokenLineLayer setFillColor:[[UIColor clearColor] CGColor]];
    [brokenLineLayer setStrokeColor:[[UIColor grayColor] CGColor]];
    brokenLineLayer.lineWidth = 1 ;
    NSMutableArray *pointArr = [NSMutableArray array];


    
    float startX = 0,startY = 0;
    float endX = 0, endY = 0;
    if (_pointQueue.count > 0) {

        CGPoint point = [[_pointQueue firstObject]CGPointValue];
        startX = point.x;
        startY = point.y;
        point = [[_pointQueue lastObject]CGPointValue];
        endX = point.x;
        endY = point.y;
        
    }
    
    float x1;
    float y1;
    float x2 = startX;
    float y2 = startY;
    float baseX = SCREEN_WIDTH *0.5f;
    float baseY = lineSpacing *3;
    
//    CGPathMoveToPoint(brokenLinePath, NULL, baseX
//                        , baseY + lineSpacing);
    CGPathMoveToPoint(brokenLinePath, NULL, baseX + startX * scaleSpacing
                      , baseY + lineSpacing);

    CGPoint pointttt;
    CGContextBeginPath(currentContextt);
    for (NSValue *pointValue in _pointQueue) {
        pointttt = [pointValue CGPointValue];
        x1 = x2;
        y1 = y2;
        x2 = pointttt.x;
        y2 = pointttt.y;
        if ((x1 != x2 )|| (y1 != y2)) {
            [pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(baseX + x2 * scaleSpacing,baseY-y2 *lineSpacing)]];
            CGPathAddLineToPoint(brokenLinePath, NULL, baseX + x1*scaleSpacing, baseY - y1*lineSpacing);
        }
    }
    CGPathAddLineToPoint(brokenLinePath, NULL, baseX + endX * scaleSpacing, baseY - endY * lineSpacing);
    CGPathAddLineToPoint(brokenLinePath, NULL, baseX + endX * scaleSpacing, baseY + lineSpacing);
    CGPathAddLineToPoint(brokenLinePath, NULL, baseX + startX, baseY + lineSpacing);
    CGPathCloseSubpath(brokenLinePath);
    
    [brokenLineLayer setPath:brokenLinePath];
    CGPathCloseSubpath(brokenLinePath);
    CGPathRelease(brokenLinePath);
    [self.layer addSublayer:brokenLineLayer];
    
    

    CAShapeLayer *paint_LineLayer = [CAShapeLayer layer];
    CGMutablePathRef  paint_LinePath = CGPathCreateMutable();
    CGContextBeginPath(currentContextt);
    [paint_LineLayer setFillColor:[[UIColor clearColor] CGColor]];
    [paint_LineLayer setStrokeColor:[[UIColor orangeColor] CGColor]];
    paint_LineLayer.lineWidth = 1.5f;
    x2 = baseX + startX *scaleSpacing;
    y2 = baseY - startY *lineSpacing;
    
    
    
    for (NSValue  *pointVlue in pointArr) {
        CGPoint pointts = [pointVlue CGPointValue];
        x1 = x2;
        y1 = y2;
        x2 = pointts.x;
        y2 = pointts.y;
        CGPathMoveToPoint(paint_LinePath, NULL, x1, y1);
        CGPathAddLineToPoint(paint_LinePath, NULL, x2, y2);

    }
    [paint_LineLayer setPath:paint_LinePath];
    CGPathCloseSubpath(paint_LinePath);
    CGPathRelease(paint_LinePath);
    [self.layer addSublayer:paint_LineLayer];
    self.brokenLineLayer = brokenLineLayer;
    self.paint_LineLayer = paint_LineLayer;
    
}


-(void)drawData{
    
    
    if (self.verticalLineLayer) {
        [self.verticalLineLayer removeFromSuperlayer];
    }
    float currentX = (SCREEN_WIDTH*0.5f) + (currentPoint.x * scaleSpacing);
    float currentY = lineSpacing * 3- currentPoint.y * lineSpacing;
        //1.获取上下文
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextSaveGState(context);
         //2.绘制图形
//         CGContextAddEllipseInRect(context, CGRectMake(currentX, currentY, lineFactor*0.65f, lineFactor *0.65f));
    /*画圆*/
    //边框圆
    CGContextSetRGBStrokeColor(context,1.0,0.5,0,1.0 );//画笔线的颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度
    //void CGContextAddArc(CGContextRef c,CGFloat x, CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle, int clockwise)1弧度＝180°/π （≈57.3°） 度＝弧度×180°/π 360°＝360×π/180 ＝2π 弧度
    // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
     CGFloat arr[] = {100};
    CGContextSetLineDash(context, 0, arr, 0);
//    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextAddArc(context, currentX, currentY, lineFactor*0.4f, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
    
    //填充圆，无边框
    CGContextAddArc(context, currentX, currentY, lineFactor*0.2f, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill);//绘制填充
    CGContextSetRGBStrokeColor(context,1.0,0.5,0,1.0 );//画笔线的颜色
    
    CAShapeLayer *verticalLineLayer = [CAShapeLayer layer];
    CGMutablePathRef verticalLinePath =  CGPathCreateMutable();
    CGPathMoveToPoint(verticalLinePath, NULL,  currentX, currentY+lineFactor*0.4f);
    CGPathAddLineToPoint(verticalLinePath, NULL, currentX, lineSpacing*4-scaleSpacing);
    
    [verticalLineLayer setPath:verticalLinePath];
    CGPathRelease(verticalLinePath);
    [self.layer addSublayer:verticalLineLayer];
    self.verticalLineLayer = verticalLineLayer;
    
    
}


-(void)update{
    @synchronized(self)
    {
        
//        DLog(@"--------------------------------------------------------------------------")
        if (_pastPointQueue.count > 0) {
            NSMutableArray *bufferPastPointQueue = [NSMutableArray array];
            CGPoint pointt;
            for (NSValue *pointValue in _pastPointQueue) {
                pointt = [pointValue CGPointValue];
                pointt.x -= 0.1;
//                pointt.y -= 0.f;
                [bufferPastPointQueue addObject:[NSValue valueWithCGPoint:pointt]];

//                DLog(@"%.f",pointt.x);
                
            }
            if (bufferPastPointQueue.count == _pastPointQueue.count) {
                _pastPointQueue = bufferPastPointQueue;
            }
            firstPoint = [[_pastPointQueue firstObject]CGPointValue];
            if (firstPoint.x < -MAX_SCALE) {
                firstPoint = [[_pastPointQueue firstObject]CGPointValue];
                [_pastPointQueue removeObjectAtIndex:0];
                if ((_pastPointQueue.count > 0) && ([[_pastPointQueue lastObject]CGPointValue].x >= -MAX_SCALE)) {
                    CGPoint p = [[_pastPointQueue firstObject]CGPointValue];
                    while (p.x < -MAX_SCALE) {
                        firstPoint = [[_pastPointQueue firstObject]CGPointValue];
                        [_pastPointQueue removeObjectAtIndex:0];
                        p = [[_pastPointQueue firstObject]CGPointValue];
                        
                    }
                    float startY;
                    if (firstPoint.y <= p.y) {
                        startY = firstPoint.y +(p.y - firstPoint.y)*(-MAX_SCALE -firstPoint.x)/(p.x-firstPoint.x);
                        
                    }else{
                        startY = p.y + (firstPoint.y - p.y)*(p.x-(-MAX_SCALE))/(p.x - firstPoint.x);
                    }
                   [ _pastPointQueue insertObject:[NSValue valueWithCGPoint: CGPointMake(-MAX_SCALE, startY) ] atIndex:0];
                    startPoint.x = -MAX_SCALE;
                    startPoint.y = startY;
                }else if (_pastPointQueue.count > 0 && ([[_pastPointQueue lastObject]CGPointValue].x < -MAX_SCALE)){
                    [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(-MAX_SCALE,[[_pastPointQueue lastObject]CGPointValue].y)]];
                    startPoint.x = -MAX_SCALE;
                    startPoint.y = [[_pastPointQueue lastObject]CGPointValue].y;
                    
                    }
                else{
                     [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(-MAX_SCALE,firstPoint.y)]];
                    startPoint.x = -MAX_SCALE;
                    startPoint.y = firstPoint.y;
                    
                }
        }else{
            startPoint.x = firstPoint.x;
            startPoint.y = firstPoint.y;
            
            }
        }else{
                startPoint.x = 0.f;
                startPoint.y = 0.f;
            }
            float x,y;
            [_forecastPointQueue removeAllObjects];
            switch (currentState) {
                case KPHASE_REST:
                    currentPoint.x = 0.f;
                    currentPoint.y = 0.f;
                    x = slotTime - stateElapsedTime;
                    y = 0.f;
                    stateElapsedTime += 0.1f;
                    if (stateElapsedTime >= slotTime) {
                        
//                        [self setState:KPHASE_RISE :0];
                        [self setState:KPHASE_RISE StateElapsedTime:0];
                        
                    }
                    [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    while (x <= MAX_SCALE) {
                        x += riseTime;
                        y = 1.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                        x += retentionTime;
                        y = 1.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                        x += fallTime;
                        y = 0.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        x += slotTime;
                        y = 0.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                        
                    }
                    break;
                    case KPHASE_HOLD:
                    currentPoint.x = 0.f;
                    currentPoint.y = 1.f;
                    x = retentionTime - stateElapsedTime;
                    y = 1.f;
                    stateElapsedTime += 0.1f;
                    if (stateElapsedTime >= retentionTime) {
                        
                        [ self setState:KPHASE_DOWN StateElapsedTime:0];
                        
                        
                    }
                    [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    while (x <= MAX_SCALE) {
                        x += fallTime;
                        y = 0.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        x += slotTime;
                        y = 0.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        x += riseTime;
                        y = 1.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                        x += retentionTime;
                        y = 1.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    }
                    break;
                case KPHASE_RISE:
                    currentPoint.x = 0.f;
                    currentPoint.y = stateElapsedTime/riseTime;
                    x = riseTime - stateElapsedTime;
                    y = 1.f;
                    stateElapsedTime += 0.1f;
                    if (stateElapsedTime >= riseTime) {
                        

                        [self setState:KPHASE_HOLD  StateElapsedTime:0];
                    }
                    [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    while (x <= MAX_SCALE) {
                        
                        x += retentionTime;
                        y = 1.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        x += fallTime;
                        y = 0.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                        x += slotTime;
                        y = 0;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                        x += riseTime;
                        y = 1;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    }
         
                    break;
                case KPHASE_DOWN:
                    currentPoint.x = 0.f;
                    currentPoint.y = 1 - stateElapsedTime/fallTime;
                    x = fallTime - stateElapsedTime;
                    y = 0.f;
                    stateElapsedTime += 0.1f;
                    
                    if (stateElapsedTime >= fallTime) {
//                        [self setState:KPHASE_SLOT:0];
                        [self setState:KPHASE_REST StateElapsedTime:0];
                        
                    }
                    [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    while (x <= MAX_SCALE) {
                        x += slotTime;
                        y = 0.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                        x += riseTime;
                        y = 1.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                        x += retentionTime;
                        y = 1.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        x += fallTime;
                        y = 0.f;
                        [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                        
                    }
                    break;
                    
                    case KPHASE_SLOT:
                    currentPoint.x = 0.f;
                    currentPoint.y = 1.f;
                    x = MAX_SCALE;
                    y = 1.f;
                    [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    
                    break;
                    case KPHASE_WAIT:
                    currentPoint.x = 0;
                    currentPoint.y = 0;
                    x = MAX_SCALE;
                    y = 0;
                    [_forecastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    
                    break;
                    
                default:
                    break;
            }
            
            if (_forecastPointQueue.count > 0) {
                lastPoint = [[_forecastPointQueue lastObject]CGPointValue];
                if (lastPoint.x > MAX_SCALE) {
                    lastPoint = [[_forecastPointQueue lastObject]CGPointValue];
                    [_forecastPointQueue removeLastObject];
                    if (_forecastPointQueue.count >0 &&[[_forecastPointQueue firstObject]CGPointValue].x <= MAX_SCALE) {
                        CGPoint p = [[_forecastPointQueue lastObject]CGPointValue];
                        
                        while (p.x >MAX_SCALE) {
                            lastPoint = [[_forecastPointQueue lastObject]CGPointValue];
                            [_forecastPointQueue removeLastObject];
                            p = [[_forecastPointQueue lastObject]CGPointValue];
                        }
                        float endY ;
                        if (lastPoint.y <= p.y) {
                            endY = lastPoint.y+(p.y-lastPoint.y)*(lastPoint.x - MAX_SCALE)/(lastPoint.x - p.x);
                        }else{
                            endY = p.y +(lastPoint.y - p.y)*(MAX_SCALE - p.x)/(lastPoint.x - p.x);
                        }
                        endPoint.x = MAX_SCALE;
                        endPoint.y = endY;
                        
                    }else if (_forecastPointQueue.count > 0){
                        endPoint.x = MAX_SCALE;
                        endPoint.y = [[_forecastPointQueue firstObject]CGPointValue].y;
                        }
                    }else{
                        endPoint.x = MAX_SCALE;
                        endPoint.y = lastPoint.y;
                        
                    }
                }else{
                    endPoint.x = MAX_SCALE;
                    endPoint.y = 0;
                    
                }
        
        
        
        
        
        
#pragma mark - 刷新UI
        [_pointQueue removeAllObjects];
        [_pointQueue addObject:[NSValue valueWithCGPoint:startPoint]];
        if (_pastPointQueue.count > 0) {
            [_pointQueue addObjectsFromArray:_pastPointQueue];
            
        }
        if (_forecastPointQueue.count > 0) {
            [_pointQueue addObjectsFromArray:_forecastPointQueue];
            
        }
        
        [_pointQueue addObject:[NSValue valueWithCGPoint:endPoint]];
//        DLog(@"_pointQueue  v %@",_pointQueue);
//        DLog(@"_pastPointQueue  %@",_pastPointQueue);
//        DLog(@"_forecastPointQueue  %@",_forecastPointQueue);
//        DLog(@"currentPoint %f,%f",currentPoint.x,currentPoint.y);
        [self setNeedsDisplay];
    }

}


-(void)setState :(Byte)slotState StateElapsedTime:(float)slotStateElapsedTime{
    
    
//    if (stateElapsedTime != 0) return;

//    DLog(@"---------------------------------------------------------------%x,%f",slotState,slotStateElapsedTime)
    float time;
    if (currentState != slotState) {
    switch (slotState) {
        case KPHASE_REST:
            if (currentState == KPHASE_SLOT) {
                [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, 1)]];
                
            }
            [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
            time = slotTime;
            break;
            
            
            case KPHASE_HOLD:
            [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, 1)]];
            time = retentionTime;
            
            break;
            
        case KPHASE_RISE:
            [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
            time = riseTime;
            break;
        case KPHASE_DOWN:
            [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, 1)]];
            time = fallTime;
            break;
            
        case KPHASE_SLOT:
            [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, currentPoint.y)]];
            [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, 1)]];
            time = 0;
            break;
        case KPHASE_WAIT:
            [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, currentPoint.y)]];
            [_pastPointQueue addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
            time = 0;
            break;
        default:
            time = 0;
            
            break;
        }
        
        currentState = slotState;
        stateElapsedTime = slotStateElapsedTime;
        
        
        DLog(@">>>>>>>>>>MMMMMMMMMMMMMMMMMMMM")
        if (self.blocksCurrentStatus) {
            
            self.blocksCurrentStatus(currentState);
        }
#pragma MARK - 此处写来自notify的回掉函数，获取最新的currentstate 和time
    
        
    }

}

-(void)setTimeSlotRiseTime:(float)slotRiseTime slotRetentionTime:(float) slotRetentionTime slotFallTime:(float) slotFallTime slotRestTime:(float) slotRestTime{
    
    
//    DLog(@"slotRestTime %f,slotRiseTime%f,slotRetentionTime %f,slotFallTime %f",slotRestTime,slotRiseTime,slotRetentionTime,slotFallTime)
    riseTime = slotRiseTime;
    retentionTime = slotRetentionTime;
    fallTime = slotFallTime;
    slotTime = slotRestTime;
}
-(void)dealloc{
    

}
@end
