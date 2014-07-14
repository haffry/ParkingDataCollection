//
//  DES3Util.h
//  RVNParking
//
//  Created by apple on 14-5-6.
//  Copyright (c) 2014年 xiaowei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES3Util : NSObject
// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;
@end
