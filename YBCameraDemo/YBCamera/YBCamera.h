//
//  YBCamera.h
//  YBCameraDemo
//
//  Created by 王迎博 on 2020/2/13.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,YBCaptureFlashMode) {
    /**闪光灯关闭*/
    YBCaptureFlashModeOff = 0,
    /**闪光灯打开*/
    YBCaptureFlashModeOn,
    /**闪光灯自动*/
    YBCaptureFlashModeAuto,
};

@interface YBCamera : UIView

/**拍摄有效区域（（可不设置，不设置则不显示遮罩层和边框）*/
@property (assign, nonatomic) CGRect effectiveRect;
/**有效区域的背景图*/
@property (nonatomic, strong) UIImageView *effectiveImageView;
/**有效区边框色，默认橘色*/
@property (nonatomic, strong) UIColor *effectiveRectBorderColor;
/**遮罩层颜色，默认黑色半透明*/
@property (nonatomic, strong) UIColor *maskColor;
/**聚焦的view*/
@property (nonatomic) UIView *focusView;

/**获取摄像头方向*/
- (BOOL)isCameraFront;

/**获取闪光灯模式*/
- (YBCaptureFlashMode)getCaptureFlashMode;

/**切换闪光灯*/
- (void)switchLight:(YBCaptureFlashMode)flashMode;

/**切换摄像头*/
- (void)switchCamera:(BOOL)isFront;

/**拍照*/
- (void)takePhoto:(void (^)(UIImage *img))resultBlock;

/**重拍*/
- (void)restart;

/**调整图片朝向*/
+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end

NS_ASSUME_NONNULL_END
