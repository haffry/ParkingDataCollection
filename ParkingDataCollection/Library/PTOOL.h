//
//  PTOOL.h
//  RVNParking
//
//  Created by 史奕鹏 on 14-4-3.
//  Copyright (c) 2014年 xiaowei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTOOL : NSObject

///获取屏幕分辨率
enum {
    // iPhone 1,3,3GS 标准分辨率(320x480px)
    UIDevice_iPhoneStandardRes      = 1,
    // iPhone 4,4S 高清分辨率(640x960px)
    UIDevice_iPhoneHiRes            = 2,
    // iPhone 5 高清分辨率(640x1136px)
    UIDevice_iPhoneTallerHiRes      = 3,
    // iPad 1,2 标准分辨率(1024x768px)
    UIDevice_iPadStandardRes        = 4,
    // iPad 3 High Resolution(2048x1536px)
    UIDevice_iPadHiRes              = 5
}; typedef NSUInteger UIDeviceResolution;

+ (UIColor *) colorFromHexRGB:(NSString *) inColorString;

+ (BOOL) getNetworkStatus;

+ (BOOL) rangeOfString:(NSString *)strOverall :(NSString*)strJudge;

+ (BOOL) isBlankStr:(NSString *) str;

+ (UIDeviceResolution) currentResolution;

+ (int) calculateTextNumber:(NSString *) strText;

+ (NSString *) JSONToString:(id)JSONObc;

+ (id) stringToJSON:(NSString *)JSONStr;

+ (NSString *)replaceAllShortLine:(NSString *)str;

+ (NSString *)replaceAllBlank:(NSString *)str;

+ (NSString *)transferToPhoneStyle:(NSString *)phoneNum;

+ (CGFloat)getTextWidthWithText:(NSString*)text fontSize:(CGFloat)size;



+ (NSString *)moneyFormat:(float)money;

+ (NSString *)moneyFormatNotSymbol:(float)money;

+ (NSObject *)objectForPath:(NSString *)jsonXPath container: (NSObject*) currentNode;

+ (NSString *)getTimeRangeWidthStartTime:(NSNumber *)startTimeNum endTime:(NSNumber *)endTimeStr resultsType:(TimeResultsType)resultType;

+ (NSString *)getTimeMonthWidthNumber:(NSNumber *) strNum;

+ (NSString *)getTimeWidthNumber:(NSNumber *) strNum;

+ (id)getValueFromUserDefaultsWithKey:(NSString *)key;

+ (void)saveToUserDefaultsWithValue:(id)value key:(NSString *)key;

+ (void)deleteFromUserDefaultsWithKey:(NSString *)key;
+ (NSString *)getTimeFormatterMAndD:(NSNumber *) strNum;
+ (NSString *)getTimeHourWidthNumber:(NSNumber *) strNum;

+ (void)removeUserFromUserDefaults;

+ (NSString *)NumberToLong:(NSNumber *)num;
+(NSString *) compareCurrentTime:(NSDate*) compareDate;
@end

@interface NSObject (TranslateToDictionary)

- (NSDictionary *) toDictionary;
- (NSObject *) toObject:(NSDictionary *)dic;
@end
