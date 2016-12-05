//
//  Photos.m
//  获取相册视频和图片-photos框架
//
//  Created by 高飞 on 16/11/18.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import "GFPhotos.h"

@implementation GFPhotos
#pragma mark--------获取相册权限
- (void)getRequestAuthorizationWithHandleBlock:(StatusBlock)handleBlock{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handleBlock(status);

        });
    }];
   
}
#pragma mark--------------- 保存图片到相册
-(void)saveImageIntoAlbumWithImage:(UIImage*)image CreatedCollectionTitle:(NSString* )createdCollectionTitle
{
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
    }];
    
    // 获得相片
    NSString* createdAssetId = [self createdAssetIdWithImage:image];
    
    PHFetchResult<PHAsset *> *createdAssets = [self createdAssetsWithCreatedAssetId:createdAssetId];
    
    
    
    // 获得相册
    PHAssetCollection *createdCollection = [self createdCollectionWithTilte:createdCollectionTitle];
                                
    if (createdAssets == nil || createdCollection == nil) {
        NSLog (@"保存失败1！");
        return;
    }
 
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
      
    
        //增删改都只能在block进行
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    // 保存结果
    if (error) {
        NSLog(@"保存失败！");
    } else {
        NSLog(@"保存成功！");
    }
    
 
}

#pragma mark--------------- 获得刚才添加到【相机胶卷】中的图片
- (NSString*)createdAssetIdWithImage:(UIImage*)image{

    __block NSString *createdAssetId = nil;
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //增加图片

        
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
   
        NSLog(@"ID:%@",createdAssetId);
        
    } error:nil];
  
    
        return createdAssetId;
   
    
    

}

-(PHFetchResult<PHAsset *> *)createdAssetsWithCreatedAssetId:(NSString*)createdAssetId{
    if (!createdAssetId) return nil;
    // 在保存完毕后取出图片
    
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];

}
//获得【自定义相册】
- (NSString*)createdCollectionIdWithTitle:(NSString*)title{
    __block NSString *createdCollectionId = nil;
    // 创建一个新的相册ID
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    return createdCollectionId;
    

}
-(PHAssetCollection *)createdCollectionWithTilte:(NSString* )title{
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //是否存在相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
//创建新相册
    NSString* createdCollectionId = [self createdCollectionIdWithTitle:title];
    if (createdCollectionId == nil) return nil;
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}







#pragma mark - 获取相册中的图片
/**
 * 获取所有的图片
 */
- (void)getAllImagesOrVideosWithMediaType:(PHAssetMediaType)mediaType{
     NSMutableArray* mArray = [NSMutableArray array];
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
       
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 1.获取自定义相册的图片，遍历所有的自定义相册
            PHFetchResult<PHAssetCollection *> *collectionResult0 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            
            for (PHAssetCollection *collection in collectionResult0) {
                if (mediaType == PHAssetMediaTypeVideo)
                    continue;
                [mArray addObjectsFromArray:[GFPhotos getAllImagesOrVideosInCollection:collection MediaType:mediaType]];
                
                
            }
            
            // 2.获得相机胶卷的图片
            PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *collection in collectionResult1) {
                switch (mediaType) {
                    case PHAssetMediaTypeUnknown:
                    case PHAssetMediaTypeAudio:
                        ;
                    case PHAssetMediaTypeImage: {
                        if (![collection.localizedTitle isEqualToString:@"Camera Roll"]) continue;
                        [mArray addObjectsFromArray:[GFPhotos getAllImagesOrVideosInCollection:collection MediaType:mediaType]];
                        self.resultBlock([mArray mutableCopy],nil);
                        
                    }
                    case PHAssetMediaTypeVideo: {
                        if ([collection.localizedTitle isEqualToString:@"Videos"]) {
                            [mArray addObjectsFromArray:[GFPhotos getAllImagesOrVideosInCollection:collection MediaType:mediaType]];
                          self.resultBlock(nil,[mArray mutableCopy]);
                            
                        }
                        
                      
                    }
                    
                }
            }
            
        });
       
    }];
    
    
}

/**
 * 获取某个相册里面的所有图片或视频
 */
+ (NSArray*)getAllImagesOrVideosInCollection:(PHAssetCollection *)collection MediaType:(PHAssetMediaType)mediaType
{
     NSMutableArray* mArray = [NSMutableArray array];
    // 采取同步获取图片（只获得一次图片）
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    
    NSLog(@"相册名字：%@", collection.localizedTitle);
    
    // 遍历这个相册中的所有图片
    PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    for (PHAsset *resultAsset in assetResult) {
        
        // 过滤非图片
        switch (mediaType) {
            case PHAssetMediaTypeUnknown: {
                ;
                break;
            }
            case PHAssetMediaTypeImage: {
                // 图片原尺寸
                CGSize targetSize = CGSizeMake(resultAsset.pixelWidth, resultAsset.pixelHeight);
                // 请求图片
                
                [[PHImageManager defaultManager] requestImageForAsset:resultAsset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    [mArray addObject:result];
                }];
 
                break;
            }
            case PHAssetMediaTypeVideo: {
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.deliveryMode=PHVideoRequestOptionsDeliveryModeAutomatic;
                [[PHImageManager defaultManager]requestAVAssetForVideo:resultAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    NSLog(@"%@",asset);
                    [mArray addObject:asset];
             
                    
                    
                    
                    
                    
                }];
                
                break;
            }
            case PHAssetMediaTypeAudio: {
                ;
                break;
            }
        }
   
       
    }
    
    return [mArray mutableCopy];
    
}
- (void)deletePhotoFormCollection:(PHAssetCollection*)collection{
    PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:[PHFetchOptions new]];
    [assetResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //获取相册的最后一张照片
            if (idx == [assetResult count] - 1) {
                [PHAssetChangeRequest deleteAssets:@[obj]];
            }
        } completionHandler:^(BOOL success, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }];
    
    //    PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:[PHFetchOptions new]] ;
    //    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        PHAssetCollection *assetCollection = obj;
    //        if ([assetCollection.localizedTitle isEqualToString:@"Camera Roll"])  {
    //            PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[PHFetchOptions new]];
    //            [assetResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    //                    //获取相册的最后一张照片
    //                    if (idx == [assetResult count] - 1) {
    //                        [PHAssetChangeRequest deleteAssets:@[obj]];
    //                    }
    //                } completionHandler:^(BOOL success, NSError *error) {
    //                    NSLog(@"Error: %@", error);
    //                }];
    //            }];
    //        }
    //    }];
    
}
#pragma mark-------获取所有图片和视频的resultBlock
- (void)getResultWithResultBlock:(ResultBlock)resultBlock{
    self.resultBlock = resultBlock;
    
}
@end
