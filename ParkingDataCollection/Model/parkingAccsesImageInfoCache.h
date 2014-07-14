//
//  parkingAccsesImageInfoCache.h
//  ParkingDataCollection
//
//  Created by hama on 14-7-10.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STDbObject.h"

@interface parkingAccsesImageInfoCache : STDbObject
@property   (assign, nonatomic) BOOL         isCommit;         //是否被提交
@property   (assign, nonatomic) NSInteger    *imgId;         //停车场Id
@property   (strong, nonatomic) NSString    *mapLang;      //图片所在位置经度
@property   (strong, nonatomic) NSString    *imgPath;      //图片路径
@property   (strong, nonatomic) NSString    *imgFile;        //车主
@property   (strong, nonatomic) NSString    * imgThumb;        //图片缩略图路径
@property   (assign, nonatomic) NSInteger    *infoId;        //关联的停车场扫街信息ID
@property   (strong, nonatomic) NSString    *type;         //图片类型（0:地标图片，1:入口图片）
@property   (strong, nonatomic) NSString      * mapLat;       //图片所在位置纬度
@property   (strong, nonatomic) NSString        * imgDesc;        //图片说明
@property   (assign, nonatomic) NSString    *isShow;         //是否用于显示(0:不显示；1：显示)

@end
