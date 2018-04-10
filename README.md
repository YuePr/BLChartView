



![](https://img.shields.io/apm/l/vim-mode.svg)

BLChartView
=========================
[![Build Status](https://travis-ci.org/meolu/walle-web.svg?branch=master)](https://travis-ci.org/meolu/walle-web)
[![Packagist](https://img.shields.io/packagist/v/meolu/walle-web.svg)](https://packagist.org/packages/meolu/walle-web)
[![Yii2](https://img.shields.io/badge/Powered_by-Yii_Framework-green.svg?style=flat)](http://www.yiiframework.com/)

A brokenline view named "brokenLineChartView" for real-time communication between iPhone and peripherals.



Quick Start
-------------

```OC
if (self.lpLineChartDrawRactView != nil) {
__weak typeof(self)weakSelf = self;
self.lpLineChartDrawRactView.blocksCurrentStatus = ^(Byte currentStatus){


if ((currentStatus == KPHASE_WAIT)||(self.nemsItem.outputAmpere_CHA==0)) {
[weakSelf.lpLineChartDrawRactView setState:KPHASE_WAIT StateElapsedTime:0.1];
weakSelf.ampereStatusLabel_CHA.hidden = YES;
weakSelf.ampereStatusLabel_CHA.noteStrLabel.text = [NSString stringWithFormat:@"等待时间:%.1fs",weakSelf.chartItem.houldTime];
}else{

weakSelf.ampereStatusLabel_CHA.hidden = NO;
}
if (weakSelf.ampereStatusLabel_CHA) {

weakSelf.ampereStatusLabel_CHA.noteStrLabel.text = currentStatus ==KPHASE_REST?[NSString stringWithFormat:@"间歇时间:%.1fs",weakSelf.chartItem.restTime]:(currentStatus == KPHASE_RISE?[NSString stringWithFormat:@"上升时间:%.1fs",weakSelf.chartItem.upTime]:(currentStatus == KPHASE_HOLD?[NSString stringWithFormat:@"保持时间:%.1fs",weakSelf.chartItem.houldTime]:(currentStatus == KPHASE_DOWN?[NSString stringWithFormat:@"下降时间:%.1fs",weakSelf.chartItem.downTime]:@"")));
}

};

}
[self.lpLineChartDrawRactView update];
```



