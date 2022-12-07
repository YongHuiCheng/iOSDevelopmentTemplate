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

/// 添加回调
/// - Parameters:
///   - progressBlock: 进度回调
///   - completedBlock: 完成回调
- (nullable id)addHandlersForProgress:(nullable FileUploadProgresBlock)progressBlock
                            completed:(nullable FileUploadFinishBlock)completedBlock;
/// 初始化上传做操
/// - Parameters:
///   - fileKey: 文件md5
///   - fileInfo: 文件其它信息
- (instancetype)initWithFileKey:(NSString *)fileKey
                       fileInfo:(NSDictionary *)fileInfo;

@end

NS_ASSUME_NONNULL_END
