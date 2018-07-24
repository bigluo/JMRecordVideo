//
//  JMVideoCapture.m
//  RecordVideoExample
//
//  Created by 123 on 2018/7/17.
//  Copyright © 2018年 JM. All rights reserved.
//

#import "JMVideoCapture.h"
#import <AVFoundation/AVFoundation.h>
#import "JMVideoCaptureUtility.h"

@interface JMVideoCapture()
/**
 * AVAssetWriter provides services for writing media data to a new file
 * AVAssetWriter这个类可以方便的将图像和音频写成一个完整的视频文件。甚至将整个应用的操作录制下来
 */
@property(nonatomic, strong) AVAssetWriter *videoWriter;

@property(nonatomic, strong) AVAssetWriterInput *videoWriterInput;

@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *avAdaptor;

/**
 * 录制队列
 */
@property(strong, nonatomic) dispatch_queue_t captureQueue;

/**
 * 需要捕捉的视图
 */
@property(nonatomic, strong) UIView *captureView;

/**
 * 需要捕捉的图层
 */
//@property(nonatomic, strong) CALayer *captureLayer;

/**
 * 录制定时器
 */
@property(strong, nonatomic) CADisplayLink *displayLink;

@property(strong, nonatomic) NSDate *startedAt;

@property(nonatomic,  assign) float spaceDate;

@end
@implementation JMVideoCapture

- (id)init
{
    self = [super init];
    if (self) {
//        self.frameRate = 24;默认帧率
        self.captureQueue = dispatch_queue_create([@"com.bigluo.screen_recorder" cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    
    return self;
}

- (bool)beginRecordWithView:(UIView *)recordView
{
    bool result = NO;
    if (recordView)
    {
        self.captureView = recordView;
        [self setUpWriter];
        self.startedAt = [NSDate date];
        self.spaceDate=0;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
            //            self.displayLink.frameInterval = 2;//用来设置间隔多少帧调用一次selector方法，默认值是1，即每帧都调用一次。
            if (_frameRate != 0) {
                //preferredFramesPerSecond
                 self.displayLink.frameInterval = 1.0/_frameRate;
            }
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        }
    return result;
}

- (void)endRecord
{
    dispatch_async(_captureQueue, ^
                   {
                       [self.displayLink invalidate];
                       self.displayLink = nil;
                       [self completeRecordingSession];
                       [self cleanupWriter];
                   });
}

- (void)drawFrame
{
    static int count = 0;
    dispatch_async(self.captureQueue, ^
                   {
                       //if (!_writing) {
                       //    _writing = true;
                       @try {
                           __block UIImage *image = nil;
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               //CGImageRef cgImage = nil;
                               //截出来的是原图（YES 0.0 质量高）
                           UIGraphicsBeginImageContextWithOptions(self.captureView.bounds.size,YES,0);

                           //之前YES unActive状态屏幕会闪
                           [self.captureView drawViewHierarchyInRect:self.captureView.bounds afterScreenUpdates:NO];

                           image = UIGraphicsGetImageFromCurrentImageContext();
                           //CGImageRef cgImage = CGImageCreateCopy(image.CGImage);

                           UIGraphicsEndImageContext();
                           
//                           UIGraphicsBeginImageContextWithOptions(self.captureLayer.frame.size, NO, [UIScreen mainScreen].scale);
// UIGraphicsBeginImageContextWithOptions(self.captureLayer.frame.size, NO, 0);
//
//                               [self.captureLayer renderInContext:UIGraphicsGetCurrentContext()];
//                               image = UIGraphicsGetImageFromCurrentImageContext();
//                               UIGraphicsEndImageContext();
                               
                           });
                               float millisElapsed = [[NSDate date] timeIntervalSinceDate:_startedAt] * 1000.0-_spaceDate*1000.0;
                               CMTime cmTime =  CMTimeMake((int)millisElapsed, 1000);
                               //NSLog(@"millisElapsed = %f",millisElapsed);
                               [self writeVideoFrameAtTime:cmTime addImage:image.CGImage];
                           //if (cgImage) {
                           //CGImageRelease(cgImage);
                           //}
                           
                       }
                       @catch (NSException *exception) {
                           
                       }
                       //    _writing = false;
                   }
                   // }
                   );
}
-(void) writeVideoFrameAtTime:(CMTime)time addImage:(CGImageRef )newImage
{
    if (![self.videoWriterInput isReadyForMoreMediaData]) {
        NSLog(@"Not ready for video data");
    }
    else {
        @synchronized (self) {
            //CGImageRef是定义在QuartzCore框架中的一个结构体指针
            //CGImageRef 和 struct CGImage * 是完全等价的。这个结构用来创建像素位图，可以通过操作存储的像素位来编辑图片。
            CGImageRef cgImage = CGImageCreateCopy(newImage);
            
            
            CVReturn status = kCVReturnSuccess;
            CVPixelBufferRef buffer = NULL;
            CFTypeRef backingData;
            CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
            CFDataRef data = CGDataProviderCopyData(dataProvider);
            
            //CFRelease(dataProvider);//不先执行这个就不会crash?
            
            backingData = CFDataCreateMutableCopy(kCFAllocatorDefault, CFDataGetLength(data), data);
            CFRelease(data);
            // CVPixelBufferLockBaseAddress( buffer, 0 );
            const UInt8 *bytePtr = CFDataGetBytePtr(backingData);
            
            status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                                  CGImageGetWidth(cgImage),
                                                  CGImageGetHeight(cgImage),
                                                  kCVPixelFormatType_32BGRA,
                                                  (void *)bytePtr,
                                                  CGImageGetBytesPerRow(cgImage),
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  &buffer);
            if(buffer){
                BOOL success = [self.avAdaptor appendPixelBuffer:buffer withPresentationTime:time];
                if (!success)
                    NSLog(@"Warning:  Unable to write buffer to video");
                //[self stopRecording];
                //  CVPixelBufferUnlockBaseAddress( buffer, 0 );
                CVPixelBufferRelease( buffer );
            }
            //也就是 在arc模式下 不是什么东西 都可以释放
            //例如 C-types的对象 都需要手动来进行释放
            //clean up
            
            //CFRelease(image);
            //CFRelease(provider);
            CFRelease(backingData);
            CGImageRelease(cgImage);
            //CGDataProviderRelease(dataProvider);
            //CFRelease(dataProvider);不释放不报错？但应该会内存泄露
        }
    }
}


- (void)setUpWriter {
    CGSize size = self.captureView.frame.size;
    //Clear Old TempFile
    NSError  *error = nil;
    NSString *filePath = [JMVideoCaptureUtility getTempVideoCaptureFilePath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        if ([fileManager removeItemAtPath:filePath error:&error] == NO)
        {
            NSLog(@"Could not delete old recording file at path:  %@", filePath);
        }
    }
    
    //Configure videoWriter
    NSURL   *fileUrl=[NSURL fileURLWithPath:filePath];
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(_videoWriter);
    
    //Configure videoWriterInput
    NSDictionary* videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithDouble:size.width*size.height], AVVideoAverageBitRateKey,
                                           nil ];
    
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   videoCompressionProps, AVVideoCompressionPropertiesKey,
                                   nil];
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSParameterAssert(_videoWriterInput);
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    self.avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
    
    //add input
    [self.videoWriter addInput:_videoWriterInput];
    [self.videoWriter startWriting];
    //CMTimeMake(a,b)    a当前第几帧, b每秒钟多少帧.当前播放时间a/b
    [self.videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
}


- (void) completeRecordingSession {
    
    //UIGraphicsEndImageContext();
    [self.videoWriterInput markAsFinished];
    
    // Wait for the video
    int status = self.videoWriter.status;
    while (status == AVAssetWriterStatusUnknown)
    {
        NSLog(@"Waiting...");
        [NSThread sleepForTimeInterval:0.5f];
        status = self.videoWriter.status;
    }
    
    [self.videoWriter finishWritingWithCompletionHandler:^{
        if ([_delegate respondsToSelector:@selector(recordingFinished:)]) {
            [_delegate recordingFinished:[JMVideoCaptureUtility getTempVideoCaptureFilePath]];
        }
    }];
}

- (void)cleanupWriter {
    
    self.avAdaptor = nil;
    
    self.videoWriterInput = nil;
    
    self.videoWriter = nil;
    
    self.startedAt = nil;
    
}

@end
