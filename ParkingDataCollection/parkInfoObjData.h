//
//  parkInfoObjData.h
//  ParkingDataCollection
//
//  Created by hama on 14-7-11.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "parkInfoObjectCache.h"
@interface parkInfoObjData :NSObject



//扫街信息数据获取
+(void)getAllParkInfoCacheList:(NSString *)cityName
                       success:(ModelSuccessBlock)successBlock
                        failed:(ModelFailedBlock)failedBlock;

//扫街信息数据采集------批量入库
+(void)catchParkInfoList2db:(NSArray *)catchObjListJson
                    success:(ModelSuccessBlock)successBlock
                     failed:(ModelFailedBlock)failedBlock;

//扫街信息数据采集------单条入库
+(void)catchParkInfo2db:(NSString *)catchObjJson
                success:(ModelSuccessBlock)successBlock
                 failed:(ModelFailedBlock)failedBlock;



@end
