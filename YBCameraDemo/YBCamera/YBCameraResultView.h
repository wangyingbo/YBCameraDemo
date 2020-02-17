//
//  YBCameraResultView.h
//  YBCameraDemo
//
//  Created by 王迎博 on 2020/2/13.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,CameraStatusCode) {
    /**授权失败*/
    CameraStatusCodeDenied,
    /**无法访问*/
    CameraStatusCodeRestricted,
    /**获取PHAsset失败*/
    CameraStatusCodePhotoFailed,
    /**相册获取或创建失败*/
    CameraStatusCodeAlbumFailed,
};

typedef void(^UsePhotoBlock) (UIImage *img, NSError *error);

@interface YBCameraResultView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *btRephotograph;
@property (strong, nonatomic) UIButton *btUsePhoto;
/**是否保存到相册，默认值为NO，不保存；如果值设为YES，默认保存在系统相册*/
@property (nonatomic, assign) BOOL saved;
/**是否保存在自定义相册里*/
@property (nonatomic, assign) BOOL saveToCustomAlbum;
/**保存到自定义相册时，相册的名字*/
@property (nonatomic, copy) NSString *albumName;


/**重拍block*/
@property (copy, nonatomic) void (^rephotographBlock)(void);
/**使用block*/
@property (copy, nonatomic) UsePhotoBlock usePhotoBlock;


@end

NS_ASSUME_NONNULL_END
