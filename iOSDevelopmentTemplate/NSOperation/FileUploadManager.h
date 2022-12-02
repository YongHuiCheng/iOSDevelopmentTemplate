//
//  FileUploadManager.h
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/12/2.
//

#import <Foundation/Foundation.h>
#import "FileUploadEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileUploadManager : NSObject
EOSingletonH

/// 上传视频
/// - Parameters:
///   - path: 路径
///   - size: 大小
///   - progress: 进度回调
///   - result: 结果回调
- (void)uploadVideo:(NSString *)path
               size:(CGSize)size
           progress:(FileUploadProgresBlock)progress
             result:(FileUploadFinishBlock)result;

/// 多视频文件上传
/// - Parameters:
///   - videos: 视频路径集合
///   - progress: 进度回调
///   - result: 结果回调
- (void)uploadVideos:(NSArray<NSString *> *)videos
            progress:(FileUploadProgresBlock)progress
         resultBlock:(FileUploadGroupFinishBlock)resultBlock;

/// 上传图片，path & image & data 三种方式，任选一种
/// - Parameters:
///   - path: 图片路径
///   - image: 图片数据
///   - data: 图片二进制数据
///   - isCompression: 是否压缩
///   - progress: 进度回调
///   - result: 结果回调
- (void)uploadImagePath:(nullable NSString *)path
                  image:(nullable UIImage *)image
                   data:(nullable NSData *)data
          isCompression:(BOOL)isCompression
               progress:(FileUploadProgresBlock)progress
                 result:(FileUploadFinishBlock)result;

/// 多图片上传，UIImage 方式
/// - Parameters:
///   - imageArray: UIImage 集合
///   - isCompression: 是否压缩
///   - progress: 进度回调
///   - result: 结果回调
- (void)uploadImages:(NSArray<UIImage *> *)imageArray
       isCompression:(BOOL)isCompression
            progress:(FileUploadProgresBlock)progress
         resultBlock:(FileUploadGroupFinishBlock)resultBlock;

/// 多图片上传，文件路径方式
/// - Parameters:
///   - imageArray: 文件路径合集
///   - isCompression: 是否压缩
///   - progress: 进度回调
///   - result: 结果回调
- (void)uploadImagePaths:(NSArray<NSString *> *)imageArray
           isCompression:(BOOL)isCompression
                progress:(FileUploadProgresBlock)progress
             resultBlock:(FileUploadGroupFinishBlock)resultBlock;

@end

NS_ASSUME_NONNULL_END
