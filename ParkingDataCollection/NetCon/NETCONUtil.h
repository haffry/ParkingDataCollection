//
//  NETCONUtil.h
//  RVNParking
//
//  Created by 史奕鹏 on 14-4-3.
//  Copyright (c) 2014年 xiaowei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


#if NS_BLOCKS_AVAILABLE
typedef void (^NETCONUtilSuccessBlock)(NSDictionary *dic);
typedef void (^NETCONUtilFailedBlock)(NSString* strMsg);
#endif
////通讯完成后实现得协议方法
//@protocol NETCONUtilDelegate <NSObject>
//
//@optional
//-(void)connectionDidFinished:(id)resultObject;
//
//
//@end

@interface NETCONUtil : NSObject

@property (strong, nonatomic)AFHTTPRequestOperationManager *manager;

+(instancetype)defaultConnection;


//扫街信息数据获取
-(void)getAllParkInfoCacheList:(NSString *)cityName
                         success:(NETCONUtilSuccessBlock)successBlock
                          failed:(NETCONUtilFailedBlock)failedBlock;

//扫街信息数据采集------批量入库
-(void)catchParkInfoList2db:(NSArray *)catchObjListJson
                         success:(NETCONUtilSuccessBlock)successBlock
                          failed:(NETCONUtilFailedBlock)failedBlock;
                         
//扫街信息数据采集------单条入库
-(void)catchParkInfo2db:(NSString *)catchObjJson
                         success:(NETCONUtilSuccessBlock)successBlock
                          failed:(NETCONUtilFailedBlock)failedBlock;



-(void)excuteRequestWithUrl:(NSString *)url parameters:(id)parameter
                    success:(NETCONUtilSuccessBlock)successBlock
                     failed:(NETCONUtilFailedBlock)failedBlock;
//获得扫街信息数据json结构
-(NSString*)getParkinfoCatchObjJsonWithObj:(id)_obj;

//获得扫街信息数据json结构列表
-(NSArray*)getParkinfoListCatchObjJsonWithObj:(NSArray*)_array;
@end


