//
//  parkInfoObjData.m
//  ParkingDataCollection
//
//  Created by hama on 14-7-11.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import "parkInfoObjData.h"
#import "NETCONUtil.h"

@implementation parkInfoObjData

+(NSArray *)prepareData:(NSDictionary *)dic{
    NSMutableArray *parkInfoList=[[NSMutableArray alloc] init];
    
    
    if ([[dic objectForKey:NETCON_RESULT] isEqualToString:@"1"]) {
        
        NSArray *parkInfoDataList=[dic objectForKey:@"list"];
        
        if ([parkInfoDataList count] != 0) {
            
            for (NSDictionary *dict in parkInfoDataList) {
                parkInfoObjectCache* parkInfoObject=[[parkInfoObjectCache alloc] init];
                if ([dict objectForKey:@"imgList"]) {
                    NSArray* imgArray=[dict objectForKey:@"imgList"];
                    for (NSDictionary *imgDic in imgArray) {
                        parkingAccsesImageInfoCache* imgInfo=[[parkingAccsesImageInfoCache alloc] init];
                        [imgInfo toObject:imgDic];
                         NSMutableArray *imgList=[[NSMutableArray alloc] init];
                        [imgList addObject:imgInfo];
                        parkInfoObject.imgList=imgList;
                    }
                }else if([dict objectForKey:@"catchInfo"]){
                    parkInfoCache* parkInfo=[[parkInfoCache alloc] init];
                    [parkInfo toObject:dict];
                    parkInfoObject.parkInfo=parkInfo;
                }
                [parkInfoList addObject:parkInfoObject];
            }
        }
    }
    
    return parkInfoList;
}

+(void)getAllParkInfoCacheList:(NSString *)cityName
                       success:(ModelSuccessBlock)successBlock
                        failed:(ModelFailedBlock)failedBlock{
     NETCONUtil *netConnection = [NETCONUtil defaultConnection];
    
    [netConnection getAllParkInfoCacheList:cityName success:^(NSDictionary *dic) {
        NSArray* array=[self prepareData:dic];
        successBlock(array);
    } failed:^(NSString *strMsg) {
        failedBlock(strMsg);
    }];
}

//扫街信息数据采集------批量入库
+(void)catchParkInfoList2db:(NSArray *)catchObjListJson
                    success:(ModelSuccessBlock)successBlock
                     failed:(ModelFailedBlock)failedBlock{
    NETCONUtil *netConnection = [NETCONUtil defaultConnection];
    
    [netConnection catchParkInfoList2db:catchObjListJson success:^(NSDictionary *dic) {
        NSArray* array=[self prepareData:dic];
        successBlock(array);
    } failed:^(NSString *strMsg) {
        failedBlock(strMsg);
    }];

}

//扫街信息数据采集------单条入库
+(void)catchParkInfo2db:(NSString *)catchObjJson
                success:(ModelSuccessBlock)successBlock
                 failed:(ModelFailedBlock)failedBlock{
    NETCONUtil *netConnection = [NETCONUtil defaultConnection];
    
    [netConnection catchParkInfo2db:catchObjJson success:^(NSDictionary *dic) {
        NSArray* array=[self prepareData:dic];
        successBlock(array);
    } failed:^(NSString *strMsg) {
        failedBlock(strMsg);
    }];
}

+(void)commitParkInfoWithModelObj:(id)obj
                          success:(ModelSuccessBlock)successBlock
                           failed:(ModelFailedBlock)failedBlock{
    NSString* strJson=[PTOOL JSONToString:obj];
    [parkInfoObjData catchParkInfo2db:strJson
                              success:^(NSArray* array){
                                  
    }
                            failed:^(NSString* strMsg){}];
}

+(void)commitParkInfoWithModelObjList:(NSArray*)array
                          success:(ModelSuccessBlock)successBlock
                           failed:(ModelFailedBlock)failedBlock{
    NSMutableArray* jsonArray=[[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<array.count; i++) {
        NSString* strJson=[PTOOL JSONToString:[array objectAtIndex:i]];
        [jsonArray addObject:strJson];
    }
    
    [parkInfoObjData catchParkInfoList2db:jsonArray
                              success:^(NSArray* array){
                                  
                              }
                               failed:^(NSString* strMsg){}];
}
@end
