//
//  SLQCameraViewController.m
//
//
//  Created by MrSong on 16-5-18.
//  Copyright (c) 2016年 MrSong. All rights reserved.
//
#import "SLQCameraViewController.h"
#import "SLQCameraHelper.h"

#define BOX_BOUNDS CGRectMake(0.0f, 0.0f, 150, 150.0f)

@interface SLQCameraViewController ()

/**闪光灯模式*/
@property (nonatomic, assign) ISTCameraFlashMode currentFlashMode;
/**预览视图*/
@property (nonatomic, strong) UIView *previewView;
/// 对焦边框
@property (strong, nonatomic) UIView *focusBox;
/**闪光灯按钮*/
@property (nonatomic, strong) UIButton *flashBtn;
/**返回按钮*/
@property (nonatomic, strong) UIButton *backBtn;
/**切换摄像头*/
@property (nonatomic, strong) UIButton *toggleCameraBtn;
/**拍照按钮*/
@property (nonatomic, strong) UIButton *takePhotoBtn;

/**图片预览*/
@property (nonatomic, strong) UIImageView *photoImageView;
/**使用照片*/
@property (nonatomic, strong) UIButton *useBtn;
/**重拍*/
@property (nonatomic, strong) UIButton *againBtn;
/**缩小按钮*/
@property (nonatomic, strong) UIButton *smallerBtn;
/**放大按钮*/
@property (nonatomic, strong) UIButton *biggerBtn;
/**缩放条*/
@property (nonatomic, strong) UISlider *slider;
/**captureImage*/
@property (nonatomic, strong) UIImage *captureImage;
/// 对焦手势
@property (strong, nonatomic) UITapGestureRecognizer *singleTapRecognizer;
@end

@implementation SLQCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //创建视图
    _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _previewView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_previewView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(10, ScreenHeight - 100, 100, 60);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToMainVc:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    _backBtn = backBtn;
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    takePhotoBtn.frame = CGRectMake(ScreenWidth/2 - 50, ScreenHeight - 100, 100, 100);
    [takePhotoBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoBtn];
    _takePhotoBtn = takePhotoBtn;
    
    UIButton *toggleCameraBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    toggleCameraBtn.frame = CGRectMake(ScreenWidth - 100, 20, 100, 60);
    [toggleCameraBtn setTitle:@"前后" forState:UIControlStateNormal];
    [toggleCameraBtn addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toggleCameraBtn];
    _toggleCameraBtn = toggleCameraBtn;
    
    
    UIButton *biggerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    biggerBtn.frame = CGRectMake(ScreenWidth - 100, ScreenHeight/2 - 150, 100, 60);
    [biggerBtn setTitle:@"放大" forState:UIControlStateNormal];
    //    [biggerBtn addTarget:self action:@selector(biggerCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:biggerBtn];
    _biggerBtn = biggerBtn;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(ScreenWidth - 150, ScreenHeight/2 - 50, 200, 150)];
    slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [slider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchDragExit | UIControlEventTouchDragOutside | UIControlEventTouchCancel] ;
    _slider = slider;
    
    UIButton *smallerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    smallerBtn.frame = CGRectMake(ScreenWidth - 100,  ScreenHeight/2 + 150, 100, 60);
    [smallerBtn setTitle:@"缩小" forState:UIControlStateNormal];
    //    [smallerBtn addTarget:self action:@selector(smallerCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:smallerBtn];
    _smallerBtn = smallerBtn;
    
    
    _flashBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _flashBtn.frame = CGRectMake(10, 20, 100, 60);
    [_flashBtn addTarget:self action:@selector(changeFlashMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashBtn];
    
    _photoImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_photoImageView];
    _photoImageView.hidden = YES;
    
    UIButton *againBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    againBtn.frame = CGRectMake(10, ScreenHeight - 100, 80, 50);
    [againBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [againBtn addTarget:self action:@selector(backToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:againBtn];
    againBtn.hidden = YES;
    _againBtn = againBtn;
    
    UIButton *useBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    useBtn.frame = CGRectMake(ScreenWidth - 100-10, ScreenHeight - 100, 100, 50);
    [useBtn setTitle:@"使用照片" forState:UIControlStateNormal];
    [useBtn addTarget:self action:@selector(useBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:useBtn];
    useBtn.hidden = YES;
    _useBtn = useBtn;
    
    _focusBox = [self viewWithColor:[UIColor colorWithRed:0.102 green:0.636 blue:1.000 alpha:1.000]];
    [self.view addSubview:_focusBox];
    
    _singleTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:_singleTapRecognizer];
    
    //判断支持类别
    if ([SLQCameraHelper isBackCameraFlashSupportAutoMode]) {
        [_flashBtn setTitle:@"自动" forState:UIControlStateNormal];
        _currentFlashMode = ISTCameraFlashModeAuto;
    }else if ([SLQCameraHelper isBackCameraFlashSupportOnMode]){
        [_flashBtn setTitle:@"打开" forState:UIControlStateNormal];
        _currentFlashMode = ISTCameraFlashModeOn;
    }else if ([SLQCameraHelper isBackCameraFlashSupportOffMode]){
        [_flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
        _currentFlashMode = ISTCameraFlashModeOff;
    }
    //后置摄像头若不支持闪光灯隐藏按钮
    if (![SLQCameraHelper isBackCameraSupportFlash]) {
        _flashBtn.hidden = YES;
    }
    //预览窗口
    [SLQCameraHelper embedPreviewInView:_previewView];

}



// 重拍照片
- (void)backToCamera
{
    [SLQCameraHelper startRunning];
    
    self.view.alpha = 0.5;
    [UIView animateWithDuration:1 animations:^{
        self.captureImage = nil;
        self.photoImageView.hidden = YES;
        self.useBtn.hidden = YES;
        self.againBtn.hidden = YES;
        
        self.flashBtn.hidden = NO;
        self.takePhotoBtn.hidden = NO;
        self.backBtn.hidden = NO;
        self.toggleCameraBtn.hidden = NO;
        self.view.alpha = 1;
        [self.view setNeedsDisplay];
    }];
}

- (void)sliderValueChanged:(UISlider *)slider {
    NSLog(@"%f",slider.value);
    [SLQCameraHelper zoomCarema:slider.value];
}

- (void)sliderValueEnd:(UISlider *)slider {
    NSLog(@"%f",slider.value);
    [SLQCameraHelper cancelZoomRamp];
}


/**
 *  使用照片
 */
- (void)useBtnClick {

    // 回调图片
    if (self.getImageBlock) {
        if (self.captureImage) {
            self.getImageBlock(self.captureImage,self);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //开始实时取景
    [SLQCameraHelper startRunning];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //停止取景
    [SLQCameraHelper stopRunning];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一级控制器
- (void)backToMainVc:(UIButton *)btn
{
    //Back
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)getImageBlock:(GetImageBlock)block {
    if (block) {
        _getImageBlock = block;
    }
}

- (UIView *)viewWithColor:(UIColor *)color {
    UIView *view = [[UIView alloc] initWithFrame:BOX_BOUNDS];
    view.backgroundColor = [UIColor clearColor];
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = 5.0f;
    view.hidden = YES;
    return view;
}

/**
 *  单击手势
 *
 *  @param recognizer 手势
 */
- (void)handleSingleTap:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    [self runBoxAnimationOnView:self.focusBox point:point];
    [SLQCameraHelper focusPoint:point];
    
}

// 对焦边框动画
- (void)runBoxAnimationOnView:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
                     }
                     completion:^(BOOL complete) {
                         double delayInSeconds = 0.5f;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             view.hidden = YES;
                             view.transform = CGAffineTransformIdentity;
                         });
                     }];
}

//拍照
- (void)takePhoto:(UIButton *)btn
{
    __weak typeof (self)weakSelf = self;
    [SLQCameraHelper captureStillImageWithBlock:^(UIImage *captureImage){

        [UIView animateWithDuration:0.1 animations:^{
            //停止取景
            [SLQCameraHelper stopRunning];
            UIImageWriteToSavedPhotosAlbum(captureImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            weakSelf.captureImage = captureImage;
            weakSelf.photoImageView.image = captureImage;
            weakSelf.photoImageView.hidden = NO;
            weakSelf.useBtn.hidden = NO;
            weakSelf.againBtn.hidden = NO;
            
            weakSelf.flashBtn.hidden = YES;
            weakSelf.takePhotoBtn.hidden = YES;
            weakSelf.backBtn.hidden = YES;
            weakSelf.toggleCameraBtn.hidden = YES;
            [weakSelf.view setNeedsDisplay];
        }];

    }];
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    NSLog(@"%@",msg);
}


//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = (UITouch *)[touches anyObject];
//    CGPoint currentPoint = [touch locationInView:self.view];
//    [SLQCameraHelper focusPoint:currentPoint];
//}

//切换镜头
- (void)toggleCamera:(UIButton *)btn
{
    btn.enabled = NO;
    [SLQCameraHelper toggleCamera];
    btn.enabled = YES;
    if ([SLQCameraHelper isBackFacingCamera]) {
        if ([SLQCameraHelper isBackCameraSupportFlash]) {
            _flashBtn.hidden = NO;
        }
    }else{
        _flashBtn.hidden = YES;
    }
}

//切换闪光灯
- (void)changeFlashMode
{
    if (_currentFlashMode == ISTCameraFlashModeAuto) {
        //切换到闪光灯为开
        if ([SLQCameraHelper isBackCameraFlashSupportOnMode]) {
            [SLQCameraHelper changeBackCameraFlashModeToOn];
            _currentFlashMode = ISTCameraFlashModeOn;
            [_flashBtn setTitle:@"开启" forState:UIControlStateNormal];
        }else if ([SLQCameraHelper isBackCameraFlashSupportOffMode]){
            //切换到闪光灯为关
            [SLQCameraHelper changeBackCameraFlashModeToOff];
            _currentFlashMode = ISTCameraFlashModeOff;
            [_flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
        }
    }else if (_currentFlashMode == ISTCameraFlashModeOn) {
        //切换到闪光灯为关
        if ([SLQCameraHelper isBackCameraFlashSupportOffMode]) {
            [SLQCameraHelper changeBackCameraFlashModeToOff];
            _currentFlashMode = ISTCameraFlashModeOff;
            [_flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
        }else if ([SLQCameraHelper isBackCameraFlashSupportAutoMode]){
            //切换到闪光灯为自动
            [SLQCameraHelper changeBackCameraFlashModeToAuto];
            _currentFlashMode = ISTCameraFlashModeAuto;
            [_flashBtn setTitle:@"自动" forState:UIControlStateNormal];
        }
    }else if (_currentFlashMode == ISTCameraFlashModeOff) {
        //切换到闪光灯为自动
        if ([SLQCameraHelper isBackCameraFlashSupportAutoMode]) {
            [SLQCameraHelper changeBackCameraFlashModeToAuto];
            _currentFlashMode = ISTCameraFlashModeAuto;
            [_flashBtn setTitle:@"自动" forState:UIControlStateNormal];
        }else if ([SLQCameraHelper isBackCameraFlashSupportOnMode]){
            //切换到闪光灯为开
            [SLQCameraHelper changeBackCameraFlashModeToOn];
            _currentFlashMode = ISTCameraFlashModeOn;
            [_flashBtn setTitle:@"开启" forState:UIControlStateNormal];
        }
    }
}
@end
