//
//  JMVideoCaptureUtility.h
//  RecordVideoExample
//
//  Created by 123 on 2018/7/17.
//  Copyright © 2018年 JM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completeBlock)(NSError *error);

@interface JMVideoCaptureUtility : NSObject
+ (NSString *)getTempVideoCaptureFilePath;
+ (NSString *)getTempAudioCaptureFilePath;
+ (NSString *)getOutputCaptureFilePath;
+ (void)removeAudioAndVideoTempFile;

/** 音频与视频的合并 */
+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath complete:(completeBlock)complete;

@end
