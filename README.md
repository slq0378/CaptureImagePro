# CaptureImagePro
通过AVFoundation自定义摄像机

## 使用很简单

- 可通过Cocoapod安装 
   - `pod "CaptureImagePro" `


- 效果

![](CaptureImagePro/captureImage.gif)

- 包含头文件
`#import "SLQCameraViewController/SLQCameraViewController.h"`

- 直接使用，通过block回调image

```objc
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
```

