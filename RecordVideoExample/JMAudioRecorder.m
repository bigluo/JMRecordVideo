//
//  JMAudioRecorder.m
//  RecordVideoExample
//
//  Created by 123 on 2018/7/17.
//  Copyright © 2018年 JM. All rights reserved.
//

#import "JMAudioRecorder.h"

@implementation JMAudioRecorder
#pragma mark - 开始录音
- (void)beginRecordByFileName:(NSString*)_fileName;{
    self.recordFilePath = _fileName;
    //初始化录音
    AVAudioRecorder *temp = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:[_recordFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                                       settings:[self getAudioRecorderSettingDict]
                                                          error:nil];
    self.recorder = temp;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.recorder record];
}

-(void)startRecord{
    [self.recorder record];
    _nowPause=NO;
}

-(void)pauseRecord{
    if (self.recorder.isRecording) {
        [self.recorder pause];
        _nowPause=YES;
    }
}

- (void)endRecord{
    if (self.recorder.isRecording||(!self.recorder.isRecording&&_nowPause)) {
        [self.recorder stop];
        self.recorder = nil;
        [self.delegate wavComplete];
    }
}

- (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   nil];
    return recordSetting;
}
@end
