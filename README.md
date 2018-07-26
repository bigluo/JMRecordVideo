# JMRecordVideo
## 简介
因为几年前公司的项目经常用到视频通话功能，尝试了不少的小厂大厂的视频SDK。
在遇到一些新的SDK尚没有录制视频功能时，项目却定义了这个功能时，就通过一个取巧的方法来录制视频，现在把它放上来。

## 原理
通过捕捉视频图像,来生成录制视频。

## 主要类介绍
* JMAudioRecorder： 负责录音功能
* JMVideoCapture：  负责录制视频功能 
* JMVideoCaptureUtility： 封装常用方法
* JMVideoCaptureHelper：  封装工具类

## 内部调用
* AVAssetWriter：负责把媒体数据写到一个新文件里
* AVAssetWriterInput: 负责把打包并输出文件提供给AVAssertWriter
* AVAssetWriterInputPixelBufferAdaptor：负责添加CVPixelBuffer进AVAssetWriterInput
* AVAudioRecorder： 音频录制类
* AVMutableComposition: 音频和视频合成类

## 使用


#### 开始录制
```
- (void)recordWithView:(UIView *)recordView;
```

#### 结束录制
```
- (void)StopRecord;
```

#### 撤销录制
```
- (void)cancelRecord;
```
