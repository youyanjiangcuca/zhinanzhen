//
//  ViewController.m
//  zhuangxiu
//
//  Created by 家乐淘 on 2019/12/30.
//  Copyright © 2019 zhuangxiu. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <MapKit/MapKit.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,CLLocationManagerDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) WKWebViewConfiguration *config;
@property (nonatomic, strong) NSMutableArray *mapArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
//经度
@property (nonatomic, assign) float currLongitude;
//纬度
@property (nonatomic, assign) float currLatitude;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWKWebView];
    
    [self initLocationManager];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"定位" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor orangeColor]];
    btn.frame = CGRectMake(50, 100, 100, 50);
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"导航" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setBackgroundColor:[UIColor orangeColor]];
    btn2.frame = CGRectMake(200, 100, 100, 50);
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 setTitle:@"分享" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(showShareSDkAlert) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setBackgroundColor:[UIColor orangeColor]];
    btn3.frame = CGRectMake(300, 100, 100, 50);
    [self.view addSubview:btn3];
}
-(void)showAlert{
    NSString *message = [NSString stringWithFormat:@"经度为:%f\n纬度为:%f",self.currLongitude,self.currLatitude];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (void)initWKWebView {
    if (!_wkWebView) {
        //初始化一个WKWebViewConfiguration对象
        _config = [WKWebViewConfiguration new];
        //初始化偏好设置属性：preferences
        _config.preferences = [WKPreferences new];
        //允许视频播放
        _config.allowsAirPlayForMediaPlayback = YES;
        // 允许在线播放
        _config.allowsInlineMediaPlayback = YES;
        //The minimum font size in points default is 0;
        _config.preferences.minimumFontSize = 10;
        //是否支持JavaScript
        _config.preferences.javaScriptEnabled = YES;
        //不通过用户交互，是否可以打开窗口
        _config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        //JS管理对象
        _config.userContentController = [[WKUserContentController alloc] init];
        [_config.userContentController addScriptMessageHandler:self name:@"showMessage"];

        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 [UIScreen mainScreen].bounds.size.width,
                                                                 [UIScreen mainScreen].bounds.size.height)
                                        configuration:_config];
        
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        
        
        //https://www.zxcompass.com   http://192.168.50.213:7210/newTest/NewFile.html
        NSURL *url = [NSURL URLWithString:@"https://www.zxcompass.com"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //request.HTTPMethod = @"GET";
        //http://tgo.
        //[request setValue:@"cqjlt.net" forHTTPHeaderField:@"Referer"];
        [_wkWebView loadRequest:request];
        
        [self.view addSubview:_wkWebView];
        
    }
    
}
-(void)initLocationManager{
    if ([CLLocationManager locationServicesEnabled]) {
        //判断定位操作是否被允许
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10.0f;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }
    else{
        //不能定位用户的位置的情况再次进行判断，并给与用户提示
        //提醒用户检查当前的网络情况//2提醒用户打开定位开关
        NSLog(@"当前信号弱，无法获取定位");
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *currLocation = [locations lastObject];
    self.currLatitude = currLocation.coordinate.latitude;
    self.currLongitude = currLocation.coordinate.longitude;
    NSLog(@"经度=%f  纬度=%f",currLocation.coordinate.latitude,currLocation.coordinate.longitude);
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设置中打开定位" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"打开定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:ok];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    NSLog(@"%@",message.body);
}
- (void)getLocationInfo {
    
    NSString* paramString =@"我是 OC 调用 JS";

    NSString* jsStr = [NSString stringWithFormat:@"shareResult('%@')",paramString];

    [_wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@...%@",result,error);
    }];


}
-(void)btnClick{
    _mapArray = [NSMutableArray arrayWithObject:@{@"type":@"苹果地图"}];
    BOOL status = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
    NSLog(@"百度地图的状态为：%d",status);
    BOOL status2 = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
    NSLog(@"高德地图的状态为：%d",status2);
    BOOL status3 = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
    NSLog(@"谷歌地图的状态为：%d",status3);
    if (status == 1) {
        [_mapArray addObject:@{@"type":@"百度地图",@"url":@"baidumap://"}];
    }
    if (status2 == 1) {
        [_mapArray addObject:@{@"type":@"高德地图",@"url":@"iosamap://"}];
    }
    if (status3 == 1) {
        [_mapArray addObject:@{@"type":@"谷歌地图",@"url":@"comgooglemaps://"}];
    }
    [self showMapAlert];
}
-(void)showMapAlert{
    
    UIAlertController *alertSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for ( int i = 0; i<_mapArray.count; i++) {
        NSDictionary *dic = _mapArray[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:dic[@"type"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self jumpToMap:dic[@"type"]];
        }];
        [alertSheet addAction:action];
        
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertSheet addAction:cancelAction];
    [self presentViewController:alertSheet animated:YES completion:nil];
}
-(void)jumpToMap:(NSString *)string{
    if ([string isEqualToString:@"苹果地图"]) {
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(106.5, 29.5);
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:loc addressDictionary:nil]];
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                       MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
    else if ([string isEqualToString:@"高德地图"]){
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",@"装修指南针",@"zhinanzhen",106.5, 29.5] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else if ([string isEqualToString:@"百度地图"]){
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",106.5, 29.5] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else if ([string isEqualToString:@"谷歌地图"]){
        NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"装修指南针",@"zhinanzhen",106.5, 29.5] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}
-(void)showShareSDkAlert{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[[NSBundle mainBundle] pathForResource:@"D45" ofType:@"png"]];
    [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                         images:imageArray
                                            url:[NSURL URLWithString:@"https://www.mob.com"]
                                          title:@"分享标题"
                                           type:SSDKContentTypeAuto];

    [ShareSDK showShareActionSheet:nil //(第一个参数要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，在ipad中要想弹出我们的分享菜单，这个参数必须要传值，可以传自己分享按钮的对象，或者可以创建一个小的view对象去传，传值与否不影响iphone显示)
                           customItems:nil
                           shareParams:shareParams
                    sheetConfiguration:nil
                        onStateChanged:^(SSDKResponseState state,
                                         SSDKPlatformType platformType,
                                         NSDictionary *userData,
                                         SSDKContentEntity *contentEntity,
                                         NSError *error,
                                         BOOL end)
         {

             switch (state) {

                 case SSDKResponseStateSuccess:
                 NSLog(@"成功");//成功
                     break;
                 case SSDKResponseStateFail:
                      {
                 NSLog(@"--%@",error.description);
                    //失败
                    break;
               }
                 case SSDKResponseStateCancel:
                     break;
                 default:
                 break;
             }
         }];
}
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    return [UIScreen mainScreen].bounds.size;
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//
//}

@end
