//
//  SLQCameraHelper
//
//
//  Created by MrSong on 16-5-18.
//  Copyright (c) 2016年 MrSong. All rights reserved.
//

#import "SLQCameraHelper.h"
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>

@implementation SLQCameraHelper

static SLQCameraHelper *sharedInstance = nil;

- (void)initialize
{
    //正在处理生成图片为NO
    self.isProcessingImage = NO;
    //1.创建会话层
    self.capSession = [[AVCaptureSession alloc] init];
    [self.capSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    
//    2.创建、配置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSError *error;
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (captureInput)
    {
        if([self.capSession canAddInput:captureInput]) {
            
            [self.capSession addInput:captureInput];
        }
        
    }else {
        NSLog(@"Error: %@", error);
    }
    _device = device;
   
    
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    if ([self.capSession canAddInput:newVideoInput]) {
        [self.capSession addInput:newVideoInput];
    }
    self.videoInput = newVideoInput;
    //3.创建、配置输出
    _captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    _captureOutput.outputSettings = outputSettings;
//    [_captureOutput setOutputSettings:outputSettings];

	[self.capSession addOutput:_captureOutput];
    
    // 是否支持对焦
//    [self focusPoint];
    
    
}
- (id) init
{
	if (self = [super init]) [self initialize];
	return self;
}

-(void) embedPreviewInView: (UIView *) aView {
    if (!_capSession) return;
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession: _capSession];
    _preview.frame = aView.bounds;
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [aView.layer addSublayer: _preview];
}

-(void)captureimage
{
    //将处理图片状态值置为YES
    self.isProcessingImage = YES;
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    __block SLQCameraHelper *objSelf = self;
    [_captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             NSLog(@"开始生成图片");
             UIImage *tempImage = [[UIImage alloc] initWithData:imageData];
             objSelf.image = tempImage;
             //将处理图片状态值置为NO
             objSelf.isProcessingImage = NO;
         }
     }];
}
- (void)captureImage:(CaptureImageBlock)block{
    //get connection
    _captureBlock = block;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    __block SLQCameraHelper *objSelf = self;

    [_captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             NSLog(@"开始生成图片");
             UIImage *tempImage = [[UIImage alloc] initWithData:imageData];
             objSelf.image = tempImage;
             //返回图片
             objSelf.captureBlock(objSelf.image);
         }
     }];
}


- (void)zoomCarema:(CGFloat)value {
    if([self canZoom]) {
        
        if(!self.device.isRampingVideoZoom) {
            NSError *error;
            if ([self.device lockForConfiguration:&error]) {
                // 线性转换
                CGFloat zoomFactor = pow([self getMAXZoomValue], value);
                self.device.videoZoomFactor = zoomFactor;
                [self.device unlockForConfiguration];
            }else {
                NSLog(@"缩放失败：%@",[error localizedDescription]);
            }
        }
    }
}

/// 是否支持缩放
- (BOOL)canZoom {
    return self.device.activeFormat.videoMaxZoomFactor > 1.0f;
}
/// 缩放最大值
- (CGFloat)getMAXZoomValue {
    return MIN(self.device.activeFormat.videoMaxZoomFactor, 4.0f);
}

- (void)cancelZoomRamp  {
    
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        [self.device cancelVideoZoomRamp];
        [self.device unlockForConfiguration];
    }else {
        NSLog(@"设置缩放状态失败：%@",[error localizedDescription]);
    }
}



- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
/**
 *  对焦
 */
- (void)focusPoint:(CGPoint )point {
    AVCaptureDevice *device = self.videoInput.device;
    NSError *error;
    if([device isFocusPointOfInterestSupported]
       && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        if([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }else {
            // 对焦失败
            NSLog(@"对焦失败 = %@",error);
        }
    }
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (BOOL) toggleCameraPosition
{
    BOOL success = NO;

    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        else
            goto bail;
        
        if (newVideoInput != nil) {
            [[self capSession] beginConfiguration];
            [[self capSession] removeInput:[self videoInput]];
            if ([[self capSession] canAddInput:newVideoInput]) {
                [[self capSession] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [[self capSession] addInput:[self videoInput]];
            }
            [[self capSession] commitConfiguration];
            success = YES;
        } else if (error) {
            NSLog(@"切换镜头出错:%@",error);
        }
    }
    
bail:
    return success;
}
- (BOOL)isUseBackFacingCamera
{
    BOOL isUse;
    AVCaptureDevicePosition position = [[_videoInput device] position];
    
    if (position == AVCaptureDevicePositionBack){
        isUse = YES;
    }else if (position == AVCaptureDevicePositionFront){
        isUse = NO;
    }else{
        isUse = NO;
    }
    return isUse;
}
- (BOOL)isBackCameraHasFlash
{
    if ([[self backFacingCamera] hasFlash]) {
        return YES;
    }
    return NO;
}
- (BOOL)isFlashSupportAutoMode
{
    if ([[self backFacingCamera] hasFlash]) {
        if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
            return YES;
        }
	}
    return NO;
}
- (BOOL)isFlashSupportOnMode
{
    if ([[self backFacingCamera] hasFlash]) {
        if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOn]) {
            return YES;
        }
	}
    return NO;
}
- (BOOL)isFlashSupportOffMode
{
    if ([[self backFacingCamera] hasFlash]) {
        if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOff]) {
            return YES;
        }
	}
    return NO;
}
- (void)changeFlashModeToAuto
{
    if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
}
- (void)changeFlashModeToOn
{
    if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOn]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeOn];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
}
- (void)changeFlashModeToOff
{
    if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOff]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeOff];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
}
#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (void) dealloc
{
//    Block_release(captureBlock);
    [[self capSession] stopRunning];
	self.capSession = nil;
	self.image = nil;
}
#pragma mark Class Interface


+ (void)zoomCarema:(CGFloat)value {
     [[self sharedInstance] zoomCarema:value];
}


+ (void)cancelZoomRamp {
    [[self sharedInstance] cancelZoomRamp];
}

+ (id) sharedInstance // private
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SLQCameraHelper alloc] init];
    });
    return sharedInstance;
}


+ (void) startRunning
{
    [[[self sharedInstance] capSession] startRunning];
}


+ (void) stopRunning
{
    [[[self sharedInstance] capSession] stopRunning];
}

+ (BOOL)toggleCamera
{
    return [[self sharedInstance] toggleCameraPosition];
}


+ (void)focusPoint:(CGPoint )point {
    [[self sharedInstance] focusPoint:point];
}


+ (UIImage *) image
{
    //判断图片状态状态值，如果为YES，则等待，避免因还未生成图片时取图片而造成的返回照片不正确的问题
//    BOOL shouldWait = YES;
//    while (shouldWait) {
//        if (![[ISTCameraHelper sharedInstance] isProcessingImage]) {
//            NSLog(@"照片组成完毕");
//            shouldWait = NO;
//        }
//    }
    NSLog(@"取图片");
    return [[self sharedInstance] image];
}

+ (void)captureStillImage
{
    [[self sharedInstance] captureimage];
}

+ (void)captureStillImageWithBlock:(CaptureImageBlock)block
{
    [[self sharedInstance] captureImage:block];
}

+ (void)embedPreviewInView: (UIView *) aView
{
    [[self sharedInstance] embedPreviewInView:aView];
}

+ (BOOL)isBackFacingCamera
{
    return [[self sharedInstance] isUseBackFacingCamera];
}

+ (BOOL)isBackCameraSupportFlash
{
    return [[self sharedInstance] isBackCameraHasFlash];
}

+ (BOOL)isBackCameraFlashSupportAutoMode
{
    return [[self sharedInstance] isFlashSupportAutoMode];
}

+ (BOOL)isBackCameraFlashSupportOnMode
{
    return [[self sharedInstance] isFlashSupportOnMode];
}

+ (BOOL)isBackCameraFlashSupportOffMode
{
    return [[self sharedInstance] isFlashSupportOffMode];
}

+ (void)changeBackCameraFlashModeToAuto
{
    [[self sharedInstance] changeFlashModeToAuto];
}

+ (void)changeBackCameraFlashModeToOn
{
    [[self sharedInstance] changeFlashModeToOn];
}

+ (void)changeBackCameraFlashModeToOff
{
    [[self sharedInstance] changeFlashModeToOff];
}

@end
