//
//  FileUploadManager.m
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/12/2.
//

#import "FileUploadManager.h"
#import <AVFoundation/AVFoundation.h>
#import "FileUploadOperation.h"
#import "NSData+EO.h"

@interface FileUploadManager ()
@property (nonatomic, strong) dispatch_queue_t addOperationSerialQueue;

/// 上传队列
@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@end

@implementation FileUploadManager
EOSingletonM

- (instancetype)init {
    self = [super init];
    if (!self) {
        self.uploadQueue = [[NSOperationQueue alloc] init];
        self.uploadQueue.maxConcurrentOperationCount = 5;
        self.addOperationSerialQueue = dispatch_queue_create("com.echo.wjUploadOperationSerializeQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)uploadVideo:(NSString *)path
               size:(CGSize)size
           progress:(FileUploadProgresBlock)progress
             result:(FileUploadFinishBlock)result
{
    if (!path.length) {
        dispatch_main_async_safe(^{
            !result ? : result(NO, nil);
        });
        return;
    }

    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        dispatch_main_async_safe(^{
            !result ? : result(NO, nil);
        });
        return;
    }
    [self _uploadVideo:path
                  size:size
              progress:progress
                reslut:result];
}

- (void)uploadVideos:(NSArray<NSString *> *)videos
            progress:(FileUploadProgresBlock)progress
         resultBlock:(FileUploadGroupFinishBlock)resultBlock
{
    if (!videos || !videos.count) {
        !resultBlock ? : resultBlock(NO, nil, nil);
        return;
    }

    NSMutableArray *results = [NSMutableArray array];
    NSMutableArray *failPaths = [NSMutableArray array];

    __block NSInteger allTotalBytes = 0;
    __block NSInteger allTotalBytesSent = 0;

    for (NSString *path in videos) {
        [self uploadVideo:path size:CGSizeZero progress:^(NSInteger totalBytesSent, NSInteger totalBytes) {
            if (totalBytesSent == 0) {
                allTotalBytes += totalBytes;
            } else {
                allTotalBytesSent += totalBytesSent;
            }
            !progress ? : progress(allTotalBytesSent, allTotalBytes);
        } result:^(BOOL success, NSDictionary * _Nullable result) {
            if (success) {
                [results addObject:result];
            } else {
                [failPaths addObject:path];
            }
            // operation 回调完成
            if (results.count + failPaths.count == videos.count) {
                BOOL success = !failPaths.count;
                !result ? : resultBlock(success, results, failPaths);
            }
        }];
    }
}

- (void)uploadImagePath:(NSString *)path
                  image:(UIImage *)image
                   data:(NSData *)data
          isCompression:(BOOL)isCompression
               progress:(FileUploadProgresBlock)progress
                 result:(FileUploadFinishBlock)result
{
    [self _uploadImagePath:path
                     image:image
                      data:data
                  progress:progress
                    result:result
             isCompression:isCompression];
}

- (void)uploadImagePaths:(NSArray<NSString *> *)imageArray
           isCompression:(BOOL)isCompression
                progress:(FileUploadProgresBlock)progress
             resultBlock:(FileUploadGroupFinishBlock)resultBlock
{
    if (!imageArray || !imageArray.count) {
        !resultBlock ? : resultBlock(NO, nil, nil);
        return;
    }

    NSMutableArray *results = [NSMutableArray array];
    NSMutableArray *failImages = [NSMutableArray array];

    __block NSInteger allTotalBytes = 0;
    __block NSInteger allTotalBytesSent = 0;

    for (NSString *path in imageArray) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage imageWithData:data];

        [self uploadImagePath:path
                        image:image
                         data:data
                isCompression:isCompression
                     progress:^(NSInteger totalBytesSent, NSInteger totalBytes) {
            if (totalBytesSent == 0) {
                allTotalBytes += totalBytes;
            } else {
                allTotalBytesSent += totalBytesSent;
            }

            !progress ? : progress(allTotalBytesSent, allTotalBytes);
        } result:^(BOOL success, NSDictionary * _Nullable result) {
            if (success) {
                [results addObject:result];
            } else {
                [failImages addObject:path];
            }
            // operation 回调完成
            if (results.count + failImages.count == imageArray.count) {
                BOOL success = !failImages.count;
                !resultBlock ? : resultBlock(success, results, failImages);
            }
        }];
    }
}

- (void)uploadImages:(NSArray<UIImage *> *)imageArray
       isCompression:(BOOL)isCompression
            progress:(FileUploadProgresBlock)progress
         resultBlock:(FileUploadGroupFinishBlock)resultBlock
{
    if (!imageArray || !imageArray.count) {
        !resultBlock ? : resultBlock(NO, nil, nil);
        return;
    }

    NSMutableArray *results = [NSMutableArray array];
    NSMutableArray *failImages = [NSMutableArray array];

    __block NSInteger allTotalBytes = 0;
    __block NSInteger allTotalBytesSent = 0;

    for (UIImage *image in imageArray) {

        [self uploadImagePath:nil
                        image:image
                         data:nil
                isCompression:isCompression
                     progress:^(NSInteger totalBytesSent, NSInteger totalBytes) {
            if (totalBytesSent == 0) {
                allTotalBytes += totalBytes;
            } else {
                allTotalBytesSent += totalBytesSent;
            }

            !progress ? : progress(allTotalBytesSent, allTotalBytes);
        } result:^(BOOL success, NSDictionary * _Nullable result) {
            if (success) {
                [results addObject:result];
            } else {
                [failImages addObject:image];
            }
            // operation 回调完成
            if (results.count + failImages.count == imageArray.count) {
                BOOL success = !failImages.count;
                !resultBlock ? : resultBlock(success, results, failImages);
            }
        }];
    }
}

#pragma mark - privateMethod
- (void)_uploadVideo:(NSString *)path
                size:(CGSize)size
            progress:(FileUploadProgresBlock)progress
              reslut:(FileUploadFinishBlock)reslut {

    NSMutableDictionary *fileInfo = [NSMutableDictionary new];
    
    // 文件类型
    fileInfo[FileSDKFileInfoFileTypeKey] = @(FileUploadFileTypeImage);
    
    // 文件路径&文件名称，如果文件为空，随机生成一个
    NSString *fileName;
    if (path) {
        fileInfo[FileSDKFileInfoFilePathKey] = path;
        fileName = [path lastPathComponent];
    }
    if (fileName.length == 0) {
        fileName = [FileUploadManager createFileName];
    }
    fileInfo[FileSDKFileInfoFileNameKey] = fileName;
    
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    NSString *md5 = [fileData echo_MD5];

    NSInteger fileSize = (NSInteger)[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    progress(0, fileSize);

    CGSize imageSize = [FileUploadManager getVideoSize:size path:path];
    CGFloat duration = [FileUploadManager getVideoDuration:path];

    fileInfo[FileSDKFileInfoImageSizeKey] = [NSValue valueWithCGSize:imageSize];
    fileInfo[FileSDKFileInfoDurationlKey] = @(duration);
    fileInfo[FileSDKFileInfoFileSizeKey] = @(fileSize);

    
    [self _uploadFileWithFileKey:md5
                        fileInfo:fileInfo
                        progress:progress
                        result:reslut];
}

- (void)_uploadImagePath:(NSString *)path
                   image:(UIImage *)image
                    data:(NSData *)data
                progress:(FileUploadProgresBlock)progress
                  result:(FileUploadFinishBlock)result
           isCompression:(BOOL)isCompression {
    
    CGFloat compressionQuality = isCompression ? 0.85 : 1;
    NSMutableDictionary *fileInfo = [[NSMutableDictionary alloc] init];
    
    // 文件类型
    fileInfo[FileSDKFileInfoFileTypeKey] = @(FileUploadFileTypeImage);
    
    // 文件路径&文件名称，如果文件为空，随机生成一个
    NSString *fileName;
    if (path) {
        fileInfo[FileSDKFileInfoFilePathKey] = path;
        fileName = [path lastPathComponent];
    }
    if (fileName.length == 0) {
        fileName = [FileUploadManager createFileName];
    }
    fileInfo[FileSDKFileInfoFileNameKey] = fileName;

    
    // 获取图片宽高，文件大小，文件md5值
    CGSize imageSize = CGSizeZero;
    NSString *md5 = nil;
    NSData *fileData = nil;
    NSInteger fileSize = 0;

    if (path) {
        fileSize = (NSInteger)[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
        fileData = [NSData dataWithContentsOfFile:path];
    } else if (image) {
        imageSize = image.size;
        fileData = UIImageJPEGRepresentation (image, compressionQuality);
    } else if (data) {
        fileData = data;
    }

    md5 = [fileData echo_MD5];

    
    if (fileData) {
        fileInfo[FileSDKFileInfoFileDataKey] = fileData;
    }
    
    if (!CGSizeEqualToSize(CGSizeZero, imageSize)) {
        UIImage *img = [UIImage imageWithData:fileData];
        imageSize = img.size;
    }
    fileInfo[FileSDKFileInfoImageSizeKey] = [NSValue valueWithCGSize:imageSize];

    if (!fileSize) {
        fileSize = fileData.length;
    }
    fileInfo[FileSDKFileInfoFileSizeKey] = @(fileSize);
    
    progress(0, fileSize);

    // 创建operation，开始上传
    [self _uploadFileWithFileKey:md5
                        fileInfo:fileInfo
                        progress:progress
                        result:result];
}

- (void)_uploadFileWithFileKey:(NSString *)fileKey
                      fileInfo:(NSDictionary *)fileInfo
                      progress:(FileUploadProgresBlock)progress
                        result:(FileUploadFinishBlock)result
{
    FileUploadOperation *operation = [[FileUploadOperation alloc] initWithFileKey:fileKey
                                                                         fileInfo:fileInfo
                                                                     progresBlock:progress
                                                                      resultBlock:result];
    [self addUploadOperation:operation];
}


- (void)addUploadOperation:(FileUploadOperation *)operation {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.addOperationSerialQueue, ^{
        if ([weakSelf isUploadingFile:operation.fileKey]) {
            NSLog(@"重复添加上传任务->\nkey:%@", operation.fileKey);
            return;
        }
        [weakSelf.uploadQueue addOperation:operation];
    });
}

- (BOOL)isUploadingFile:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"operation.fileKey = %@", key];
    NSArray *filterResult = [self.uploadQueue.operations filteredArrayUsingPredicate:predicate];
    return filterResult.count > 0;
}

- (void)cancelUploadOperations {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.uploadQueue cancelAllOperations];
    });
}

#pragma mark - Tool
/// 获取随机文件名
+ (NSString *)createFileName {
    NSInteger time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger random = 1000000 + arc4random() % (1000000 - 1);
    NSInteger random2 = 10000 + arc4random() % (10000 - 1);

    return [NSString stringWithFormat:@"%ld%ld%ld", time, random, random2];
}


/// 获取视频时长
/// - Parameter url: 视频路径
+ (CGFloat)getVideoDuration:(NSString *)url {
    if (!url.length) {
        return 0;
    }

    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:url]];
    CMTime duration = [asset duration];
    CGFloat seconds = ceilf((CGFloat)duration.value / (CGFloat)duration.timescale);
    return seconds;
}


/// 获取视频宽高
/// - Parameters:
///   - size: 默认size
///   - path: 视频路径
+ (CGSize)getVideoSize:(CGSize)size
                  path:(NSString *)path {
    CGSize imageSize = CGSizeZero;

    if (CGSizeEqualToSize(size, CGSizeZero)) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
        NSArray *array = asset.tracks;

        for (AVAssetTrack *track in array) {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                imageSize = track.naturalSize;
                break;
            }
        }
    } else {
        imageSize = size;
    }
    return imageSize;
}

@end
