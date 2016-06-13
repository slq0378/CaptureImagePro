//
//  ISTCameraViewController.h
//  ISTHideCameraShutterDemo
//
//
//  Created by MrSong on 16-5-18.
//  Copyright (c) 2016年 MrSong. All rights reserved.
//

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


#import <UIKit/UIKit.h>
typedef void (^GetImageBlock)(UIImage *,UIViewController *controller);

typedef enum{
    ISTCameraFlashModeAuto = 1,
    ISTCameraFlashModeOn,
    ISTCameraFlashModeOff,
}ISTCameraFlashMode;

@interface SLQCameraViewController : UIViewController

/**GetImageBlock*/
@property (nonatomic, copy) GetImageBlock getImageBlock;
/**
 *  获取图片回调
 *
 *  @param block block description
 */
- (void)getImageBlock:(GetImageBlock)block;

@end
