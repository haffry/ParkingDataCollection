//
//  rootViewController.m
//  ParkingDataCollection
//
//  Created by hama on 14-7-8.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import "rootViewController.h"

@implementation rootViewController

-(void)startLocation:(id)sender{
    NSLog(@"进入普通定位态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

//停止定位
-(void)stopLocation:(id)sender
{
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
    
    _annotation = [[BMKPointAnnotation alloc]init];
    _annotation.coordinate = userCoor;
    _annotation.title = @"收集数据";
    [_mapView addAnnotation:_annotation];
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = userCoor;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isRegion=YES;
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, self.rootView.bounds.size.height)];
    [_mapView setMapType:BMKMapTypeStandard];
    [self.rootView addSubview:_mapView];
    
    startBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    startBtn.backgroundColor=[UIColor grayColor];
    startBtn.frame=CGRectMake(10, 10, 104, 24);
    [startBtn setTitle:@"开始定位"  forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView addSubview:startBtn];
    
    stopBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopBtn.backgroundColor=[UIColor grayColor];
    stopBtn.frame=CGRectMake(200, 10, 104, 24);
    [stopBtn setTitle:@"停止定位"  forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stopLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView addSubview:stopBtn];
    
    _locService = [[BMKLocationService alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    [self.rootView bringSubviewToFront:self.commitBtnView];
}
-(void)viewDidAppear:(BOOL)animated{
    // 添加一个PointAnnotation
    
    
    
}
-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = (id)self;
    _geocodesearch.delegate=self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    [newAnnotationView removeFromSuperview];
    [_mapView removeAnnotation:_annotation];
}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        UIImage* img=[UIImage imageNamed:@"pin_green.png"];
        newAnnotationView.image = img;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
    [self performSegueWithIdentifier:@"pushDetailsView" sender:self];
}

#pragma 定位回调
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{
	NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
    if (userLocation.location.coordinate.latitude && isRegion) {
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.002f, 0));
        //调整后适合当前地图窗口显示的经纬度范围
        BMKCoordinateRegion adjusteRegion = [_mapView regionThatFits:viewRegion];
        // *设定当前地图的显示范围
        [_mapView setRegion:adjusteRegion animated:YES];
        isRegion=NO;
    }
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    if (userLocation.location) {
        userCoor=userLocation.location.coordinate;
        
        //[self stopLocation];
    }
    
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
    
}
    
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    BMKReverseGeoCodeResult* _result=result;
    NSLog(@"_result:%@",  _result.address);
    NSLog(@"_result:%@",  _result.addressDetail.streetName);
    NSLog(@"_result:%@",  _result.addressDetail.streetNumber);
    NSLog(@"_result:%@",  _result.addressDetail.city);
    NSLog(@"_result:%@",  _result.addressDetail.province);
    NSLog(@"_result:%@",  _result.addressDetail.district);
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //    NSLog(@">>>>>>>>>>%@",segue.identifier);
    //    NSLog(@">>>>>>>>>>%@",segue.sourceViewController);
    //    NSLog(@">>>>>>>>>>%@",segue.destinationViewController);
    if([segue.identifier isEqualToString:@"pushDetailsView"])
    {
        //PassWordConfirmViewController *passWordConfirmViewController=segue.destinationViewController;
        
    }
}
@end
