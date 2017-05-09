//
//  ViewController.m
//  QRCodeReader
//
//  Created by 吴珂 on 15/1/23.
//  Copyright (c) 2015年 吴珂. All rights reserved.
//  二维码扫描  bengkui

/*
 步骤如下：
 1.导入AVFoundation框架，引入<AVFoundation/AVFoundation.h>
 2.设置一个用于显示扫描的view
 3.实例化AVCaptureSession、AVCaptureVideoPreviewLayer
 */

#import "ScanQRViewController.h"
#import "HttpCapture-swift.h"
#import <AVFoundation/AVFoundation.h>
#import "SidebarMenuViewController.h"

#define IS_VAILABLE_IOS8  ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)

@interface ScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    int line_tag;
}

@property (strong, nonatomic)  UILabel *lblStatus;
- (void)startStopReading:(BOOL)bOpen;

@property (strong, nonatomic) UIView *boxView;
@property (strong, nonatomic) CALayer *scanLayer;

-(BOOL)startReading;
-(void)stopReading;

//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation ScanQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    line_tag = 1872637;
    _captureSession = nil;
    [self configSession];
    [self setOverlayPickerView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startStopReading:true];
}

- (BOOL)canOpenSystemSettingView {
    if (IS_VAILABLE_IOS8) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

- (void)systemSettingView {
    if (IS_VAILABLE_IOS8) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)configSession{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusDenied){
        if (IS_VAILABLE_IOS8) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机权限受限" message:@"请在iPhone的\"设置->隐私->相机\"选项中,允许\"自游邦\"访问您的相机." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self canOpenSystemSettingView]) {
                    [self systemSettingView];
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        return ;
    }
    
    NSError *error;
    
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return ;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:captureMetadataOutput];
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    NSMutableArray *a = [[NSMutableArray alloc] init];
    if ([captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        [a addObject:AVMetadataObjectTypeQRCode];
    }
//    if ([captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
//        [a addObject:AVMetadataObjectTypeEAN13Code];
//    }
//    if ([captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
//        [a addObject:AVMetadataObjectTypeEAN8Code];
//    }
//    if ([captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
//        [a addObject:AVMetadataObjectTypeCode128Code];
//    }
    captureMetadataOutput.metadataObjectTypes=a;
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:self.view.bounds];
    
    //9.将图层添加到预览view的图层上
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    //10.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    [_captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
}

- (BOOL)startReading {
    //10.开始扫描
    if ([_captureSession isRunning])
    {
        return true;
    }
    [_captureSession startRunning];
    return true;
}

- (void)toggle:(ToggleState)state
{
    if (state == ToggleOpen)
    {
        
    }
    else if (state == ToggleClose)
    {
        [self startStopReading:false];
    }
}

- (void)addAnimation{
    UIView *line = [self.view viewWithTag:line_tag];
    line.hidden = NO;
    CABasicAnimation *animation = [ScanQRViewController moveYTime:2 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:self.view.frame.size.width-60-2] rep:OPEN_MAX];
    [line.layer addAnimation:animation forKey:@"LineAnimation"];
}

- (void)removeAnimation{
    UIView *line = [self.view viewWithTag:line_tag];
    [line.layer removeAnimationForKey:@"LineAnimation"];
    line.hidden = YES;
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
{
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.delegate = self;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}

- (void)setOverlayPickerView
{
    //左侧的view
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, self.view.frame.size.height)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    //右侧的view
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-30, 0, 30, self.view.frame.size.height)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //最上部view
    UIImageView* upView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, self.view.frame.size.width-60, (self.view.center.y-(self.view.frame.size.width-60)/2))];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //底部view
    UIImageView * downView = [[UIImageView alloc] initWithFrame:CGRectMake(30, (self.view.center.y+(self.view.frame.size.width-60)/2), (self.view.frame.size.width-60), (self.view.frame.size.height-(self.view.center.y-(self.view.frame.size.width-60)/2)))];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(upView.frame), self.view.frame.size.width-60, 2)];
    line.tag = line_tag;
    line.image = [UIImage imageNamed:@"扫描线"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    [self.view addSubview:line];
    
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMinY(downView.frame), self.view.frame.size.width-60, 60)];
    msg.backgroundColor = [UIColor clearColor];
    msg.textColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.font = [UIFont systemFontOfSize:16];
    msg.text = @"将二维码放入框内,即可自动扫描";
    [self.view addSubview:msg];
}

- (IBAction)startStopReading:(BOOL)bStart {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (bStart) {
            if ([self startReading]) {
                [_lblStatus setText:@"Scanning for QR Code"];
            }
        }
        else{
            [self stopReading];
            [self removeAnimation];
        }
    });
}

-(void)stopReading{
    if ([_captureSession isRunning])
    {
        [_captureSession stopRunning];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(openUrl:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        }
    }
}

-(void)openUrl:(NSString *)urlstr
{
    [self stopReading];
    [self.delegate setToolbarURL:urlstr];
    NSIndexPath * indexpath = [self.delegate getSearchWebControllerIndexPath];
    NSIndexPath * indexpath2 = [self.delegate getMenuItemIndexPath:self];
    [self.delegate selectIndexPath:indexpath2 animationFinishBlock:^(BOOL finish) {
        [self.delegate selectIndexPath:indexpath animationFinishBlock:nil];
    }];
}


- (BOOL)shouldAutorotate
{
    return NO;
}


@end
