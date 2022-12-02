//
//  NSData+EO.m
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/12/2.
//

#import "NSData+EO.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSData (EO)

- (NSString*)echo_MD5 {
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, (int)self.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
