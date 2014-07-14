//
//  PTOOL.m
//  RVNParking
//
//  Created by 史奕鹏 on 14-4-3.
//  Copyright (c) 2014年 xiaowei. All rights reserved.
//

#import "PTOOL.h"
#import "Reachability.h"
#import "SBJSON.h"
#import <objc/message.h>  

@implementation PTOOL



+(NSString *) compareCurrentTime:(NSDate*) compareDate
//
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分前",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小前",temp];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    
    return  result;
}


+(NSString *)NumberToLong:(NSNumber *)num{
    
    char s[40];
    sprintf(s,"%lf",num.doubleValue/1000);
    long tmp=atol(s);
    return [NSString stringWithFormat:@"%ld",tmp];
}

+(void)removeUserFromUserDefaults{
    
    [PTOOL deleteFromUserDefaultsWithKey:@"userInfo"];
    
}


+(void)saveToUserDefaultsWithValue:(id)value key:(NSString *)key{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:value forKey:key];
    [userDefault synchronize];
}

+(id)getValueFromUserDefaultsWithKey:(NSString *)key{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:key];
    
}
+(void)deleteFromUserDefaultsWithKey:(NSString *)key{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:key];
    [userDefault synchronize];
    
}


+ (NSString *)getTimeWidthNumber:(NSNumber *) strNum{

    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:strNum.doubleValue/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];

    return [dateFormatter stringFromDate:confromTimesp];;
}

+ (NSString *)getTimeFormatterMAndD:(NSNumber *) strNum{
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:strNum.doubleValue/1000];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:confromTimesp];
    
    NSInteger year = [components year];
    
    NSInteger day = [components day];
    
    NSInteger month= [components month];
    
    //    NSInteger endTimeHour = [components hour];
    //
    //    NSInteger endTimeMin = [components minute];
    return [NSString stringWithFormat:@"%d-%d-%d",year,month,day];
}
+ (NSString *)getTimeMonthWidthNumber:(NSNumber *) strNum{
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:strNum.doubleValue/1000];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:confromTimesp];
    
    
    NSInteger day = [components day];
    
    NSInteger month= [components month];
    
//    NSInteger endTimeHour = [components hour];
//    
//    NSInteger endTimeMin = [components minute];
    return [NSString stringWithFormat:@"%d/%d",month,day];
}

+ (NSString *)getTimeHourWidthNumber:(NSNumber *) strNum{
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:strNum.doubleValue/1000];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:confromTimesp];
    
//    NSInteger day = [components day];
//    
//    NSInteger month= [components month];
    
    NSInteger hour = [components hour];

    NSInteger min = [components minute];
    return [NSString stringWithFormat:@"%d:%d",hour,min];
}

+ (NSString *)getTimeRangeWidthStartTime:(NSNumber *)startTimeNum endTime:(NSNumber *)endTimeStr resultsType:(TimeResultsType)resultType{
    
    NSDate * startTime = [NSDate dateWithTimeIntervalSince1970:startTimeNum.doubleValue/1000];

    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:endTimeStr.doubleValue/1000];
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *startTimeComp  = [calendar components:unitFlags fromDate:startTime];
    NSDateComponents* endTimeComp = [calendar components:unitFlags fromDate:endTime];
    
    BOOL isSameDay = [startTimeComp day]   == [endTimeComp day]   &&
                     [startTimeComp month] == [endTimeComp month] &&
                     [startTimeComp year]  == [endTimeComp year];
    
    
    NSInteger startTimeMonth= [startTimeComp month];
    NSInteger startTimeDay = [startTimeComp day];
    NSInteger startTimeHour = [startTimeComp hour];
    NSInteger startTimeMin = [startTimeComp minute];
    
    NSInteger endTimeMonth= [endTimeComp month];
    NSInteger endTimeDay = [endTimeComp day];
    NSInteger endTimeHour = [endTimeComp hour];
    NSInteger endTimeMin = [endTimeComp minute];
    
    if (resultType == TimeResultsTypeAll) {
        if (isSameDay) {
            
            return [NSString stringWithFormat:@"%d-%d %d:%d-%d:%d",startTimeMonth,startTimeDay,startTimeHour,startTimeMin,endTimeHour,endTimeMin];
        }else {
            
            
            return [NSString stringWithFormat:@"%d-%d %d:%d-%d-%d %d:%d",startTimeMonth,startTimeDay,startTimeHour,startTimeMin,endTimeMonth,endTimeDay,endTimeHour,endTimeMin];
        }
    }else if (resultType == TimeResultsTypeMonth) {
        
        return [NSString stringWithFormat:@"%d/%d-%d/%d",startTimeMonth,startTimeDay,endTimeMonth,endTimeDay];
        
    }else if (resultType == TimeResultsTypeDay){
        
        if([endTimeStr intValue]  == 0){
            
            return [NSString stringWithFormat:@"%d:%d",startTimeHour,startTimeMin];
        }
        return [NSString stringWithFormat:@"%d:%d-%d:%d",startTimeHour,startTimeMin,endTimeHour,endTimeMin];
    }
    return nil;
}

+ (NSObject *)objectForPath:(NSString *)jsonXPath container: (NSObject*) currentNode {
    //要处理的数据为空直接返回
    if (currentNode == nil) {
        return nil;
    }
    else if([jsonXPath length]==0) {
        return currentNode;
    }
    
    //如果不是数组和字典直接返回
    if(![currentNode isKindOfClass:[NSDictionary class]] && ![currentNode isKindOfClass:[NSArray class]]) {
        return currentNode;
    }
    
    //去掉第一个/
    if ([jsonXPath hasPrefix:@"/"]) {
        jsonXPath = [jsonXPath substringFromIndex:1];
    }
    
    //以/拆分剩下的子串,取得结果中的第一项
    NSString *currentKey = [[jsonXPath componentsSeparatedByString:@"/"] objectAtIndex:0];
    
    //下一级节点
    NSObject *nextNode;
    //如果是字典，则获得currentKey对应的值
    if ([currentNode isKindOfClass:[NSDictionary class]]) {
        NSDictionary *currentDict = (NSDictionary *) currentNode;
        nextNode = [currentDict objectForKey:currentKey];
    }
    //如果是数组则currentKey必须为数字，强性要求,即要获得数组的第几项
    else if ([currentNode isKindOfClass:[NSArray class]]) {
        
        NSArray * currentArray = (NSArray *) currentNode;
        nextNode = [currentArray objectAtIndex:[currentKey integerValue]];
    }
    
    // 从jsonXPath中移除当前的currentKey
    NSString * nextXPath = [jsonXPath stringByReplacingCharactersInRange:NSMakeRange(0, [currentKey length]) withString:@""];
    
    //用新的nextXPath处理新的节点
    return [self objectForPath:nextXPath container: nextNode];
    
}


+ (NSString *) moneyFormat:(float)money{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"¥###,###,###,###,##0.00;"];
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:money]];
}

+ (NSString *) moneyFormatNotSymbol:(float)money{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,###,###,###,##0.00;"];
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:money]];
}

#pragma mark 获取当前字体总宽度
+ (CGFloat)getTextWidthWithText:(NSString*)text fontSize:(CGFloat)fSize
{
    UIFont *font = [UIFont systemFontOfSize:fSize];
    CGSize size = CGSizeMake(1000, 20000.0f);
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size =[text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine attributes:tdic context:nil].size;
#else
    size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
#endif
    
    return size.width;
}


#pragma mark 颜色转换
+ (UIColor *) colorFromHexRGB:(NSString *) inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; 
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode);
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

#pragma mark 检查网路链接
+ (BOOL)getNetworkStatus
{
    
    NSLog(@"提示：开始检测网络连接......\n");
    
    
    Reachability *r = [Reachability reachabilityWithHostName:PSERVER_URL];
    
    switch ([r currentReachabilityStatus])
    {
        case NotReachable:
        {
            printf("提示:没有网络链接......\n");
            return NO;
        }
        case ReachableViaWWAN:
        {
            printf("提示:使用3G网络......\n");
            return YES;
        }
        case ReachableViaWiFi:
        {
            printf("提示:使用Wifi网络......\n");
            return YES;
        }
        default:
        {
            printf("提示:使用其它网络......\n");
            return YES;
        }
    }
    
    return YES;
}

#pragma mark 判读字符串是否包含
+(BOOL)rangeOfString:(NSString *)strOverall :(NSString*)strJudge{
    
    NSRange range = [strOverall rangeOfString:strJudge];
    if (range.location == NSNotFound)
    {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark 判读字符串是否为空
+ (BOOL) isBlankStr:(NSString *)str {
    
    if (str == nil || str == NULL) {
        
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        
        return YES;
        
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        
        return YES;
    }
    if ([str isEqualToString:@"(null)"]) {
        
        return YES;
        
    }
    if ([str isEqualToString:@"<null>"]) {
        
        return YES;
        
    }
    return NO;
}


+(NSString *)transferToPhoneStyle:(NSString *)phoneNum{
    NSMutableString *phone = [NSMutableString stringWithString:[PTOOL replaceAllShortLine:[PTOOL replaceAllBlank:phoneNum]]];
    if (phone.length > 0 && phone.length <= 3) {
        
    }else if (phone.length > 3 && phone.length <=7){
        if ([phone characterAtIndex:3] != ' ') {
            if ([phone characterAtIndex:3] == '-') {
                
                [phone replaceCharactersInRange:NSMakeRange(3, 1) withString:@" "];
                
            }else{
                
                [phone insertString:@" " atIndex:3];
                
            }
            
        }
        
    }else if(phone.length > 7){
        if ([phone characterAtIndex:3] != ' ') {
            if ([phone characterAtIndex:3] == '-') {
                
                [phone replaceCharactersInRange:NSMakeRange(3, 1) withString:@" "];
                
            }else{
                
                [phone insertString:@" " atIndex:3];
                
            }
        }
        if ([phone characterAtIndex:8] != ' ') {
            if ([phone characterAtIndex:8] == '-') {
                
                [phone replaceCharactersInRange:NSMakeRange(8, 1) withString:@" "];
                
            }else{
                
                [phone insertString:@" " atIndex:8];
                
            }
        }
    }
    
    return phone;
}

+ (NSString *)replaceAllShortLine:(NSString *)str{
    
    return [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
}
+ (NSString *)replaceAllBlank:(NSString *)str{
    
    return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}
#pragma mark 判断设备屏幕分辨率
+ (UIDeviceResolution) currentResolution {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
                return UIDevice_iPhoneStandardRes;
            return (result.height > 960 ? UIDevice_iPhoneTallerHiRes : UIDevice_iPhoneHiRes);
        } else
            return UIDevice_iPhoneStandardRes;
    } else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
}

+ (NSMutableURLRequest *)imageRequestWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad; // this will make sure the request always returns the cached image
    request.HTTPShouldHandleCookies = NO;
    request.HTTPShouldUsePipelining = YES;
    [request addValue:@ "image/*" forHTTPHeaderField:@ "Accept" ];
    
    return request;
}


#pragma mark 获取文字个数
+ (int) calculateTextNumber:(NSString *)strText
{
    float number = 0.0;
    for (int index = 0; index < [strText length]; index++)
    {
        NSString *protoText = [strText substringToIndex:[strText length] - index];
        NSString *toChangetext = [strText substringToIndex:[strText length] -1 -index];
        NSString *charater;
        if ([toChangetext length]==0)
        {
            charater = protoText;
        }
        else
        {
            NSRange range = [strText rangeOfString:toChangetext];
            charater = [protoText stringByReplacingCharactersInRange:range withString:@""];
            
        }
        
        if ([charater lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            number++;
        }
        else
        {
            number = number+0.5;
        }
    }
    return ceil(number);
}

#pragma mark  JSON和String相互转换
+ (NSString *) JSONToString:(id)JSONObc{
    
    SBJSON *sbJSON = [[SBJSON alloc] init];
    NSError *error;
    NSString *jsonString = [sbJSON stringWithObject:JSONObc error:&error];
    if (error) {
        NSLog(@"JSON转化出错:%@",error);
        return nil;
    }
    return jsonString;
    
}
+ (id) stringToJSON:(NSString *)JSONStr{
    
    SBJSON *sbJSON = [[SBJSON alloc] init];
    NSError *error;
    id obj = [sbJSON objectWithString:JSONStr error:&error];
    if (error) {
        NSLog(@"JSON转化出错:%@",error);
        return nil;
    }
    return obj;
    
}

+ (NSString *)generateUuidString{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    CFRelease(uuid);
    
    return uuidString;
}
//CGRect frame = {{0, 0}, {320, 20}};
//UIWindow* wd = [[UIWindow alloc] initWithFrame:frame];
//[wd setBackgroundColor:[UIColor clearColor]];
//[wd setWindowLevel:UIWindowLevelStatusBar];
//frame = CGRectMake(100, 0, 30, 20);
//UIImageView* img = [[UIImageView alloc] initWithFrame:frame];
//[img setContentMode:UIViewContentModeCenter];
//[img setImage:[UIImage im   ageNamed:@"00_0103.png"]];
//[wd addSubview:img];
//[wd makeKeyAndVisible];
//
//[UIView beginAnimations:nil context:nil];
//[UIView setAnimationDuration:2];
//frame.origin.x += 150;
//[img setFrame:frame];
//[UIView commitAnimations];
@end

@implementation NSObject (TranslateToDictionary)

- (NSDictionary *)toDictionary{
    
    Class className = [self class];
    u_int count;
    objc_property_t *properties = class_copyPropertyList(className, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        
        id value =  [self valueForKey:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        if(value ==nil)
            [valueArray addObject:[NSNull null]];
        else {
            [valueArray addObject:value];
        }
    }
    
    free(properties);
    
    NSDictionary* returnDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    
    return returnDic;
}

- (NSObject *)toObject:(NSDictionary *)dic{
    
    
    Class className = [self class];
    u_int count;
    objc_property_t *properties = class_copyPropertyList(className, &count);
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        
        id value =  [dic valueForKey:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        if (value!=nil) {
            [self setValue:value forKey:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        }
        
        //        NSLog(@"%@",value);
    }
    
    free(properties);
    
    return self;
}
@end