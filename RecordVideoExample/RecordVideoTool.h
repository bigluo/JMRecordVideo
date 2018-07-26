//
//  RecordVideoTool.h
//  KidRobot
//
//  Created by Mac on 16/6/14.
//  Copyright © 2016年 QBB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THCapture.h"
#import "BlazeiceAudioRecordAndTransCoding.h"

/**
 *  视屏通话录制视频
 */
@interface RecordVideoTool : NSObject<THCaptureDelegate,AVAudioRecorderDelegate,BlazeiceAudioRecordAndTransCodingDelegate>
#define VEDIOPATH @"vedioPath"
{
    THCapture *capture;
    BlazeiceAudioRecordAndTransCoding*audioRecord;
    NSString* opPath;
}
@property (nonatomic,assign) BOOL isRecording;//是否正在录制
+ (instancetype)sharedInstances;
- (void)recordMustSuccess:(UIView *)recordView;
- (void)StopRecord;
@end
