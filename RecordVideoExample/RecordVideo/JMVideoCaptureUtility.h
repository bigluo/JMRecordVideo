//
//  JMVideoCaptureUtility.h
//  RecordVideoExample
//
//  Created by 123 on 2018/7/17.
//  Copyright © 2018年 JM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMVideoCaptureUtility : NSObject
+ (NSString *)getTempVideoCaptureFilePath;
+ (NSString *)getTempAudioCaptureFilePath;
// 音频与视频的合并. action的形式如下:
// - (void)mergedidFinish:(NSString *)videoPath WithError:(NSError *)error;
+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath andTarget:(id)target andAction:(SEL)action;

@end
