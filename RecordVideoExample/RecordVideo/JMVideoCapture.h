//
//  JMVideoCapture.h
//  RecordVideoExample
//
//  Created by 123 on 2018/7/17.
//  Copyright © 2018年 JM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface JMVideoCapture : NSObject
/**
 * 帧率
 */
@property(nonatomic, assign) NSUInteger frameRate;

- (bool)startRecordingWithCaptureView:(UIView *)captureView;
- (void)endRecording;
@end
