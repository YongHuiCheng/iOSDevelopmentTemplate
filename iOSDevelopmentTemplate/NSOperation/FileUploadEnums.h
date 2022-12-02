//
//  FileUploadEnums.h
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/12/2.
//

#ifndef FileUploadEnums_h
#define FileUploadEnums_h

/// 上传操作锁名称
static NSString * _Nullable const FileUploadOperationLockName = @"FileUploadOperationLockName";


// 文件信息key
/// 文件路径
static NSString * _Nullable const FileSDKFileInfoFilePathKey =  @"FilePathKey";
/// 文件名称
static NSString * _Nullable const FileSDKFileInfoFileNameKey =  @"FileNameKey";
/// 文件二进制数据 NSData
static NSString * _Nullable const FileSDKFileInfoFileDataKey =  @"FileDataKey";
/// 文件大小 NSInteger
static NSString * _Nullable const FileSDKFileInfoFileSizeKey =  @"FileSizeKey";
/// 文件类型
static NSString * _Nullable const FileSDKFileInfoFileTypeKey =  @"FileTypeKey";
/// 图片&视频缩略图宽高， CGSize
static NSString * _Nullable const FileSDKFileInfoImageSizeKey =  @"ImageSizeKey";

/// 视频缩略图 UIImage
static NSString * _Nullable const FileSDKFileInfoThumbnailKey =  @"thumbnail";
/// 视频时长 CGFloat
static NSString * _Nullable const FileSDKFileInfoDurationlKey =  @"duration";


/// 上传进度block
typedef void (^FileUploadProgresBlock)(NSInteger totalBytesSent, NSInteger totalBytes);
/// 上传结果block
typedef void (^FileUploadFinishBlock)(BOOL success, NSDictionary *_Nullable result);
/// 批量上传结果block
typedef void (^FileUploadGroupFinishBlock)(BOOL success, NSArray<NSDictionary *> *_Nullable results, NSArray<NSDictionary *> *_Nullable failItems);

/// 文件类型
typedef NS_ENUM(NSUInteger, FileUploadFileType) {
    FileUploadFileTypeImage = 1,   // 图片
    FileUploadFileTypeExcel = 2,   // excel
    FileUploadFileTypeApk   =  3,  // apk
    FileUploadFileTypeVideo =  4,  // 视频
    FileUploadFileTypeOther =  5,  // 其它
};

#endif /* FileUploadEnums_h */
