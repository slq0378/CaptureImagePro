//
//  ViewController.m
//  CaptureImagePro
//
//  Created by Christian on 16/6/12.
//  Copyright © 2016年 slq. All rights reserved.
//
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "SLQCameraViewController/SLQCameraViewController.h"

@interface ViewController ()
/**iamge*/
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do anyu additional setup after loading the view, typically from a nib.
    
    // 初始化界面
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(ScreenWidth/2-50, ScreenHeight-200, 100, 100);
    [btn setTitle:@"拍照" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2-100, ScreenHeight/2-200, 200, 200)];
    [self.view addSubview:imageV];
    imageV.backgroundColor = [UIColor greenColor];
    _imageView = imageV;
    
}

/**
 *  拍照
 */
- (void)takePhoto {
    __weak typeof (self)weakSelf = self;
    SLQCameraViewController *vc = [[SLQCameraViewController alloc] init];
    [vc getImageBlock:^(UIImage *image, UIViewController *controller) {
        weakSelf.imageView.image = image;
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
