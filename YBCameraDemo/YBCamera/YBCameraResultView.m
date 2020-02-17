//
//  YBCameraResultView.m
//  YBCameraDemo
//
//  Created by 王迎博 on 2020/2/13.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import "YBCameraResultView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

NSString * const kCameraErrorDomain = @"AuthorityDomain";
NSString * const KAlbumErrorDomain = @"AlbumDomain";

@interface YBCameraResultView ()
@property (nonatomic, strong) PHAssetCollection *createdCollection;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *createdAssets;
@end


@implementation YBCameraResultView

#pragma mark - override
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.btRephotograph.frame = CGRectMake(20, self.frame.size.height - 60, 60, 40);
    self.btUsePhoto.frame = CGRectMake(self.frame.size.width - 80, self.frame.size.height - 60, 60, 40);
}

- (void)setSaveToCustomAlbum:(BOOL)saveToCustomAlbum {
    _saveToCustomAlbum = saveToCustomAlbum;
}

- (void)setSaved:(BOOL)saved {
    _saved = saved;
}

#pragma mark - initData

- (void)initData {
    self.saved = NO;
    self.saveToCustomAlbum = NO;
}

#pragma mark - initUI
- (void)initUI {
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.backgroundColor =[UIColor blackColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    
    self.btRephotograph = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.btRephotograph setTitle:@"重拍" forState:UIControlStateNormal];
    [self.btRephotograph addTarget:self action:@selector(rephotographAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btRephotograph];
    
    self.btUsePhoto = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.btUsePhoto setTitle:@"使用" forState:UIControlStateNormal];
    [self.btUsePhoto addTarget:self action:@selector(usePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btUsePhoto];
}

#pragma mark - actions
- (void)rephotographAction:(id)sender {
    if (self.rephotographBlock) {
        self.rephotographBlock();
    }
    [self remove];
}

- (void)usePhotoAction:(id)sender {
    NSError *error = nil;
    
    if (self.saved) {
        [self saveImageWithError:&error completion:^{
            [self useHandler:error];
        }];
    }else {
        [self useHandler:error];
    }
}

- (void)useHandler:(NSError *)error {
    if (self.usePhotoBlock) {
        self.usePhotoBlock(self.imageView.image,error);
    }
    [self remove];
}

- (void)remove {
    [self removeFromSuperview];
}

#pragma mark - private

/**请求授权*/
- (void)saveImageWithError:(NSError *__autoreleasing _Nullable *)error completion:(void(^)(void))completion {
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    // 请求检查访问权限 :
    // 如果用户还没有做出选择，会自动弹框，用户对弹框做出选择后，才会调用block
    // 如果之前已经做过选择，会直接执行block
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前App访问相册
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
                    //提醒用户打开开关
                }
                *error = [NSError errorWithDomain:kCameraErrorDomain code:CameraStatusCodeDenied userInfo:nil];
                !completion?:completion();
            } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前App访问相册
                [self saveImageIntoAlbumWithError:error completion:completion];
            } else if (status == PHAuthorizationStatusRestricted) { // 无法访问相册
                *error = [NSError errorWithDomain:kCameraErrorDomain code:CameraStatusCodeRestricted userInfo:nil];
                !completion?:completion();
            }
        });
    }];
}

/**保存到相册*/
- (void)saveImageIntoAlbumWithError:(NSError *__autoreleasing _Nullable *)error completion:(void(^)(void))completion {
    
    if (!self.saveToCustomAlbum) {
        //保存到系统相册里
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        return;
    }
    
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = self.createdAssets;
    if (createdAssets == nil) {
        *error = [NSError errorWithDomain:KAlbumErrorDomain code:CameraStatusCodePhotoFailed userInfo:nil];
        !completion?:completion();
        return;
    }
    
    // 获得相册
    PHAssetCollection *createdCollection = self.createdCollection;
    if (createdCollection == nil) {
        *error = [NSError errorWithDomain:KAlbumErrorDomain code:CameraStatusCodeAlbumFailed userInfo:nil];
        !completion?:completion();
        return;
    }
    
    // 添加刚才保存的图片到【自定义相册】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:error];
    !completion?:completion();
}

#pragma mark - 获得当前App对应的自定义相册
- (PHAssetCollection *)createdCollection {
    NSString *title = self.albumName;
    if (!title) {
        // 获得APP名字作为相册名
        title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    }
    // 抓取所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    // 查找当前App对应的自定义相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }

    /** 当前App对应的自定义相册没有被创建过 **/
    // 创建一个【自定义相册】
    NSError *error = nil;
    __block NSString *createdCollectionID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) return nil;

    // 根据唯一标识获得刚才创建的相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionID] options:nil].firstObject;
}

#pragma mark - 获得相片
- (PHFetchResult<PHAsset *> *)createdAssets
{
    NSError *error = nil;
    __block NSString *assetID = nil;
    
    // 保存图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) return nil;
    
    // 获取刚才保存的相片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}

#pragma mark - 保存到系统相册的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    [self useHandler:error];
}

@end
