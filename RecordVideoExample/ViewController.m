//
//  ViewController.m
//  RecordVideoExample
//
//  Created by 123 on 2018/7/16.
//  Copyright © 2018年 JM. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "JMVideoCaptureHelper.h"
#import "RecordVideoTool.h"

@interface ViewController ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, strong) UIView *playerView;


@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubView];
    [self setupPlayer];
}

- (void)initSubView{
    UIView *playerView = [[UIView alloc]init];
    self.playerView = playerView;
    [self.view addSubview:playerView];
    playerView.backgroundColor = [UIColor blackColor];
    playerView.frame = CGRectMake(20, 100, self.view.frame.size.width - 40, (self.view.frame.size.width-40)*9/16);
   
    
    UIButton *playButton = [[UIButton alloc]init];
    [self.view addSubview:playButton];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    playButton.frame = CGRectMake(70, CGRectGetMaxY(playerView.frame)+30, 40, 40);
    [playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIButton *stopButton = [[UIButton alloc]init];
    [self.view addSubview:stopButton];
    stopButton.frame = CGRectMake(150, CGRectGetMaxY(playerView.frame)+30, 40, 40);
    [stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *recordButton = [[UIButton alloc]init];
    [self.view addSubview:recordButton];
    recordButton.frame = CGRectMake(playButton.frame.origin.x, CGRectGetMaxY(playButton.frame)+30, 40, 40);
    [recordButton setTitle:@"录制" forState:UIControlStateNormal];
    [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];

    
    UIButton *endRecordButton = [[UIButton alloc]init];
    [self.view addSubview:endRecordButton];
    endRecordButton.frame = CGRectMake(stopButton.frame.origin.x, CGRectGetMaxY(playButton.frame)+30, 80, 40);
    [endRecordButton setTitle:@"停止录制" forState:UIControlStateNormal];
    [endRecordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [endRecordButton addTarget:self action:@selector(endRecord) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(stopButton.frame.origin.x, CGRectGetMaxY(endRecordButton.frame)+30, 200, 200)];
    self.imageView = imageView;
    imageView.image = [UIImage imageNamed:@"binding_AP_robot"];
    [self.view addSubview:imageView];
}

- (void)setupPlayer{
    NSURL *url = [NSURL fileURLWithPath:[self videoLocalPath]];
    self.urlAsset = [AVURLAsset assetWithURL:url];
    NSArray *array = self.urlAsset.tracks;
    CGSize videoSize = CGSizeZero;
    
    for (AVAssetTrack *track in array) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
        }
    }
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player =[AVPlayer playerWithPlayerItem:self.playerItem];

    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    self.playerLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playerView.layer addSublayer:_playerLayer];
    
    self.playerLayer.frame = CGRectMake(0, 0, self.playerView.frame.size.width, self.playerView.frame.size.height);
//    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init]; playerVC.showsPlaybackControls = NO; playerVC.player = player;
    //[playerVC setVideoGravity:AVLayerVideoGravityResize]; playerVC.view.frame = CGRectMake(0, 20, ScreenWidth, ScreenWidth*9/16); [player play];
    
}

- (void)stop{
    NSLog(@"停止视频");
    self.playing = NO;
    [self.player pause];
    [self.playerItem seekToTime:kCMTimeZero];
}

- (void)play{
    self.playing = YES;
    NSLog(@"播放视频");
    [self.player play];
}

- (void)record{
    if (!self.playing) {
        NSLog(@"视频没有播放");
        return;
    }
    if ([[JMVideoCaptureHelper sharedInstances]recording]) {
        NSLog(@"正在录制中");
        return;
    }
    NSLog(@"开始录制视频");
//    [[RecordVideoTool sharedInstances]recordMustSuccess:_imageView];
//    [[RecordVideoTool sharedInstances]recordMustSuccess:self.playerView];
     [[JMVideoCaptureHelper sharedInstances]recordWithView:_playerView];
    
//    [[JMVideoCaptureHelper sharedInstances]recordWithLayer:self.playerView.layer];
    
}

- (void)endRecord{
    NSLog(@"结束录制");
//    [[RecordVideoTool sharedInstances]StopRecord];;
    [[JMVideoCaptureHelper sharedInstances] StopRecord];
    
}

- (NSString *)videoLocalPath{
    return [[NSBundle mainBundle]pathForResource:@"test" ofType:@"mp4"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
