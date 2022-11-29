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

#endif /* EchoMacro_h */
