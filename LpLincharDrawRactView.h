//
//  LpLincharDrawRactView.h
//  BLChartView
//
//  Created by YuePr.Guangz on 2016/11/28.
//  Copyright © 2016年 YuePr.Guangz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LpLincharDrawRactView : UIView

typedef void(^blockLpChartCurrentStatus)(Byte currentStatus);

-(instancetype)init;
-(void)drawRect:(CGRect)rect;
-(void)setTimeSlotRiseTime:(float)slotRiseTime slotRetentionTime:(float) slotRetentionTime slotFallTime:(float) slotFallTime slotRestTime:(float) slotRestTime;
-(void)setState :(Byte)slotState StateElapsedTime:(float)slotStateElapsedTime;
-(void)update;


@property(nonatomic,copy)blockLpChartCurrentStatus blocksCurrentStatus;


@end
 
