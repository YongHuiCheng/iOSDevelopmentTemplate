//
//  FileUploadOperation.m
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/12/2.
//

#import "FileUploadOperation.h"
#import "YYKit.h"

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

typedef NSMutableDictionary<NSString *, id> FileCallbacksDictionary;

@interface FileUploadOperation ()

@property (nonatomic, assign, getter = isExecuting) BOOL executing;
@property (nonatomic, assign, getter = isFinished) BOOL finished;

/// 计时器
@property (nonatomic, strong) NSTimer *timer;
/// 超时时间默认3分钟
@property (nonatomic, assign) NSInteger timeoutInterval;
/// 计数
@property (nonatomic, assign) NSInteger timeCnt;
/// 线程锁
@property (nonatomic, strong) NSRecursiveLock *lock;
/// 文件信息
@property (nonatomic, strong) NSDictionary *fileInfo;

/// 存储回调
@property (strong, nonatomic, nonnull) NSMutableArray<FileCallbacksDictionary *> *callbackBlocks;


@end

@implementation FileUploadOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

- (instancetype)initWithFileKey:(NSString *)fileKey
                       fileInfo:(NSDictionary *)fileInfo
{
    if (self = [super init]) {
        _executing = NO;
        _finished = NO;
        _timeoutInterval = 180;
        self.timeCnt = 0;
        
        self.fileKey = fileKey;
        NSMutableDictionary *fileDict = [[NSMutableDictionary alloc] initWithDictionary:fileInfo];
        fileDict[FileSDKFileInfoFileMD5Key] = self.fileKey;
        self.fileInfo = fileDict;

        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = FileUploadOperationLockName;
    }

    return self;
}

- (id)addHandlersForProgress:(FileUploadProgresBlock)progressBlock
                   completed:(FileUploadFinishBlock)completedBlock {
    FileCallbacksDictionary *callbacks = [NSMutableDictionary new];

    if (progressBlock) {
        callbacks[kProgressCallbackKey] = [progressBlock copy];
    }

    if (completedBlock) {
        callbacks[kCompletedCallbackKey] = [completedBlock copy];
    }

    @synchronized (self) {
        [self.callbackBlocks addObject:callbacks];
    }
    return callbacks;
}

#pragma mark - 重写Operation部分方法
- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            if (!self.isFinished) {
                self.finished = YES;
            }

            [self callCompletionBlocksWithError:[NSError errorWithDomain:FileUploadErrorDomain
                                                                    code:FileUploadErrorCancelled
                                                                userInfo:@{ NSLocalizedDescriptionKey: @"Operation cancelled by user before sending the request" }]];
            [self reset];
            return;
        }

        [self uploadFile];
        self.executing = YES;
    }
}

- (void)cancel {
    @synchronized (self) {
        [self cancelInternal];
    }
}

- (void)cancelInternal {
    if (self.isFinished) {
        return;
    }

    [super cancel];

    NSLog(@"FileUploadOperation ===== %@文件取消上传", self.fileKey);

    if (self.isExecuting || self.isFinished) {
        if (self.isExecuting) {
            self.executing = NO;
        }

        if (!self.isFinished) {
            self.finished = YES;
        }
    }

    NSError *error = [NSError errorWithDomain:FileUploadErrorDomain
                                         code:FileUploadErrorCancelled
                                     userInfo:@{ NSLocalizedDescriptionKey: @"Operation cancelled by user during sending the request" }];
    [self callCompletionBlocksWithError:error];

    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    @synchronized (self) {
        [self.callbackBlocks removeAllObjects];
    }
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark - privateMethod
- (void)callProgressBlockWithSendSize:(NSInteger)sendSize
                            totalSize:(NSInteger)totalSize
{
    for (FileUploadProgresBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
        progressBlock(sendSize, totalSize);
    }
}

- (void)callCompletionBlocksWithError:(nullable NSError *)error {
    NSLog(@"FileUploadOperation ===== upload error: %@", error.description);
    [self callCompletionBlocksWithResult:nil error:error];
}

- (void)callCompletionBlocksWithResult:(NSDictionary *)result
                                 error:(nullable NSError *)error {
    NSArray<id> *completionBlocks = [self callbacksForKey:kCompletedCallbackKey];

    dispatch_main_async_safe(^{
        for (FileUploadFinishBlock completedBlock in completionBlocks) {
            BOOL success = error ? NO : YES;
            completedBlock(success, error, result);
        }
        [self stopTimer];
    });
}

- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    NSMutableArray<id> *callbacks;

    @synchronized (self) {
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
    }
    [callbacks removeObjectIdenticalTo:[NSNull null]];
    return [callbacks copy];
}

- (void)startTimer {
    YYWeakProxy *weakProxy = [YYWeakProxy proxyWithTarget:self];
    self.timer = [NSTimer timerWithTimeInterval:1
                                         target:weakProxy
                                       selector:@selector(timerAction)
                                       userInfo:nil
                                        repeats:YES];
}

- (void)stopTimer {
    if([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerAction {
    self.timeCnt++;
    if (self.timeCnt >= self.timeoutInterval) {
        [self stopTimer];
        if (self.isExecuting) {
            [self cancel];
        }
    }
}

- (void)uploadFile {
 
    [self startTimer];
    NSLog(@"FileUploadOperation ===== %@文件任务开始", self.fileKey);
    //TODO：code 上传文件的请求
}

- (void)finishUploadFile {
    // 上传结果
    NSDictionary *result = [NSDictionary new];
    [self callCompletionBlocksWithResult:result error:nil];
}

#pragma mark - getter
- (NSMutableArray<FileCallbacksDictionary *> *)callbackBlocks {
    if (!_callbackBlocks) {
        _callbackBlocks = [[NSMutableArray alloc] init];
    }

    return _callbackBlocks;
}
@end
