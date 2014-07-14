//
//  NETCONUtil.m
//  RVNParking
//
//  Created by 史奕鹏 on 14-4-3.
//  Copyright (c) 2014年 xiaowei. All rights reserved.
//

#import "NETCONUtil.h"

@interface NETCONUtil ()


@end

@implementation NETCONUtil

+(instancetype)defaultConnection{
    
    static  NETCONUtil *defaultConnection = nil ;
    static  dispatch_once_t onceToken;  // 锁
    dispatch_once (& onceToken, ^ {     // 最多调用一次
        defaultConnection = [[self  alloc] init];
    });
    return  defaultConnection;
    
}

-(id)init{
    
    self = [super init];
    
    if (self) {
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:PSERVER_URL]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager = manager;
        
    }
    
    return self;
    
}

-(void)excuteRequestWithUrl:(NSString *)url
                parameters:(id)parameter
                success:(NETCONUtilSuccessBlock)successBlock
                failed:(NETCONUtilFailedBlock)failedBlock;{
    
     __block NSDictionary* _dic;
    [self.manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *result = [DES3Util decrypt:resultStr];
        NSLog(@"========result=======:%@",result);
        NSString *resultDic = [PTOOL stringToJSON:result];
        NSDictionary *dic = (NSDictionary *)resultDic;
        if ([[dic objectForKey:NETCON_RESULT] isEqualToString:@"1"]){
            NSLog(@" Request Finished");
            successBlock(dic);
        }else{
            failedBlock([_dic objectForKey:@"msg"]);
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"result:%@ statusCode:%ld error:%@",[[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding],(long)operation.response.statusCode,error);
        
       
        failedBlock(@"服务器异常,请稍后在试.");
        
    }];
    
}


//扫街信息数据获取
-(void)getAllParkInfoCacheList:(NSString *)cityName
                       success:(NETCONUtilSuccessBlock)successBlock
                        failed:(NETCONUtilFailedBlock)failedBlock{
    NSString *method = @"getInfoList";
    NSString *key1 = @"cityId";
    
    NSDictionary *parameter = @{key1:[DES3Util encrypt:cityName]};
    NSString *url = [PSERVER_URL stringByAppendingFormat:@"%@",method];
    [self excuteRequestWithUrl:url parameters:parameter success:successBlock failed:failedBlock];
}

//扫街信息数据采集------批量入库
-(void)catchParkInfoList2db:(NSArray *)catchObjListJson
                    success:(NETCONUtilSuccessBlock)successBlock
                     failed:(NETCONUtilFailedBlock)failedBlock{
    NSString *method = @"catchInfoList2db";
    NSString *key1 = @"catchObjListJson";
    NSMutableArray* _array=[[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<catchObjListJson.count; i++) {
        [_array addObject:[DES3Util encrypt:[catchObjListJson objectAtIndex:i]]];
    }
    NSDictionary *parameter=[[NSDictionary alloc] initWithObjectsAndKeys:key1, _array,nil];
    NSString *url = [PSERVER_URL stringByAppendingFormat:@"%@",method];
    [self excuteRequestWithUrl:url parameters:parameter success:successBlock failed:failedBlock];
}

//扫街信息数据采集------单条入库
-(void)catchParkInfo2db:(NSString *)catchObjJson
                success:(NETCONUtilSuccessBlock)successBlock
                 failed:(NETCONUtilFailedBlock)failedBlock{
    NSString *method = @"catchInfo2db";
    NSString *key1 = @"catchObjJson";
    
    NSDictionary *parameter = @{key1:[DES3Util encrypt:catchObjJson]};
    NSString *url = [PSERVER_URL stringByAppendingFormat:@"%@",method];
    [self excuteRequestWithUrl:url parameters:parameter success:successBlock failed:failedBlock];
}

-(NSString*)getParkinfoCatchObjJsonWithObj:(id)_obj obj2:(NSArray*)_obj2{
    NSString* strJson;
    NSMutableDictionary* dic=[[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray* array=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObject:_obj forKey:@"catchInfo"], [NSDictionary dictionaryWithObject:_obj2 forKey:@"imgList"],nil];
    [dic setObject:array forKey:@"list"];
    
    strJson=[PTOOL JSONToString:dic];
    if (strJson) {
        return strJson;
    }
    return @"";
}

//获得扫街信息数据json结构列表
//-(NSArray*)getParkinfoListCatchObjJsonWithObj:(NSArray*)_array{
//    
//}
@end
