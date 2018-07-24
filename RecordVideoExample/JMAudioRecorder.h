//
//  JMAudioRecorder.h
//  RecordVideoExample
//
//  Created by 123 on 2018/7/17.
//  Copyright © 2018年 JM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@protocol JMAudioRecorderDelegate <NSObject>
-(void)wavComplete;
@end

@interface JMAudioRecorder : NSObject
@property (nonatomic, weak)     id<JMAudioRecorderDelegate> delegate;
@property (nonatomic, strong)   AVAudioRecorder     *recorder;
@property (nonatomic, strong)   NSString            *recordFilePath;
@property (nonatomic, assign)   BOOL nowPause;

- (void)beginRecordByFileName:(NSString*)_fileName;
- (void)endRecord;
@end
