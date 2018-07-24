//
//  JMVideoCaptureHelper.m
//  RecordVideoExample
//
//  Created by 123 on 2018/7/21.
//  Copyright © 2018年 JM. All rights reserved.
//

#import "JMVideoCaptureHelper.h"
#import "JMVideoCapture.h"
#import "JMAudioRecorder.h"
#import "JMVideoCaptureUtility.h"

#define VEDIOPATH @"vedioPath"

@interface JMVideoCaptureHelper()<JMVideoCaptureDelegate,JMAudioRecorderDelegate>

@property (nonatomic, strong) JMVideoCapture *capture;

@property (nonatomic, strong) JMAudioRecorder *audioRecorder;

@property (nonatomic, strong) NSString *finalPath;
@end

@implementation JMVideoCaptureHelper
+ (instancetype)sharedInstances{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)recordWithView:(UIView *)recordView{
    NSLog(@"开始录制===========================");
    self.recording = YES;
    if(self.capture == nil){
        self.capture=[[JMVideoCapture alloc] init];
    }
    self.capture.frameRate = 35;
    self.capture.delegate = self;
    
    if (!_audioRecorder) {
        self.audioRecorder = [[JMAudioRecorder alloc]init];
        self.audioRecorder.delegate=self;
    }
    
    [self.capture beginRecordWithView:recordView];
    [self performSelector:@selector(toStartAudioRecord) withObject:nil afterDelay:0.1];
}

#pragma mark audioRecordDelegate
/**
 *  开始录音
 */
-(void)toStartAudioRecord
{
    [self.audioRecorder beginRecordByFileName:[JMVideoCaptureUtility getTempAudioCaptureFilePath]];
}
/**
 *  音频录制结束合成视频音频
 */
-(void)wavComplete
{
    //视频录制结束,为视频加上音乐
    if (self.audioRecorder) {
       // NSString* path=[self getPathByFileName:VEDIOPATH ofType:@"wav"];
        NSString *audioPath = [JMVideoCaptureUtility getTempAudioCaptureFilePath];
        NSString *videoPath = [JMVideoCaptureUtility getTempVideoCaptureFilePath];
        [JMVideoCaptureUtility mergeVideo:videoPath andAudio:audioPath complete:^(NSError *error) {
            if (error) {
                NSLog(@"%@",error);
                return ;
            }
            [self mergedidFinish];
        }];
    }
}

#pragma mark THCaptureDelegate
- (void)recordingFinished:(NSString*)outputPath
{
    NSLog(@"结束录制===========================");
    _finalPath=outputPath;
    if (self.audioRecorder) {
        [self.audioRecorder endRecord];
    }
    self.recording = NO;
}

- (void)recordingFaild:(NSError *)error
{
    if (self.audioRecorder) {
        [self.audioRecorder endRecord];
    }
    self.recording = NO;
}

- (void)video: (NSString *)videoPath didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInfo{
    if (error) {
        NSLog(@"---%@",[error localizedDescription]);
    }
}

- (void)mergedidFinish
{
    NSDateFormatter* dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSString* currentDateStr=[dateFormatter stringFromDate:[NSDate date]];
    
    NSString* fileName=[NSString stringWithFormat:@"白板录制,%@.mov",currentDateStr];
    
    NSString* path=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
//    {
//        NSError *err=nil;
//        [[NSFileManager defaultManager] moveItemAtPath:videoPath toPath:path error:&err];
//    }
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"allVideoInfo"]) {
//        NSMutableArray* allFileArr=[[NSMutableArray alloc] init];
//        [allFileArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"allVideoInfo"]];
//        [allFileArr insertObject:fileName atIndex:0];
//        [[NSUserDefaults standardUserDefaults] setObject:allFileArr forKey:@"allVideoInfo"];
//    }
//    else{
//        NSMutableArray* allFileArr=[[NSMutableArray alloc] init];
//        [allFileArr addObject:fileName];
//        [[NSUserDefaults standardUserDefaults] setObject:allFileArr forKey:@"allVideoInfo"];
//    }
    
    //音频与视频合并结束，存入相册中
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}


- (void)StopRecord{
    NSLog(@"准备停止录制");
    self.recording = NO;
    [self.capture endRecord];
}

- (void)cancelRecord{
    NSLog(@"撤销录制");
    self.recording = NO;
    [self.capture endRecord];
}

- (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}
@end
