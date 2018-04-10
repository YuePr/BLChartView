
BLChartView
=========================
![](https://img.shields.io/apm/l/vim-mode.svg)
[![Build Status](https://travis-ci.org/meolu/walle-web.svg?branch=master)](https://travis-ci.org/meolu/walle-web)
[![Yii2](https://img.shields.io/badge/Powered_by-Yuepr_Framework-green.svg?style=flat)](http://www.yiiframework.com/)

A brokenline view named "brokenLineChartView" for real-time communication between iPhone and peripherals.


Quick Start
-------------
```objc
#define KPHASE_REST                       0X51
#define KPHASE_RISE                        0X82
#define KPHASE_HOLD                      0X83
#define KPHASE_DOWN                     0X24
#define KPHASE_WAIT                       0X16
#define KPHASE_SLOT                      0X25

[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerInterRuptFunction) userInfo:@{@"key":@"value"} repeats:true];
-(void)timerInterRuptFunction{
if (_lpLineChartDrawRactView != nil) {
__weak typeof(self)weakSelf = self;
_lpLineChartDrawRactView.blocksCurrentStatus = ^(Byte currentStatus){

if ((currentStatus == KPHASE_WAIT)||(self.nemsItem.outputAmpere_CHA==0)) {
[weakSelf.lpLineChartDrawRactView setState:KPHASE_WAIT StateElapsedTime:0.1];
weakSelf.ampereStatusLabel_CHA.hidden = YES;
weakSelf.ampereStatusLabel_CHA.noteStrLabel.text = [NSString stringWithFormat:@"等待时间:%.1fs",weakSelf.chartItem.houldTime];
}else{

weakSelf.ampereStatusLabel_CHA.hidden = NO;
}
if (weakSelf.ampereStatusLabel_CHA) {

weakSelf.ampereStatusLabel_CHA.noteStrLabel.text = currentStatus             ==KPHASE_REST?[NSString stringWithFormat:@"间歇时间:%.1fs",weakSelf.chartItem.restTime]:    (currentStatus == KPHASE_RISE?[NSString stringWithFormat:@"上升时间:%.1fs",weakSelf.chartItem.upTime]:(currentStatus == KPHASE_HOLD?[NSString stringWithFormat:@"保持时间:%.1fs",weakSelf.chartItem.houldTime]:(currentStatus == KPHASE_DOWN?[NSString stringWithFormat:@"下降时间:%.1fs",weakSelf.chartItem.downTime]:@"")));
}

};

}
[_lpLineChartDrawRactView update];
}
```

<!--<iframe height=716 width=402 src="https://github.com/YuePr/BLChartView/blob/master/images/003.gif">-->

![](https://github.com/YuePr/BLChartView/blob/master/images/003.gif)





