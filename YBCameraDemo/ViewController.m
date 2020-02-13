//
//  ViewController.m
//  YBCameraDemo
//
//  Created by 王迎博 on 2020/2/13.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import "ViewController.h"
#import "YBCamera.h"
#import "YBCameraResultView.h"


#define FULL_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define FULL_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


#ifndef weakify
#define weakify( self ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(self) __weak_##self##__ = self; \
_Pragma("clang diagnostic pop")
#endif
#ifndef strongify
#define strongify( self ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(self) self = __weak_##self##__; \
_Pragma("clang diagnostic pop")
#endif



@interface ViewController ()
@property (nonatomic, strong) YBCamera *camera;
@property (nonatomic, strong) YBCameraResultView *resultView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self configCamera];
    
    [self configButtons];
}

#pragma mark - configUI

- (void)configCamera {
    self.camera = [[YBCamera alloc] initWithFrame:self.view.bounds];
    //拍摄有效区域（可不设置，不设置则不显示遮罩层和边框）
    self.camera.effectiveRect = CGRectMake(20, 200, self.view.frame.size.width - 40, 280);
    self.camera.effectiveRectBorderColor = [UIColor redColor];
    [self.view insertSubview:self.camera atIndex:0];
}

- (void)configButtons {
    CGFloat button_w = 120.f;
    CGFloat button_h = 40.f;
    CGFloat space = (FULL_SCREEN_WIDTH - button_w*2)/3;
    
    //拍照
    UIButton *takePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(FULL_SCREEN_WIDTH/2 - button_w/2, FULL_SCREEN_HEIGHT - button_h - 20, button_w, button_h)];
    [takePhotoButton setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhotoButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:takePhotoButton];
    [takePhotoButton addTarget:self action:@selector(takePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //闪光灯
    UIButton *flashButton = [[UIButton alloc] initWithFrame:CGRectMake(FULL_SCREEN_WIDTH/2 - button_w - space/2, CGRectGetMinY(takePhotoButton.frame) - button_h*2, button_w, button_h)];
    [flashButton setTitle:@"闪光灯：关" forState:UIControlStateNormal];
    [flashButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:flashButton];
    [flashButton addTarget:self action:@selector(flashAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //前后摄像头
    UIButton *orientButton = [[UIButton alloc] initWithFrame:CGRectMake(FULL_SCREEN_WIDTH/2 + space/2, CGRectGetMinY(flashButton.frame), button_w, button_h)];
    [orientButton setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [orientButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:orientButton];
    [orientButton addTarget:self action:@selector(orientAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - actions

- (void)takePhotoAction:(UIButton *)sender {
    @weakify(self);
    [self.camera takePhoto:^(UIImage *img) {
        @strongify(self);
        self.resultView = [[YBCameraResultView alloc] initWithFrame:self.view.bounds];
        self.resultView.imageView.image = img;
       
        @weakify(self);
        self.resultView.rephotographBlock = ^ {
           @strongify(self);
           [self.camera restart];
        };
        self.resultView.usePhotoBlock = ^(UIImage *img){
        };
        [self.view addSubview:self.resultView];
    }];
}

- (void)flashAction:(UIButton *)sender {
    sender.tag += 1;
    sender.tag = sender.tag%3;
    
    NSString *title = @"";
    switch (sender.tag) {
        case 0: {
            title = @"闪光灯：关";
        }
            break;
        case 1: {
            title = @"闪光灯：开";
        }
            break;
        case 2: {
            title = @"闪光灯：自动";
        }
            break;
            
        default:
            break;
    }
    
    [sender setTitle:title forState:UIControlStateNormal];
    [self.camera switchLight:(YBCaptureFlashMode)sender.tag];
}

- (void)orientAction:(UIButton *)sender {
    [self.camera switchCamera:!self.camera.isCameraFront];
    if (self.camera.isCameraFront) {
        [sender setTitle:@"前摄像头" forState:UIControlStateNormal];
    }else {
        [sender setTitle:@"后摄像头" forState:UIControlStateNormal];
    }
}

@end
