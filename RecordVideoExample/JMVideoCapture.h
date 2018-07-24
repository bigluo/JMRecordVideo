//
//  JMVideoCapture.h
//  RecordVideoExample
//
//  Created by 123 on 2018/7/17.
//  Copyright © 2018年 JM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol JMVideoCaptureDelegate <NSObject>

- (void)recordingFinished:(NSString*)outputPath;
- (void)recordingFaild:(NSError *)error;

@end

@interface JMVideoCapture : NSObject
/**
 * 帧率
 */
@property(nonatomic, assign) NSUInteger frameRate;
@property(nonatomic, weak) id<JMVideoCaptureDelegate> delegate;
- (bool)beginRecordWithView:(UIView *)recordView;
- (void)endRecord;
@end
