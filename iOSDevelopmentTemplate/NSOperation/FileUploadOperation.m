//
//  FileUploadOperation.m
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/12/2.
//

#import "FileUploadOperation.h"

@interface FileUploadOperation ()

/// 超时计时器
@property (nonatomic, strong) dispatch_source_t timer;
/// 定时器挂起状态
@property (nonatomic, assign) BOOL timerValid;

/// 超时时间默认3分钟
@property (nonatomic, assign) NSInteger timeoutInterval;

/// 线程锁
@property (nonatomic, strong) NSRecursiveLock *lock;
/// 文件信息
@property (nonatomic, strong) NSDictionary *fileInfo;
/// 进度回调
@property (nonatomic, copy) FileUploadProgresBlock progresBlock;
/// 结果回调
@property (nonatomic, copy) FileUploadFinishBlock resultBlock;

@end

@implementation FileUploadOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

- (instancetype)initWithFileKey:(NSString *)fileKey
                       fileInfo:(NSDictionary *)fileInfo
                   progresBlock:(nonnull FileUploadProgresBlock)progresBlock
                    resultBlock:(nonnull FileUploadFinishBlock)resultBlock
{
    if (self = [super init]) {
        _executing = NO;
        _finished = NO;
        // 默认三分钟超时
        _timeoutInterval = 180;
        self.fileKey = fileKey;
        self.fileInfo = fileInfo;
        self.progresBlock = progresBlock;
        self.resultBlock = resultBlock;
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = FileUploadOperationLockName;
    }
    return self;
}

- (void)startTimer {
    __weak __typeof(self)weakSelf = self;
    _timerValid = YES;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (_timeoutInterval * NSEC_PER_SEC)), (_timeoutInterval * NSEC_PER_SEC), 0);
    dispatch_source_set_event_handler(_timer, ^{[weakSelf timeoutAction];});
    dispatch_resume(_timer);
}

- (void)stopTimer {
    if (_timerValid) {
        dispatch_source_cancel(_timer);
        _timer = NULL;
        _timerValid = NO;
    }
}

- (void)timeoutAction {
    [self cancel];
}

#pragma mark - privateMethod
+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"WJAsyncOperation"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)operationThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (void)startUpload {
    if (self.isCancelled || self.isFinished || self.isExecuting) {
        return;
    }
    [self KVONotificationWithNotiKey:@"isExecuting" state:&_executing stateValue:YES];
    [self uploadFile];
}

- (void)uploadFile {

    [self startTimer];
    //TODO：BY_huyang 这里开始向服务器上传文件
}

- (void)cancelUpload {
    self.resultBlock = nil;
    self.progresBlock = nil;
}

- (void)uploadFileFailed {
    [self finish];
    if (self.resultBlock) {
        self.resultBlock(NO, nil);
    }
}

- (void)finishUpload {
    self.resultBlock = nil;
    self.progresBlock = nil;
}

#pragma mark - 重写Operation部分方法
- (void)start {
    [self.lock lock];
    // 任务是否取消检测
    if (self.isCancelled) {
        [self finish];
        [self.lock unlock];
        return;
    }
    // 已经完成或者在执行状态，直接返回
    if (self.isFinished || self.isExecuting) {
        [self.lock unlock];
        return;
    }
    // 开始执行上传任务，同时也开启超时计时器
    [self runSelector:@selector(startUpload)];
    [self.lock unlock];
}

- (void)cancel {
    [self.lock lock];
    // 未取消&未完成才执行取消
    if (!self.isCancelled && !self.isFinished) {
        [super cancel];
        [self KVONotificationWithNotiKey:@"isCancelled" state:&_cancelled stateValue:YES];
        // 正在执行，取消任务
        if (self.isExecuting) {
            [self runSelector:@selector(cancelUpload)];
        }
    }
    [self.lock unlock];
}

- (void)finish {
    [self.lock lock];
    if (self.isExecuting) {
        [self KVONotificationWithNotiKey:@"isExecuting" state:&_executing stateValue:NO];
    }
    [self KVONotificationWithNotiKey:@"isFinished" state:&_finished stateValue:YES];
    [self runSelector:@selector(finishUpload)];
    [self.lock unlock];
}

- (BOOL)isAsynchronous {
    return YES;
}



- (void)KVONotificationWithNotiKey:(NSString *)key state:(BOOL *)state stateValue:(BOOL)stateValue {
    [self.lock lock];
    [self willChangeValueForKey:key];
    *state = stateValue;
    [self didChangeValueForKey:key];
    [self.lock unlock];
}

- (void)runSelector:(SEL)selecotr {
    [self performSelector:selecotr
                 onThread:[[self class] operationThread]
               withObject:nil
            waitUntilDone:NO
                    modes:@[NSRunLoopCommonModes]];
}
@end
