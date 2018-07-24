//
//  JMVideoCaptureUtility.m
//  RecordVideoExample
//
//  Created by 123 on 2018/7/17.
//  Copyright © 2018年 JM. All rights reserved.
//

#import "JMVideoCaptureUtility.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@implementation JMVideoCaptureUtility

static NSString* const kVideoFileName = @"outputVideo.mov";
static NSString* const kAudioFileName = @"outputAudio.wav";

+ (NSString *)getTempVideoCaptureFilePath{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kVideoFileName];
    
    return filePath;
}

+ (NSString *)getTempAudioCaptureFilePath{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kAudioFileName];
    return filePath;
}

+ (void)removeAudioAndVideoTempFile{
    NSString *videoFilePath = [JMVideoCaptureUtility getTempVideoCaptureFilePath];
    NSString *audioFilePath = [JMVideoCaptureUtility getTempAudioCaptureFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:videoFilePath]){
        [fileManager removeItemAtPath:videoFilePath error:nil];
    }
    if ([fileManager fileExistsAtPath:audioFilePath]){
        [fileManager removeItemAtPath:audioFilePath error:nil];
    }
}

+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath complete:(completeBlock)complete
{
    NSError *error;

    NSURL *audioUrl=[NSURL fileURLWithPath:audioPath];
    NSURL *videoUrl=[NSURL fileURLWithPath:videoPath];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    
    //混合音乐
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:kCMTimeZero error:&error];
    if (error) {
        complete(error);
        return;
    }
    
    //混合视频
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:&error];
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetPassthrough];
    if (error) {
        complete(error);
        return;
    }
    //保存混合后的文件的过程
    NSString* videoName = @"export2.mov";
    NSString *exportPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:videoName];
    NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    NSLog(@"file type %@",_assetExport.outputFileType);
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void )
     {
         NSLog(@"完成了");
         complete(nil);
     }];
}
@end
