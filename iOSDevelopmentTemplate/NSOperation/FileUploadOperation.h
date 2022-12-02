//
//  FileUploadOperation.h
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/12/2.
//

#import <Foundation/Foundation.h>
#import "FileUploadEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileUploadOperation : NSOperation

/// 操作唯一id标识符, 也即文件MD5值
@property (nonatomic, copy) NSString *fileKey;

/// 初始化上传操作
/// - Parameters:
///   - fileKey: 文件md5
///   - fileInfo: 文件其它信息
///   - progresBlock: 进度回调
///   - resultBlock: 结果回调
- (instancetype)initWithFileKey:(NSString *)fileKey
                       fileInfo:(NSDictionary *)fileInfo
                   progresBlock:(FileUploadProgresBlock)progresBlock
                    resultBlock:(FileUploadFinishBlock)resultBlock;

@end

NS_ASSUME_NONNULL_END
