//
//  CONST.h
//  ParkingDataCollection
//
//  Created by hama on 14-7-10.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import "DES3Util.h"

#define DBName @"wparking.sqlite"
#define PSERVER_URL @"http://115.28.158.2:8080/xiaop/"
#define NETCON_RESULT @"result"

#if NS_BLOCKS_AVAILABLE
typedef void (^ModelSuccessBlock)(NSArray *array);
typedef void (^ModelFailedBlock)(NSString* strMsg);
#endif

typedef NS_ENUM(NSInteger, TimeResultsType) {
    //返回类型
    TimeResultsTypeAll = 1,
    TimeResultsTypeMonth = 2,
    TimeResultsTypeDay = 3,
};


enum {
    
    海淀区      = 1,
    
    朝阳区      = 2,
    
    丰台区      = 3,
    
    东城区      =4,
    西城区      =5,
    宣武区      =6,
    崇文区      =7,
    石景山区    =8,
    大兴区      =9,
    通州区      =10,
    昌平区      = 11,
    近郊       =12
   
    
}; typedef NSInteger DistrictInBeiJing;

enum {
    
    卢湾区=1,
    徐汇区=2,
    静安区=3,
    长宁区=4,
    闵行区=5,
    浦东新区=6,
    黄浦区=7,
    普陀区=8,
    闸北区=9,
    虹口区=10,
    杨浦区=11,
    宝山区=12
    
}; typedef NSInteger DistrictInShangHai;

enum {
    
    天河区=1,
    越秀区=2,
    海珠区=3,
    荔湾区=4,
    白云区=5,
    番禺区=6,
    
    
}; typedef NSInteger DistrictInGuangZhou;


enum {
    
    福田区=1,
    罗湖区=2,
    南山区=3,
    宝安区=4,
    龙岗区=5
    
}; typedef NSInteger DistrictInShenZhen;