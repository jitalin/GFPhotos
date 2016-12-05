//
//  DemoViewController.m
//  获取相册视频和图片-photos框架
//
//  Created by 高飞 on 16/12/5.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import "DemoViewController.h"
#import "GFPhotos.h"
@interface DemoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) GFPhotos* photo;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.创建Photos实例
    GFPhotos* photo = [[GFPhotos alloc]init];
    self.photo = photo;
    

}
- (IBAction)saveImageOnlyToSystemCollection:(id)sender {
    [self saveImageOnlyToSystemCollectionWithImage:self.imageView.image];
    
}
- (IBAction)saveImageBothToCustomCollection:(id)sender {
    
    [self saveImageBothToCustomCollectionWithImage:self.imageView.image Title:@"新相册"];
    
}
- (IBAction)getAllPhotos:(id)sender {
    //2.获取所有图片或视频
    [self.photo getAllImagesOrVideosWithMediaType:PHAssetMediaTypeImage];
       //3.获取resultBlock
    [self.photo getResultWithResultBlock:^(NSArray *allPhotos, NSArray *allVideos) {
        NSLog(@"allphotos:%@",allPhotos);
        NSLog(@"allVideo:%@",allVideos);
        
    }];

}
- (IBAction)deleteLastPhotoInCollection:(id)sender {
    [self deleteLastPhotoInCollectionWithTitle:@"新相册"];
    
}
- (IBAction)getAllVideos:(id)sender {
     [self.photo getAllImagesOrVideosWithMediaType:PHAssetMediaTypeVideo];
    [self.photo getResultWithResultBlock:^(NSArray *allPhotos, NSArray *allVideos) {
        NSLog(@"allVideo:%@",allVideos);
        
    }];
}
#pragma mark--------   只在系统相册创建添加照片
- (void)saveImageOnlyToSystemCollectionWithImage:(UIImage*)image{
    [self.photo getRequestAuthorizationWithHandleBlock:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            return ;
        }
        


        [self.photo createdAssetsWithCreatedAssetId:[self.photo createdAssetIdWithImage:image]];
    }];
    
    
    
   
}
#pragma mark---------在系统相册和自定义相册里都添加照片
- (void)saveImageBothToCustomCollectionWithImage:(UIImage*)image Title:(NSString* )title{
    
    [self.photo getRequestAuthorizationWithHandleBlock:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            return ;
        }
    
        [self.photo saveImageIntoAlbumWithImage:image CreatedCollectionTitle:title];
   

    }];
    
}
#pragma mark-------删除某自定义相册的最后一张图片
- (void)deleteLastPhotoInCollectionWithTitle:(NSString* )title{
    [self.photo getRequestAuthorizationWithHandleBlock:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            return ;
        }
    [self.photo deletePhotoFormCollection:[self.photo createdCollectionWithTilte:title]];
    }];
    
}
@end
