//
//  parkInfoObjectCache.h
//  ParkingDataCollection
//
//  Created by hama on 14-7-11.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STDbObject.h"
#import "parkInfoCache.h"
#import "parkingAccsesImageInfoCache.h"

@interface parkInfoObjectCache : STDbObject
@property(strong, nonatomic)NSMutableArray* imgList;
@property(strong,nonatomic)parkInfoCache* parkInfo;
@end
