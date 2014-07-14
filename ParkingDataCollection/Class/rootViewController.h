//
//  rootViewController.h
//  ParkingDataCollection
//
//  Created by hama on 14-7-8.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface rootViewController : UIViewController<BMKMapViewDelegate,BMKGeoCodeSearchDelegate>{
    BMKMapView* _mapView;
    BMKPointAnnotation* _annotation;
    BMKPinAnnotationView *newAnnotationView;
    
    UIButton* startBtn;
    UIButton* stopBtn;
    BMKLocationService* _locService;
    
    CLLocationCoordinate2D userCoor;
    BOOL isRegion;
    BMKGeoCodeSearch* _geocodesearch;
}
@property (weak, nonatomic) IBOutlet UIView *rootView;

@property (weak, nonatomic) IBOutlet UIView *commitBtnView;
-(void)startLocation:(id)sender;
@end
