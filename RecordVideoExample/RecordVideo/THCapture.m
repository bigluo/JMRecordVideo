//
//  THCapture.m
//  ScreenCaptureViewTest
//
//  Created by wayne li on 11-8-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "THCapture.h"
#import "CGContextCreator.h"
//#import "BlazeiceAppDelegate.h"

static NSString* const kFileName=@"output.mov";

@interface THCapture()
//配置录制环境
- (BOOL)setUpWriter;
//清理录制环境
- (void)cleanupWriter;
//完成录制工作
- (void)completeRecordingSession;
//录制每一帧
- (void)drawFrame;
@end

@implementation THCapture
@synthesize frameRate=_frameRate;
@synthesize captureLayer=_captureLayer;
@synthesize delegate=_delegate;

- (id)init
{
    self = [super init];
    if (self) {
        _frameRate=10;//默认帧率为10
        NSString *label = [NSString stringWithFormat:@"com.kishikawakatsumi.screen_recorder"];
        queue = dispatch_queue_create([label cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    
    return self;
}

- (void)dealloc {
    [self cleanupWriter];
}

#pragma mark -
#pragma mark CustomMethod

- (bool)startRecording1
{
    bool result = NO;
    if (! _recording && _captureLayer)
    {
        result = [self setUpWriter];
        if (result)
        {
            startedAt = [NSDate date];
            _spaceDate=0;
            _recording = true;
            _writing = false;
            //绘屏的定时器
            //displayLink maybe gooder than timer
            //CADisplayLink是一个能让我们以和屏幕刷新率同步的频率将特定的内容画到屏幕上的定时器类。
            //CADisplayLink使用场合相对专一，适合做UI的不停重绘，比如自定义动画引擎或者视频播放的渲染。
//            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
//            self.displayLink.frameInterval = 2;//用来设置间隔多少帧调用一次selector方法，默认值是1，即每帧都调用一次。
//            self.displayLink.frameInterval = 1.0/_frameRate;
//            //如果是普通的
//            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];//UITrackingRunLoopMode
    //        NSDate *nowDate = [NSDate date];
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0/24 target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        }
    }
    return result;
}

- (void)stopRecording
{
    dispatch_async(queue, ^
                   {
    if (_recording) {
        _recording = false;
        //[timer invalidate];
     //   [self.displayLink invalidate];
        [timer invalidate];
        timer = nil;
        [self completeRecordingSession];
        [self cleanupWriter];
    }
    });
}

- (void)drawFrame
{
    static int count = 0;
    //ITLog(@"第%d帧",count++);
    /*if ([BlazeiceAppDelegate sharedAppDelegate].isPausing) {
     _spaceDate=_spaceDate+1.0/35;
     return;
     }*/
    if (!_writing) {
        [self performSelectorInBackground:@selector(getFrame) withObject:nil];
    }
}
-(void) writeVideoFrameAtTime:(CMTime)time addImage:(CGImageRef )newImage
{
    if (![videoWriterInput isReadyForMoreMediaData]) {
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
                BOOL success = [avAdaptor appendPixelBuffer:buffer withPresentationTime:time];
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
- (void)getFrame
{
    dispatch_async(queue, ^
                   {
    if (!_writing) {
        _writing = true;
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
          
            });
             //image.CGImage;


            if (_recording) {
                float millisElapsed = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0-_spaceDate*1000.0;
                CMTime cmTime =  CMTimeMake((int)millisElapsed, 1000);
                //NSLog(@"millisElapsed = %f",millisElapsed);
                [self writeVideoFrameAtTime:cmTime addImage:image.CGImage];
                
            }
            //if (cgImage) {
           //CGImageRelease(cgImage);
            //}
          
        }
        @catch (NSException *exception) {
            
        }
        _writing = false;
    }
    });
}

- (NSString*)tempFilePath {
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kFileName];
    
    return filePath;
}
-(BOOL) setUpWriter {
    CGSize size = self.captureLayer.frame.size;
    //Clear Old TempFile
    NSError  *error = nil;
    NSString *filePath=[self tempFilePath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        if ([fileManager removeItemAtPath:filePath error:&error] == NO)
        {
            NSLog(@"Could not delete old recording file at path:  %@", filePath);
            return NO;
        }
    }
    
    //Configure videoWriter
    NSURL   *fileUrl=[NSURL fileURLWithPath:filePath];
    videoWriter = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);
    
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
    
    videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSParameterAssert(videoWriterInput);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
    
    //add input
    [videoWriter addInput:videoWriterInput];
    [videoWriter startWriting];
    //CMTimeMake(a,b)    a当前第几帧, b每秒钟多少帧.当前播放时间a/b
    [videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
    
//UIGraphicsBeginImageContextWithOptions(self.captureView.bounds.size,YES,0);
    //create context
//    if (context== NULL)
//    {
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        context = CGBitmapContextCreate (NULL,
//                                         size.width,
//                                         size.height,
//                                         8,//bits per component
//                                         size.width * 4,
//                                         colorSpace,
//                                         kCGImageAlphaNoneSkipFirst);
//        CGColorSpaceRelease(colorSpace);
//        CGContextSetAllowsAntialiasing(context,NO);
//        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0,-1, 0, size.height);
//        CGContextConcatCTM(context, flipVertical);
//    }
//    if (context== NULL)
//    {
//        fprintf (stderr, "Context not created!");
//        return NO;
//    }
    
    return YES;
}

- (void) cleanupWriter {
    
    avAdaptor = nil;
    
    videoWriterInput = nil;
    
    videoWriter = nil;
    
    startedAt = nil;
    
    
    //CGContextRelease(context);
    //context=NULL;
}

- (void) completeRecordingSession {
    
    //UIGraphicsEndImageContext();
    [videoWriterInput markAsFinished];
    
    // Wait for the video
    int status = videoWriter.status;
    while (status == AVAssetWriterStatusUnknown)
    {
        NSLog(@"Waiting...");
        [NSThread sleepForTimeInterval:0.5f];
        status = videoWriter.status;
    }
    
    BOOL success = [videoWriter finishWriting];
    if (!success)
    {
        NSLog(@"finishWriting returned NO");
        if ([_delegate respondsToSelector:@selector(recordingFaild:)]) {
            [_delegate recordingFaild:nil];
        }
        return ;
    }
    
    NSLog(@"Completed recording, file is stored at:  %@", [self tempFilePath]);
    if ([_delegate respondsToSelector:@selector(recordingFinished:)]) {
        [_delegate recordingFinished:[self tempFilePath]];
    }
}



@end
