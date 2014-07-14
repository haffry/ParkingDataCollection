//
//  parkInfoCache.h
//  ParkingDataCollection
//
//  Created by hama on 14-7-10.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STDbObject.h"

@interface parkInfoCache : STDbObject
@property   (assign, nonatomic) BOOL         isCommit;         //是否被提交
@property   (assign, nonatomic) NSInteger    *infoId;         //停车场Id
@property   (strong, nonatomic) NSString    *cityId;      //城市代码(1北京、2上海、3广州、4深圳)
@property   (strong, nonatomic) NSString    *checkInId;      //录入者ID
@property   (strong, nonatomic) NSString    *parkPersonal;        //车主
@property   (strong, nonatomic) NSString    * districtId;        //区域代码
@property   (strong, nonatomic) NSString    *parkName;        //停车场名称
@property   (strong, nonatomic) NSString    *mapLang;         //经度
@property   (strong, nonatomic) NSString      * parkAddress;       //具体位置信息
@property   (strong, nonatomic) NSString        * parkNum;        //车位数
@property   (strong, nonatomic) NSString       *parkType;     //停车场类型（0地上、1地下、2露天、3地上+地下）
@property   (strong, nonatomic) NSString      * mapLat;      //纬度
@property   (assign, nonatomic) NSString    *checkInName;         //录入者姓名
@property   (assign, nonatomic) NSString    *contactPhone;         //联系电话
@property   (assign, nonatomic) NSString    *parkDescript;         //详情描述
@end
