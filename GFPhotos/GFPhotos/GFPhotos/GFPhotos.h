//
//  Photos.h
//  获取相册视频和图片-photos框架
//
//  Created by 高飞 on 16/11/18.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;

/**
 *  相册权限Block
 *
 *  @param status PHAuthorizationStatus
 */
typedef void(^StatusBlock)(PHAuthorizationStatus status);
/**
 *  获取所有照片或视频Blcok
 *
 *  @param allPhotos 所有照片
 *  @param allVideos 所有视频
 */
typedef void(^ResultBlock)(NSArray<UIImage*>* allPhotos,NSArray<AVURLAsset*> * allVideos);

@interface GFPhotos : PHObject
@property (nonatomic,strong) PHAssetCollection *createdCollection;
@property (nonatomic,strong) PHFetchResult *createdAssets;
@property (nonatomic,strong) PHFetchResult *fetchResult;
@property (nonatomic,copy) StatusBlock statusBlock;
@property (nonatomic,copy) ResultBlock resultBlock;
/**
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



@end
