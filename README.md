# GFPhotos
Adapted to iOS8 or above，Use Photos framework to get all the album pictures or video, save the picture to the system album or save to the custom album, delete a custom photo album, etc.; 适应于iOS8以上 ，运用Photos 框架 获取所有相册图片或视频，保存图片到系统相册或同时保存到自定义相册，单独删除某自定义相册的图片等；
接口如下：/**
 *   获取相册权限
 */
- (void)getRequestAuthorizationWithHandleBlock:(StatusBlock)handleBlock;
/**
 *  createdAssetId
 *
 *  @param image 要保存的图片
 *
 *  @return createdAssetId 图片ID
 */
- (NSString*)createdAssetIdWithImage:(UIImage*)image;
/**
 *  只在系统相册里添加图片
 *
 *  @param createdAssetId 图片ID
 *
 *  @return 保存图片
 */
-(PHFetchResult<PHAsset *> *)createdAssetsWithCreatedAssetId:(NSString*)createdAssetId;

/**
 *  createdCollectionId
 *
 *  @param title 自定义相册名称
 *
 *  @return createdCollectionId 相册ID
 */
- (NSString*)createdCollectionIdWithTitle:(NSString*)title;
/**
 *  createdCollection
 *
 *  @param title 自定义相册名称
 *
 *  @return createdCollection 自定义相册
 */
-(PHAssetCollection *)createdCollectionWithTilte:(NSString* )title;


/**
 *  保存图片到相册和自定义相册
 *
 *  @param image                  保存的图片
 *  @param createdCollectionTitle 自定义相册名称
 */
-(void)saveImageIntoAlbumWithImage:(UIImage*)image CreatedCollectionTitle:(NSString* )createdCollectionTitle;

/**
 * 获取所有的图片或视频
 */
- (void)getAllImagesOrVideosWithMediaType:(PHAssetMediaType)mediaType;
/**
 * 获取某个相册里面的所有图片或视频的相关数据
 */
+ (NSArray*)getAllImagesOrVideosInCollection:(PHAssetCollection *)collection MediaType:(PHAssetMediaType)mediaType;

//删除自定义相册里的图片
- (void)deletePhotoFormCollection:(PHAssetCollection*)collection;
/**
 *  获取所有图片或视频resultBlock
 *
 *  @param resultBlock ResultBlock
 */
- (void)getResultWithResultBlock:(ResultBlock)resultBlock;


DemoCode below:
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
Contact GitHub API Training Shop Blog About
