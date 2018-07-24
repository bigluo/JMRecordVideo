//
//  JMVideoCaptureHelper.h
//  RecordVideoExample
//
//  Created by 123 on 2018/7/21.
//  Copyright © 2018年 JM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * JMVideoCapture工具类
 */
@interface JMVideoCaptureHelper : NSObject
@property (nonatomic, assign) BOOL recording;
+ (instancetype)sharedInstances;

/**
 * 开始录制
 *
 * recordView: 需要录制的View
 */
- (void)recordWithView:(UIView *)recordView;

/**
 * 结束录制
 */
- (void)StopRecord;

/**
 * 撤销录制
 */
- (void)cancelRecord;
@end
