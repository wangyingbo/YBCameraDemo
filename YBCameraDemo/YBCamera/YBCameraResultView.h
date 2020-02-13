//
//  YBCameraResultView.h
//  YBCameraDemo
//
//  Created by 王迎博 on 2020/2/13.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBCameraResultView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *btRephotograph;
@property (strong, nonatomic) UIButton *btUsePhoto;
/**重拍*/
@property (copy, nonatomic) void (^rephotographBlock)(void);
/**使用*/
@property (copy, nonatomic) void (^usePhotoBlock)(UIImage *img);


@end

NS_ASSUME_NONNULL_END
