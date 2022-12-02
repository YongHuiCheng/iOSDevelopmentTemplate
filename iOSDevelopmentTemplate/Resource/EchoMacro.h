//
//  EchoMacro.h
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/11/29.
//

#ifndef EchoMacro_h
#define EchoMacro_h



#define EO_WIDTH  [UIScreen mainScreen].bounds.size.width
#define EO_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define EOSizeScale ((CIO_SCREEN_HEIGHT > 667) ? CIO_SCREEN_HEIGHT/667 : 1)


#define EOWeakSelf __weak typeof(self) weakSelf = self;


//字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
//字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)
//是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))


// 主线程GCD
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

// 单利宏
// .h头文件
#define EOSingletonH  +(instancetype)sharedInstance;

// 1.m文件
#define EOSingletonM \
 \
static id _instance; \
 \
+(instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{  \
        _instance=[super allocWithZone:zone]; \
    }); \
    return _instance; \
} \
 \
+(instancetype)sharedInstance \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance=[[self alloc]init]; \
    }); \
    return _instance; \
} \
-(id)copyWithZone:(NSZone *)zone \
{ \
    return _instance; \
}


#endif /* EchoMacro_h */
