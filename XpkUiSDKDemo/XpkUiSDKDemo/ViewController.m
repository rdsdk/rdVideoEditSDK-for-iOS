//
//  ViewController.m
//  XpkUiSDKDemo
//
//  Created by emmet on 15/12/7.
//  Copyright © 2015年 XpkUiSDKDemo. All rights reserved.
//

#import "ViewController.h"

//
#import "XpkUISDK.h"//引用头文件

#import "PlayVideoController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVCaptureDevice.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <netdb.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <objc/message.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <err.h>
#include <stdio.h>
#include <netinet/in.h>
#include <string.h>

#import <Photos/Photos.h>

#define PHOTO_ALBUM_NAME @"XpkUISDKDemo"
#define VideoAverageBitRate 2.5

NSString *const APPKEY = @"27eb1f31f0f52501";
NSString *const APPSECRET = @"3ac8a8b40ce5bd5c37642978ef097731TDgMqucwJLGDvj09ws+W82FH8K5E5H6onCA01GRnpc0BSFM1ih2nXeX5aHyRfjlZY5hbwHrXlyTcH3i3cDebjS//Q++L5M30pIHb4S/4W6gGO4rIzup6ImsxgHExwqy/k/08HScy8OSkjK67JlkaS3ivejvTZpMGlst/hizafT4JkrarYi3vSBmin2i+4kKc4BuJHNAfORV3JnJi52A/nbPhbSCulMUWAC/ccw+f1a5RBWY6ZMl4VB4hpCx87tvKpF9Ctzf0XuaoNWSWlYSAyNoAp1UhM5nlEk0nf2nzScTovrt4CfR1qq5vrifqMubvSfjAT4y4jck30YFyxRnJLXAcWPKoUisUCwhelVMc2o+4s+UlIBDtsm/5rhddUoPmWRBsKllAENGsCD1oRJMeRiA0Wr/EgZ+XNu6NMC3PrQcaw/HWaM1dwT4c3o2z9yXh3zokTvDVjR5SmX0ab19YanCEy4vlfobIaJoBFbIbzlfymJGnpkfoObHN9b7qjYwA";


@interface ViewController ()<UIActionSheetDelegate,UIAlertViewDelegate,XpkUISDKDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate>
{
    UITableView             *_functionListTable;
    XpkUISDK                *_xpkSDK;
    UIView                  *_playerView;
    AVPlayerLayer           *_playPlayer;
    UIView                  *_syncContainer;
    AVPlayer                *_player;
    AVPlayerItem            *_playerItem;
    
    NSString                *_exportVideoPath;
    UIButton                *_playBtn;
    UIButton                *_savePhotosAlbumBtn;
    UIButton                *_deletedBtn;
    UIInterfaceOrientation   _deviceOrientation;
    NSMutableArray          *_functionList;
    UIButton *cameraBtn;
    
    UISwitch    *switchBtn;
    UILabel     *wizardLabel;
    UIView      *cameraSettingView;
    UIView      *camerapositionSettingView;
    UIView      *cameraModelSettingView;
    UIView      *cameraWriteToAlbumSettingView;
    UIView      *settingView;
    UIView      *editSettingView;
    UIView      *musicSettingView;
    UIView      *filterSettingView;
    
    UIButton    *fragmentEditBtn;
    UIView      *fragmentEditSettingView;
    UIView      *proportionSettingView;
    UIButton    *endPicDisabledBtn;
    UIView      *waterSettingView;
    UIView      *waterPositionView;
    UIButton    *waterSettingBtn;
    UIView       *supportFiletypeView;
    UIView       *supportDeviceOrientationView;
    UITextField  *exportVideoMaxDurationField;
    UIView       *videoMaxDurationView;
    UIButton     *videoMaxDurationBtn;
    UILabel      *exportMaxDurationSettingLabel;
    //编辑设置
    EditConfiguration  *_editConfiguration;
    CameraConfiguration *_cameraConfiguration;
    ExportConfiguration *_exportConfiguration;
    
    long int exportVideoMaxDuration;
}
@end

@implementation ViewController

// 是否支持转屏
- (BOOL)shouldAutorotate
{
    return YES;
}

// 支持的屏幕方向，此处可直接返回 UIInterfaceOrientationMask 类型
// 也可以返回多个 UIInterfaceOrientationMask 取或运算后的值
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self deviceOrientationDidChange:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self.navigationItem setHidesBackButton:YES];
    // 设置导航栏背景图片
    
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 7.0)
    {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:20];
        attributes[NSForegroundColorAttributeName] = UIColorFromRGB(0xffffff);
        
        
        self.navigationController.navigationBar.titleTextAttributes = attributes;
        
        self.navigationController.navigationBar.barTintColor=UIColorFromRGB(0x0e0e10);
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }else{
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"head_"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    self.view.backgroundColor = UIColorFromRGB(0x27262c);
    [super viewWillAppear:animated];
}

// 是否支持旋转到某个屏幕方向
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) |
            (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 200){
        if(buttonIndex == 1){
            [_xpkSDK trimVideoWithType:RDCutVideoReturnTypeTime];
        }else{
            [_xpkSDK trimVideoWithType:RDCutVideoReturnTypePath];
        }
    }
    
    if(alertView.tag == 2000){
        if (buttonIndex == 0) {
            [self enterSystemSetting];
        }
        else{
            
        }
    }
}

-(void)deviceOrientationDidChange:(NSObject*)sender{
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
        if(self.navigationController.visibleViewController == self){
            NSLog(@"横向");
            self.navigationController.navigationBarHidden = NO;//emmet20160829
            self.navigationController.navigationBar.translucent = NO;
            [self.navigationController setNavigationBarHidden:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
        if(_deviceOrientation != UIInterfaceOrientationLandscapeLeft && _deviceOrientation != UIInterfaceOrientationLandscapeRight){
            if(deviceOrientation == UIInterfaceOrientationLandscapeLeft){
                _deviceOrientation = UIInterfaceOrientationLandscapeLeft;
            }else if(deviceOrientation == UIInterfaceOrientationLandscapeRight){
                _deviceOrientation = UIInterfaceOrientationLandscapeRight;
            }
            
            if (_playerView) {
                _playerView.frame = CGRectMake(60, 0, [UIScreen mainScreen].bounds.size.width - 120, [UIScreen mainScreen].bounds.size.height - 66);
                _playBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-30, _playerView.frame.size.height, 60,40);
                _savePhotosAlbumBtn.frame = CGRectMake(10, _playerView.frame.size.height, 80,40);
                _deletedBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-90, _playerView.frame.size.height, 80,40);
            }
            
            _functionListTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-44);
            [_functionListTable reloadData];
            
            {
                float alpha = settingView.alpha;
                [self initSettingView];
                settingView.alpha = alpha;
            }
            
            {
                float alpha = cameraSettingView.alpha;
                [self initcameraSettingView];
                cameraSettingView.alpha = alpha;
            }
        }
        
    }
    else if(deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        if(self.navigationController.visibleViewController == self){
            NSLog(@"纵向");
            self.navigationController.navigationBarHidden=NO;//emmet20160829
            self.navigationController.navigationBar.translucent=NO;
            [self.navigationController setNavigationBarHidden: NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
        if(_deviceOrientation != UIInterfaceOrientationPortrait){
            _deviceOrientation = UIInterfaceOrientationPortrait;
            
            if (_playerView) {
                _playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
                _playBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-30, _playerView.frame.size.height, 60,40);
                _savePhotosAlbumBtn.frame = CGRectMake(10, _playerView.frame.size.height, 80,40);
                _deletedBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-90, _playerView.frame.size.height, 80,40);
            }
            _functionListTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
            [_functionListTable reloadData];
            
            {
                float alpha = settingView.alpha;
                [self initSettingView];
                settingView.alpha = alpha;
            }
            
            {
                float alpha = cameraSettingView.alpha;
                [self initcameraSettingView];
                cameraSettingView.alpha = alpha;
            }
        }
    }
    _playPlayer.frame = _playerView.bounds;
    
    return;
}

- (void)initXpkSdk{
    if(!_xpkSDK){
        
        //初始化
        _xpkSDK = [[XpkUISDK alloc] initWithAPPKey:APPKEY APPSecret:APPSECRET resultFail:^(NSError *error) {
            NSLog(@"error:%@",error);
        }];
        
        _xpkSDK.delegate = self;
        //是否需要定制功能
        _xpkSDK.editConfiguration.enableWizard                = false;
        //设置编辑所支持的文件类型
        _xpkSDK.editConfiguration.supportFileType             = SUPPORT_ALL;
        _xpkSDK.editConfiguration.defaultSelectAlbum          = RDDEFAULTSELECTALBUM_VIDEO;
        _xpkSDK.editConfiguration.supportDeviceOrientation    = UIINTERFACEORIENTATION_PORTRAIT;
        
        _xpkSDK.editConfiguration.customizationPROPORTIONTYPE                = RDPROPORTIONTYPE_AUDIO;
        
        //定长截取设置
        _xpkSDK.editConfiguration.trimMinDuration                 = 12.0;
        _xpkSDK.editConfiguration.trimMaxDuration                 = 30.0;
        _xpkSDK.editConfiguration.defaultSelectMinOrMax       = kRDDefaultSelectCutMax;
        
        
        //拍摄设置
        _xpkSDK.cameraConfiguration.cameraRecordSizeType        = RecordVideoTypeMixed;
        _xpkSDK.cameraConfiguration.cameraRecordOrientation     = RecordVideoOrientationAuto;
        _xpkSDK.cameraConfiguration.cameraCollocationPosition   = CameraCollocationPositionBottom;
        NSString * exportPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/recordVideoFile.mp4"];
        _xpkSDK.cameraConfiguration.cameraOutputPath = exportPath;
        
        //编辑导出设置
        _xpkSDK.exportConfiguration.videoBitRate   = VideoAverageBitRate;
        _xpkSDK.exportConfiguration.endPicDisabled = false;
        _xpkSDK.exportConfiguration.endPicUserName = @"疯狂熊猫人";//@"秀拍客";
        _xpkSDK.exportConfiguration.endPicImagepath = [[NSBundle mainBundle] pathForResource:@"片尾caise_LOGO" ofType:@"png"];
        
        _xpkSDK.exportConfiguration.waterDisabled = false;
        _xpkSDK.exportConfiguration.waterImage = [UIImage imageNamed:@"water_LOGO"];
        _xpkSDK.exportConfiguration.waterPosition = WATERPOSITION_LEFTTOP;
        
        //需要去掉哪些功能
        //_xpkSDK.editConfiguration.customizationTRIM           = false;
        //_xpkSDK.editConfiguration.customizationSPLIT          = false;
        //_xpkSDK.editConfiguration.customizationMUSIC            = false;
        //_xpkSDK.editConfiguration.customizationFILTER           = false;
        
        //TODO:以下设置已过期
        //        _xpkSDK.orientationLock      = YES;
        //        _xpkSDK.recordSizeType = RecordVideoTypeMixed;
        //        _xpkSDK.recordOrientation = RecordVideoOrientationAuto;
        //        _xpkSDK.deviceOrientation = _deviceOrientation;
        //        //设置截取的最大值和最小值，默认选中最大值还是最小值
        //        _xpkSDK.minDuration = 12.0;//最小值
        //        _xpkSDK.maxDuration = 30.0;//最大值
        //        _xpkSDK.defaultSelectMinOrMax = kRDDefaultSelectCutMin;// 设置 默认选中最大值还是最小值 default  kRDDefaultSelectCutMin
        //        //是否禁用片尾
        //        _xpkSDK.endWaterPicDisabled = false;// default NO
        //        //设置到处视频结尾水印的用户名
        //        [_xpkSDK setEndWaterPicUserName:@"疯狂熊猫人"];
        //======
        
    }
    [switchBtn setOn:(_xpkSDK.editConfiguration.enableWizard ? YES : NO)];
    [endPicDisabledBtn setSelected:(!_xpkSDK.exportConfiguration.endPicDisabled ? NO : YES)];
    [waterSettingBtn setSelected:(!_xpkSDK.exportConfiguration.waterDisabled ? NO : YES)];
    wizardLabel.text = _xpkSDK.editConfiguration.enableWizard ?  @"开启向导模式": @"关闭向导模式";
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0x27262c);
    //return;
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
        self.navigationController.navigationBarHidden = NO;//emmet20160829
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else{
        self.navigationController.navigationBarHidden=NO;//emmet20160829
        self.navigationController.navigationBar.translucent=NO;
        [self.navigationController setNavigationBarHidden: NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
#if 0
    
    UIButton *qiehuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qiehuanBtn.backgroundColor = [UIColor cyanColor];
    [qiehuanBtn setTitle:@"切换" forState:UIControlStateNormal];
    [qiehuanBtn setTitleColor:UIColorFromRGB(0x0e0e10) forState:UIControlStateNormal];
    [qiehuanBtn addTarget:self action:@selector(qiehuanBtnTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    qiehuanBtn.frame = CGRectMake(0, 0, 50, 35);
    qiehuanBtn.layer.cornerRadius = 5.0;
    qiehuanBtn.layer.masksToBounds = YES;
    UIBarButtonItem *batItem = [[UIBarButtonItem alloc] initWithCustomView:qiehuanBtn];
    self.navigationItem.rightBarButtonItem = batItem;
    
#endif
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    
    
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"kuwawnenbledLock"] boolValue]){
        self.title = @"iOS视频编辑SDK-Demo";
        
    }else{
        self.title = @"酷玩";
        
    }
    
    [self createXpkUISDKAlbum];
    
    
    
    _functionList = [[NSMutableArray alloc] init];
    
    NSMutableArray *functions_1 = [[NSMutableArray alloc] init];
    
    NSMutableArray *functions_2 = [[NSMutableArray alloc] init];
    NSMutableArray *functions_3 = [[NSMutableArray alloc] init];
    NSMutableArray *functions_4 = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *functions_Dic1 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *functions_Dic2 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *functions_Dic3 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *functions_Dic4 = [[NSMutableDictionary alloc] init];
    
    
    
    [functions_1 addObject:@"方式一:(正方形录制)"];
    [functions_1 addObject:@"方式二:(长方形录制)"];
    [functions_1 addObject:@"方式三:(正方形与长方形,可切换)"];
    
    [functions_Dic1 setObject:@"录制功能" forKey:@"title"];
    [functions_Dic1 setObject:functions_1 forKey:@"functionList"];
    
    [functions_2 addObject:@"方式一:直接进入编辑"];
    [functions_2 addObject:@"方式二:选择相册(不需要扫描)"];
    [functions_2 addObject:@"方式三:选择相册(需要扫描)"];
    
    [functions_Dic2 setObject:@"视频编辑" forKey:@"title"];
    [functions_Dic2 setObject:functions_2 forKey:@"functionList"];
    
    [functions_3 addObject:@"方式一:返回截取后的路径"];
    [functions_3 addObject:@"方式二:返回开始时间和结束时间"];
    [functions_3 addObject:@"方式三:自定义返回类型"];
    [functions_3 addObject:@"方式四:自由截取"];
    
    [functions_Dic3 setObject:@"视频截取" forKey:@"title"];
    [functions_Dic3 setObject:functions_3 forKey:@"functionList"];
    
    [functions_4 addObject:@"视频+图片"];
    [functions_4 addObject:@"仅视频"];
    [functions_4 addObject:@"仅图片"];
    
    [functions_Dic4 setObject:@"选择相册" forKey:@"title"];
    [functions_Dic4 setObject:functions_4 forKey:@"functionList"];
    
    
    [_functionList addObject:functions_Dic1];
    [_functionList addObject:functions_Dic2];
    [_functionList addObject:functions_Dic3];
    [_functionList addObject:functions_Dic4];
    
    CGRect rect;
    if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
        rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }else{
        rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    }
    
    _functionListTable = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    _functionListTable.backgroundView = nil;
    _functionListTable.backgroundColor = [UIColor clearColor];
    _functionListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _functionListTable.delegate = self;
    _functionListTable.dataSource = self;
    
    [self.view addSubview:_functionListTable];
    
    _editConfiguration = [[EditConfiguration alloc] init];
    _cameraConfiguration = [[CameraConfiguration alloc] init];
    _exportConfiguration = [[ExportConfiguration alloc] init];
    if(!settingView){
        [self initSettingView];
    }
    if(!cameraSettingView){
        [self initcameraSettingView];
    }
    [self initXpkSdk];
    
}

#pragma mark- 录制
- (void)recordVideoWithType:(NSInteger)index{
    
    if(_playerView){
        [_player pause];
        [_playerView removeFromSuperview];
        [_savePhotosAlbumBtn removeFromSuperview];
        [_playBtn removeFromSuperview];
        [_deletedBtn removeFromSuperview];
    }
    __weak ViewController *weakSelf = self;
    NSString * exportPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/recordVideoFile.mp4"];
    
    [self initXpkSdk];
    
#if 1
    
    _xpkSDK.cameraConfiguration.cameraOutputPath = exportPath;
    
    
    if(index == 0){
        //方式一
        _xpkSDK.cameraConfiguration.cameraOutputSize = CGSizeMake(1080, 1080);//设置输出视频大小
        _xpkSDK.cameraConfiguration.cameraRecordSizeType = RecordVideoTypeSquare;//设置输出视频是正方形还是长方形
        _xpkSDK.cameraConfiguration.cameraRecordOrientation = RecordVideoOrientationAuto;//设置界面方向（竖屏还是横屏）
    }
    
    if(index == 1){
        //方式二(只录制等宽高的视频，这里设置界面方向不会生效)
        _xpkSDK.cameraConfiguration.cameraOutputSize = CGSizeMake(1080, 1920);//设置输出视频大小
        _xpkSDK.cameraConfiguration.cameraRecordSizeType        = RecordVideoTypeNotSquare;
        _xpkSDK.cameraConfiguration.cameraRecordOrientation     = RecordVideoOrientationAuto;
        _xpkSDK.cameraConfiguration.cameraCollocationPosition   = CameraCollocationPositionTop;
    }
    if(index == 2){
        //方式三（自适应尺寸）
        _xpkSDK.cameraConfiguration.cameraOutputSize = CGSizeZero;//自动根据设备设置大小传入CGSizeZero
        _xpkSDK.cameraConfiguration.cameraRecordSizeType = RecordVideoTypeMixed;//设置输出视频是正方形还是长方形
        _xpkSDK.cameraConfiguration.cameraRecordOrientation = RecordVideoOrientationAuto;//设置界面方向（竖屏还是横屏）
        
    }
    
    [_xpkSDK videoRecordAutoSizeWithSourceController:self callbackBlock:^(NSString *videoPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (videoPath.length > 0) {
                [weakSelf editVideoWithPath:videoPath type:1];
            }
        });
    } imagebackBlock:^(NSString * _Nonnull imagePath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imagePath.length > 0) {
                [weakSelf editVideoWithPath:imagePath type:2];
            }
        });
        
    } faileBlock:^(NSError *error) {
        NSLog(@"error:%@",error);
    } cancel:^{
        //取消录制后在此做自己想做的事
    }];
    
    
#else
    if(index == 0){
        
        //方式一（自适应尺寸）
        _xpkSDK.cameraConfiguration.cameraRecordSizeType = RecordVideoTypeMixed;//设置输出视频是正方形还是长方形
        _xpkSDK.cameraConfiguration.cameraRecordOrientation = RecordVideoOrientationAuto;//设置界面方向（竖屏还是横屏）
        
        [_xpkSDK videoRecordAutoSizeWithSourceController:self
                                          cameraPosition:AVCaptureDevicePositionFront
                                               frameRate:30
                                                 bitRate:(4 * 1000 * 1000)
                                             Record_Type:RecordType_Video
                                              outputPath:exportPath
                                               videoPath:^(NSString *videoPath) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if (videoPath.length > 0) {
                                                           [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:(^(NSURL *assetURL, NSError *error){
                                                               NSLog(@"error:%@",error);
                                                           })];
                                                           [weakSelf editVideoWithPath:videoPath];
                                                       }
                                                   });
                                               } cancel:^{
                                                   
                                               }];
        
    }else if(index == 1){
        
        //方式二（录制指定大小的视频）
        _xpkSDK.cameraConfiguration.cameraRecordSizeType = RecordVideoTypeNotSquare;//设置输出视频是正方形还是长方形
        _xpkSDK.cameraConfiguration.cameraRecordOrientation = RecordVideoOrientationAuto;//设置界面方向（竖屏还是横屏）
        [_xpkSDK videoRecordWithSourceController:self
                                  cameraPosition:AVCaptureDevicePositionFront
                                       frameRate:30
                                         bitRate:(4 * 1000 * 1000)
                                      recordSize:CGSizeMake(1080, 1920)
                                     Record_Type: RecordType_Video
                                      outputPath:exportPath
                                       videoPath:^(NSString *videoPath) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               
                                               if (videoPath.length > 0) {
                                                   [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:(^(NSURL *assetURL, NSError *error){
                                                       NSLog(@"error:%@",error);
                                                   })];
                                                   [weakSelf editVideoWithPath:videoPath];
                                               }
                                           });
                                       } cancel:^{
                                           
                                       }];
        
    }else if(index == 2){
        
        //方式三(只录制等宽高的视频，这里设置界面方向不会生效)
        _xpkSDK.cameraConfiguration.cameraRecordSizeType        = RecordVideoTypeSquare;
        _xpkSDK.cameraConfiguration.cameraRecordOrientation     = RecordVideoOrientationAuto;
        _xpkSDK.cameraConfiguration.cameraCollocationPosition   = CameraCollocationPositionTop;
        [_xpkSDK videoRecordWidthEqualToHeightWithSourceController:self
                                                    cameraPosition:AVCaptureDevicePositionFront
                                                         frameRate:30
                                                           bitRate:(4 * 1000 * 1000)
                                                       Record_Type: RecordType_Video
                                                        outputPath:exportPath
                                                         videoPath:^(NSString *videoPath) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 
                                                                 if (videoPath.length > 0) {
                                                                     [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:(^(NSURL *assetURL, NSError *error){
                                                                         NSLog(@"error:%@",error);
                                                                     })];
                                                                     [weakSelf editVideoWithPath:videoPath];
                                                                 }
                                                             });
                                                         } cancel:^{
                                                             
                                                         }];
        
        
    }
    
    
#endif
}

#pragma mark- 编辑
- (void)editVideoWithType:(NSInteger)index{
    
    [self initXpkSdk];
    
    NSString * exportPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/exportVideoFile.mp4"];
    
    
    NSMutableArray *videoLists = [[NSMutableArray alloc] init];
    NSMutableArray *imagePaths = [[NSMutableArray alloc] init];
    NSString *imagepath = [[NSBundle mainBundle] pathForResource:@"IMG_0586" ofType:@"JPG"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testFile1" ofType:@"mov"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    
    if (index ==0){
        
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:opts];
        [imagePaths addObject:imagepath];
        [videoLists addObject:asset];
        __weak ViewController *weakSelf = self;
        
        //实例化XpkUiSDK对象（选择视频是需要扫描缓存文件“library/MyVideo”文件夹）
        [_xpkSDK editVideoWithSuperController:self foldertype:kFolderDocuments appAlbumCacheName:@"MyVideo" assets:videoLists imagePaths:[imagePaths mutableCopy] outputPath:exportPath callback:^(NSString *videoPath) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _exportVideoPath = videoPath;
                [weakSelf enterPlayView];
            });
        } cancel:^{
            
            [weakSelf cancelOutput];
            
        }];
        
        
    }
    else if(index ==1){
        
        __weak ViewController *weakSelf = self;
        
        [_xpkSDK editVideoWithSuperController:self  foldertype:kFolderNone appAlbumCacheName:@"MyVideo" assets:videoLists imagePaths:imagePaths outputPath:exportPath callback:^(NSString *videoPath) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _exportVideoPath = videoPath;
                [weakSelf enterPlayView];
            });
        } cancel:^{
            
            [weakSelf cancelOutput];
            
        }];
        
        
    } else{
        
        __weak ViewController *weakSelf = self;
        [_xpkSDK editVideoWithSuperController:self foldertype:kFolderDocuments appAlbumCacheName:@"MyVideo" assets:videoLists imagePaths:imagePaths outputPath:exportPath callback:^(NSString *videoPath) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _exportVideoPath = videoPath;
                [weakSelf enterPlayView];
            });
        } cancel:^{
            
            [weakSelf cancelOutput];
            
        }];
    }
    
    if(_playerView){
        _exportVideoPath = nil;
        [_player pause];
        [_playerView removeFromSuperview];
        _playerView = nil;
        [_playBtn removeFromSuperview];
        _playBtn = nil;
        [_savePhotosAlbumBtn removeFromSuperview];
        _savePhotosAlbumBtn = nil;
        [_deletedBtn removeFromSuperview];
        _deletedBtn = nil;
        _xpkSDK = nil;
    }
    
}

- (void)editVideoWithPath:(NSString *)path type:(int)type {
    if(!(path.length>0)){
        return;
    }
    NSMutableArray *videoLists = [[NSMutableArray alloc] init];
    NSMutableArray *imagePaths = [[NSMutableArray alloc] init];
    if(type == 1){
        AVURLAsset *assets = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
        [videoLists addObject:assets];
    }else{
        [imagePaths addObject:path];
    }
    __weak ViewController *weakSelf = self;
    //实例化XpkUiSDK对象
    NSString * exportPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/exportVideoFile.mp4"];
    
    [self initXpkSdk];
    
    [_xpkSDK editVideoWithSuperController:self foldertype:kFolderDocuments appAlbumCacheName:@"MyVideo" assets:videoLists imagePaths:imagePaths outputPath:exportPath callback:^(NSString *videoPath) {
        _exportVideoPath = videoPath;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
            if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
                if(self.navigationController.visibleViewController == self){
                    NSLog(@"横向");
                    self.navigationController.navigationBarHidden = YES;
                    self.navigationController.navigationBar.translucent = YES;
                    [self.navigationController setNavigationBarHidden:YES];
                    [[UIApplication sharedApplication] setStatusBarHidden:YES];
                }
                _functionListTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                
            }
            else if(deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown){
                if(self.navigationController.visibleViewController == self){
                    NSLog(@"纵向");
                    self.navigationController.navigationBarHidden=NO;
                    self.navigationController.navigationBar.translucent=NO;
                    [self.navigationController setNavigationBarHidden: NO];
                    [[UIApplication sharedApplication] setStatusBarHidden:NO];
                }
                _functionListTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
            }
            
            [weakSelf enterPlayView];
        });
    } cancel:^{
        [weakSelf cancelOutput];
    }];
    
    //设置视频输出码率
    //    [_xpkSDK setOutPutVideoAverageBitRate:VideoAverageBitRate];
    
}

#pragma mark- 截取
- (void)cutVideoWithType:(NSInteger)index{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testFile1" ofType:@"mov"];
    
    if(_playerView){
        _exportVideoPath = nil;
        [_player pause];
        [_playerView removeFromSuperview];
        _playerView = nil;
        [_playBtn removeFromSuperview];
        _playBtn = nil;
        [_savePhotosAlbumBtn removeFromSuperview];
        _savePhotosAlbumBtn = nil;
        [_deletedBtn removeFromSuperview];
        _deletedBtn = nil;
        _xpkSDK = nil;
    }
    
    NSString * exportPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/exportVideoFile.mp4"];
    
    [self initXpkSdk];
    
    
    __weak ViewController *weakSelf = self;
    //方式一（截取后回传截取后的视频）
    
    if(index == 3){
        [_xpkSDK trimVideoWithSuperController:self
                           controllerTrimMode:TRIMMODENOTSPECIFYTIME
                              controllerTitle:@"修剪片段"
                              backgroundColor:UIColorFromRGB(0x27262c)
                            cancelButtonTitle:@"取消"
                       cancelButtonTitleColor:UIColorFromRGB(0xffffff)
                  cancelButtonBackgroundColor:UIColorFromRGB(0x000000)
                             otherButtonTitle:@"下载选中片段"
                        otherButtonTitleColor:UIColorFromRGB(0xffffff)
                   otherButtonBackgroundColor:UIColorFromRGB(0x00000)
                                    assetPath:path
                                   outputPath:exportPath
                                callbackBlock:^(RDCutVideoReturnType cutType, NSString *videoPath, CMTime startTime, CMTime endTime) {
                                    NSLog(@"回调");
                                    if(cutType == RDCutVideoReturnTypePath){
                                        NSLog(@"path:%@",videoPath);
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            _exportVideoPath = videoPath;
                                            [weakSelf enterPlayView];
                                        });
                                    }
                                    
                                    if(cutType == RDCutVideoReturnTypeTime){
                                        NSLog(@"time:%lf,%lf",CMTimeGetSeconds(startTime),CMTimeGetSeconds(endTime));
                                    }
                                    
                                } failback:^(NSError *error) {
                                    NSLog(@"%@",error);
                                } cancel:^{
                                    NSLog(@"取消截取");
                                }];
        
        
        _xpkSDK.rd_CutVideoReturnType = ^(RDCutVideoReturnType *cutType){
            //            if(index == 0){
            //                //方式一：直接返回截取后的地址
            //                *cutType = RDCutVideoReturnTypePath;
            //
            //            }
            //            if(index == 1){
            //                //方式二:直接返回时间段
            //
            //                *cutType = RDCutVideoReturnTypeTime;
            //
            //            }
            //            if(index == 2){
            
            //方式三：用户自定义提示框
            *cutType = RDCutVideoReturnTypeAuto;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择" delegate:weakSelf cancelButtonTitle:@"返回路径" otherButtonTitles:@"返回时间", nil];
            alert.tag = 200;
            [alert show];
            //            }
        };
    }
    else{
        
        [_xpkSDK trimVideoWithSuperController:self
                           controllerTrimMode:TRIMMODESPECIFYTIME
                              controllerTitle:@"修剪片段"
                              backgroundColor:UIColorFromRGB(0x27262c)
                            cancelButtonTitle:@"取消"
                       cancelButtonTitleColor:UIColorFromRGB(0xffffff)
                  cancelButtonBackgroundColor:UIColorFromRGB(0x000000)
                             otherButtonTitle:@"下载片段"
                        otherButtonTitleColor:UIColorFromRGB(0xffffff)
                   otherButtonBackgroundColor:UIColorFromRGB(0x00000)
                                    assetPath:path
                                   outputPath:exportPath
                                callbackBlock:^(RDCutVideoReturnType cutType, NSString *videoPath, CMTime startTime, CMTime endTime) {
                                    NSLog(@"回调");
                                    if(cutType == RDCutVideoReturnTypePath){
                                        NSLog(@"path:%@",videoPath);
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            _exportVideoPath = videoPath;
                                            [weakSelf enterPlayView];
                                        });
                                    }
                                    
                                    if(cutType == RDCutVideoReturnTypeTime){
                                        NSLog(@"time:%lf,%lf",CMTimeGetSeconds(startTime),CMTimeGetSeconds(endTime));
                                    }
                                    
                                } failback:^(NSError *error) {
                                    NSLog(@"%@",error);
                                } cancel:^{
                                    NSLog(@"取消截取");
                                }];
        
        
        _xpkSDK.rd_CutVideoReturnType = ^(RDCutVideoReturnType *cutType){
            if(index == 0){
                //方式一：直接返回截取后的地址
                *cutType = RDCutVideoReturnTypePath;
                
            }
            if(index == 1){
                //方式二:直接返回时间段
                
                *cutType = RDCutVideoReturnTypeTime;
                
            }
            if(index == 2){
                
                //方式三：用户自定义提示框
                *cutType = RDCutVideoReturnTypeAuto;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择" delegate:weakSelf cancelButtonTitle:@"返回路径" otherButtonTitles:@"返回时间", nil];
                alert.tag = 200;
                [alert show];
            }
        };
    }
    
    
}

#pragma mark- 从相册选择文件
- (void)onXpkAlbumWithType:(NSInteger)index{
    switch (index) {
        case 0:
        {
            
            [_xpkSDK onXpkAlbumWithSuperController:self albumType:kALBUMALL callback:^(NSArray *videolist,NSArray *imageList) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:[NSString stringWithFormat:@"videos:%@ \n images:%@",videolist,imageList]
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
            }];
            
        }
            break;
        case 1:
        {
            [_xpkSDK onXpkAlbumWithSuperController:self albumType:kONLYALBUMVIDEO callback:^(NSArray *videolist,NSArray *imageList) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:[NSString stringWithFormat:@"videos:%@",videolist]
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
            }];
        }
            break;
        case 2:
        {
            
            [_xpkSDK onXpkAlbumWithSuperController:self albumType:kONLYALBUMIMAGE callback:^(NSArray *videolist,NSArray *imageList) {
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:[NSString stringWithFormat:@"images:%@",imageList]
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
                for (ALAsset *asset in imageList) {
                    @autoreleasepool {
                        //获取资源图片的详细资源信息
                        ALAssetRepresentation* representation = [asset defaultRepresentation];
                        //获取资源图片的全屏图
                        CGImageRef imageRef = [representation fullScreenImage];
                        UIImage *image = [UIImage imageWithCGImage:imageRef];
                        //获取资源图片的名字
                        NSString* filename = [[representation filename] stringByDeletingPathExtension];
                        NSLog(@"filename:%@",filename);
                        //获取沙盒中缓存文件目录
                        NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                        //将传入的文件名加在目录路径后面并返回
                        cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"images"];
                        if(![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]){
                            [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        
                        NSString *filePath = [cacheDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",filename]];
                        
                        NSData *__autoreleasing imageDataFullScreen = UIImagePNGRepresentation(image);
                        unlink([filePath UTF8String]);
                        //将获取到的文件拷贝到沙盒
                        [imageDataFullScreen writeToFile:filePath atomically:YES];
                        imageDataFullScreen = nil;
                    }
                }
            }];
        }
            break;
            
        default:
            break;
    }
}


- (void)cancelOutput{
    
}

- (void)enterPlayView{
    PlayVideoController *playVC = [[PlayVideoController alloc] init];
    if(!(_exportVideoPath.length>0)){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"testFile1" ofType:@"mov"];
        playVC.outputPath = path;
        
    }else{
        playVC.outputPath = _exportVideoPath;
    }
    playVC.deviceOrientation = _deviceOrientation;
    [self.navigationController pushViewController:playVC animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_functionList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_functionList[section] objectForKey:@"functionList"] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    headView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, headView.frame.size.width - 60, 20)];
    
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = [_functionList[section] objectForKey:@"title"];
    titleLabel.layer.masksToBounds = YES;
    [headView addSubview:titleLabel];
    
    if(section == 0 || section == 1){
        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        settingBtn.backgroundColor = [UIColor clearColor];
        [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
        [settingBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        if(section == 0){
            [settingBtn addTarget:self action:@selector(setcameraSettings:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [settingBtn addTarget:self action:@selector(settingBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        }
        settingBtn.frame = CGRectMake(headView.frame.size.width - 60, 7, 50, 30);
        settingBtn.layer.cornerRadius = 3.0;
        settingBtn.tag = section;
        settingBtn.layer.borderColor = UIColorFromRGB(0xffffff).CGColor;
        settingBtn.layer.borderWidth = 1;
        settingBtn.layer.masksToBounds = YES;
        [headView addSubview:settingBtn];
    }
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *iCell = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iCell];
    cell.textLabel.text = [[_functionList[indexPath.section] objectForKey:@"functionList"] objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        [self recordVideoWithType:indexPath.row];
    }
    if(indexPath.section == 1){
        [self editVideoWithType:indexPath.row];
    }
    if(indexPath.section == 2){
        [self cutVideoWithType:indexPath.row];
    }
    if(indexPath.section == 3){
        [self onXpkAlbumWithType:indexPath.row];
    }
}

#pragma mark- 相机设置
- (void)initcameraSettingView{
    if(cameraSettingView.superview){
        [cameraSettingView removeFromSuperview];
        cameraSettingView = nil;
    }
    
    cameraSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
    cameraSettingView.backgroundColor = UIColorFromRGB(0x27262c);
    [self.navigationController.view addSubview:cameraSettingView];
    cameraSettingView.alpha = 0.0;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraTapgesture)];
    [cameraSettingView addGestureRecognizer:gesture];
    
    
    float width = MIN(cameraSettingView.frame.size.width, cameraSettingView.frame.size.height);
    UIScrollView *settingScrollView = [[UIScrollView alloc] init];
    settingScrollView.frame = CGRectMake((cameraSettingView.frame.size.width - width), 20, width, cameraSettingView.frame.size.height - 84);
    if([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height){
        cameraSettingView.backgroundColor = [UIColor colorWithRed:39.0/250.0 green:38.0/250.0 blue:44.0/250.0 alpha:0.7];
        settingScrollView.frame = CGRectMake((cameraSettingView.frame.size.width - width)/2.0, 0, width, cameraSettingView.frame.size.height - 84);
        
    }
    settingScrollView.backgroundColor = self.view.backgroundColor;//[UIColor colorWithWhite:1 alpha:0.9];
    
    [cameraSettingView addSubview:settingScrollView];
    
    
    UILabel *cameraPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 24, 105, 31)];
    cameraPositionLabel.font = [UIFont systemFontOfSize:16];
    cameraPositionLabel.backgroundColor = UIColorFromRGB(0x27262c);
    cameraPositionLabel.textColor = [UIColor whiteColor];
    cameraPositionLabel.textAlignment = NSTextAlignmentLeft;
    cameraPositionLabel.text = @"摄像头设置:";
    cameraPositionLabel.layer.masksToBounds = YES;
    
    if(camerapositionSettingView.superview){
        [camerapositionSettingView removeFromSuperview];
        camerapositionSettingView = nil;
    }
    camerapositionSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, cameraPositionLabel.frame.size.height + cameraPositionLabel.frame.origin.y - 15, settingScrollView.frame.size.width, 60)];
    camerapositionSettingView.backgroundColor = [UIColor clearColor];
    camerapositionSettingView.layer.cornerRadius = 3.0;
    camerapositionSettingView.layer.borderWidth = 1;
    camerapositionSettingView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    camerapositionSettingView.layer.masksToBounds = YES;
    [settingScrollView addSubview:camerapositionSettingView];
    
    [settingScrollView addSubview:cameraPositionLabel];
    
    
    for (int i = 0 ; i<2 ; i++) {
        UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingItemBtn setBackgroundColor:[UIColor clearColor]];
        
        if((_xpkSDK.cameraConfiguration.cameraCaptureDevicePosition == AVCaptureDevicePositionFront && i == 0) || (_xpkSDK.cameraConfiguration.cameraCaptureDevicePosition == AVCaptureDevicePositionBack && i == 1)){
            [settingItemBtn setSelected:YES];
        }else{
            [settingItemBtn setSelected:NO];
        }
        [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
        [settingItemBtn addTarget:self action:@selector(cameraPositionChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        settingItemBtn.layer.cornerRadius = 4.0;
        settingItemBtn.layer.masksToBounds = YES;
        settingItemBtn.tag = i+1;
        switch (i) {
                
            case 0:
            {
                [settingItemBtn setTitle:@"前置" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(30, 25, 100, 30);
                
            }
                break;
            case 1:
                [settingItemBtn setTitle:@"后置" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(200, 25, 100, 30);
                
                break;
            default:
                break;
        }
        [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, settingItemBtn.frame.size.width - 20)];
        
        [camerapositionSettingView addSubview:settingItemBtn];
    }
    
    
    UILabel *cameraModelLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, camerapositionSettingView.frame.origin.y + camerapositionSettingView.frame.size.height + 10, 115, 31)];
    cameraModelLabel.font = [UIFont systemFontOfSize:16];
    cameraModelLabel.backgroundColor = UIColorFromRGB(0x27262c);
    cameraModelLabel.textColor = [UIColor whiteColor];
    cameraModelLabel.textAlignment = NSTextAlignmentLeft;
    cameraModelLabel.text = @"拍摄模式设置:";
    cameraModelLabel.layer.masksToBounds = YES;
    
    
    if(cameraModelSettingView.superview){
        [cameraModelSettingView removeFromSuperview];
        cameraModelSettingView = nil;
    }
    cameraModelSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, cameraModelLabel.frame.size.height + cameraModelLabel.frame.origin.y - 15, settingScrollView.frame.size.width, 140)];
    cameraModelSettingView.backgroundColor = [UIColor clearColor];
    cameraModelSettingView.layer.cornerRadius = 3.0;
    cameraModelSettingView.layer.borderWidth = 1;
    cameraModelSettingView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    cameraModelSettingView.layer.masksToBounds = YES;
    [settingScrollView addSubview:cameraModelSettingView];
    
    [settingScrollView addSubview:cameraModelLabel];
    for (int i = 0 ; i<2 ; i++) {
        UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingItemBtn setBackgroundColor:[UIColor clearColor]];
        
        if((_xpkSDK.cameraConfiguration.cameraModelType == CameraModel_Onlyone && i == 1) || (_xpkSDK.cameraConfiguration.cameraModelType == CameraModel_Manytimes && i == 0)){
            [settingItemBtn setSelected:YES];
        }else{
            [settingItemBtn setSelected:NO];
        }
        [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
        [settingItemBtn addTarget:self action:@selector(cameraModelChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        settingItemBtn.layer.cornerRadius = 4.0;
        settingItemBtn.layer.masksToBounds = YES;
        settingItemBtn.tag = i+1;
        switch (i) {
                
            case 0:
            {
                [settingItemBtn setTitle:@"多次拍摄" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(30, 25, 100, 30);
                
            }
                break;
            case 1:{
                settingItemBtn.backgroundColor = UIColorFromRGB(0x27262c);
                [settingItemBtn setTitle:@"单次拍摄" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(30, 60, 100, 30);
                
                if(cameraWriteToAlbumSettingView.superview){
                    [cameraWriteToAlbumSettingView removeFromSuperview];
                    cameraWriteToAlbumSettingView = nil;
                }
                cameraWriteToAlbumSettingView = [[UIView alloc] initWithFrame:CGRectMake(5, settingItemBtn.frame.size.height + settingItemBtn.frame.origin.y - 15, cameraModelSettingView.frame.size.width - 10, 60)];
                cameraWriteToAlbumSettingView.backgroundColor = [UIColor clearColor];
                cameraWriteToAlbumSettingView.layer.cornerRadius = 3.0;
                cameraWriteToAlbumSettingView.layer.borderWidth = 1;
                cameraWriteToAlbumSettingView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
                cameraWriteToAlbumSettingView.layer.masksToBounds = YES;
                [cameraModelSettingView addSubview:cameraWriteToAlbumSettingView];
                
                for (int i = 0 ; i<2 ; i++) {
                    UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [settingItemBtn setBackgroundColor:[UIColor clearColor]];
                    
                    if((_xpkSDK.cameraConfiguration.cameraWriteToAlbum && i == 0) || (!_xpkSDK.cameraConfiguration.cameraWriteToAlbum && i == 1)){
                        [settingItemBtn setSelected:YES];
                    }else{
                        [settingItemBtn setSelected:NO];
                    }
                    [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
                    [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
                    [settingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
                    [settingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
                    [settingItemBtn addTarget:self action:@selector(cameraWriteToAlbumChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
                    
                    settingItemBtn.layer.cornerRadius = 4.0;
                    settingItemBtn.layer.masksToBounds = YES;
                    settingItemBtn.tag = i+1;
                    switch (i) {
                            
                        case 0:
                        {
                            [settingItemBtn setTitle:@"写入相册" forState:UIControlStateNormal];
                            settingItemBtn.frame = CGRectMake(10, 20, 100, 30);
                            
                        }
                            break;
                        case 1:
                            [settingItemBtn setTitle:@"不写入相册" forState:UIControlStateNormal];
                            settingItemBtn.frame = CGRectMake(160, 20, 120, 30);
                            
                            break;
                        default:
                            break;
                    }
                    [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
                    [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, settingItemBtn.frame.size.width - 20)];
                    
                    
                    [cameraWriteToAlbumSettingView addSubview:settingItemBtn];
                }
            }
                break;
            default:
                break;
        }
        [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, settingItemBtn.frame.size.width - 20)];
        
        
        [cameraModelSettingView addSubview:settingItemBtn];
    }
    
    
    UIButton *cancelSettingBtn;
    UIButton *saveSettingBtn;
    
    cancelSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelSettingBtn setBackgroundImage:[self ImageWithColor:[UIColor whiteColor] cornerRadius:1] forState:UIControlStateNormal];
    [cancelSettingBtn setBackgroundImage:[self ImageWithColor:[UIColor whiteColor] cornerRadius:1] forState:UIControlStateSelected];
    [cancelSettingBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelSettingBtn setTitleColor:UIColorFromRGB(0x0e0e10) forState:UIControlStateNormal];
    [cancelSettingBtn addTarget:self action:@selector(cancelCameraSettingBtnTouch) forControlEvents:UIControlEventTouchUpInside];
    cancelSettingBtn.frame = CGRectMake(settingScrollView.frame.origin.x, settingView.frame.size.height - 50, settingScrollView.frame.size.width/2.0-5, 40);
    cancelSettingBtn.layer.cornerRadius = 3.0;
    cancelSettingBtn.layer.masksToBounds = YES;
    [cameraSettingView addSubview:cancelSettingBtn];
    
    saveSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveSettingBtn setBackgroundImage:[self ImageWithColor:[UIColor whiteColor] cornerRadius:1] forState:UIControlStateNormal];
    [saveSettingBtn setBackgroundImage:[self ImageWithColor:[UIColor whiteColor] cornerRadius:1] forState:UIControlStateSelected];
    [saveSettingBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveSettingBtn setTitleColor:UIColorFromRGB(0x0e0e10) forState:UIControlStateNormal];
    [saveSettingBtn addTarget:self action:@selector(saveCameraSettingBtnTouch) forControlEvents:UIControlEventTouchUpInside];
    saveSettingBtn.frame = CGRectMake(cancelSettingBtn.frame.origin.x + cancelSettingBtn.frame.size.width+10, settingView.frame.size.height - 50 , settingScrollView.frame.size.width/2.0-5, 40);
    saveSettingBtn.layer.cornerRadius = 3.0;
    saveSettingBtn.layer.masksToBounds = YES;
    
    [cameraSettingView addSubview:saveSettingBtn];
}

- (void)cameraTapgesture{
    cameraSettingView.alpha = 0.0;
    
}

- (void)setcameraSettings:(UIButton *)sender{
    cameraSettingView.alpha = 1.0;
    _cameraConfiguration.cameraWriteToAlbum = _xpkSDK.cameraConfiguration.cameraWriteToAlbum;
    _cameraConfiguration.cameraModelType    = _xpkSDK.cameraConfiguration.cameraModelType;
    _cameraConfiguration.cameraCaptureDevicePosition = _xpkSDK.cameraConfiguration.cameraCaptureDevicePosition;
    
    if(_xpkSDK.cameraConfiguration.cameraCaptureDevicePosition == AVCaptureDevicePositionFront){
        UIButton *btn1 = (UIButton *)[camerapositionSettingView viewWithTag:1];
        UIButton *btn2 = (UIButton *)[camerapositionSettingView viewWithTag:2];
        [btn1 setSelected:YES];
        [btn2 setSelected:NO];
        
    }else{
        UIButton *btn1 = (UIButton *)[camerapositionSettingView viewWithTag:1];
        UIButton *btn2 = (UIButton *)[camerapositionSettingView viewWithTag:2];
        [btn1 setSelected:NO];
        [btn2 setSelected:YES];
        
    }
}

- (void)cameraPositionChildBtnTouch:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
            _xpkSDK.cameraConfiguration.cameraCaptureDevicePosition = AVCaptureDevicePositionFront;
            break;
        case 2:
            _xpkSDK.cameraConfiguration.cameraCaptureDevicePosition = AVCaptureDevicePositionBack;
            break;
        default:
            break;
    }
    
    for (UIButton *itemBtn in camerapositionSettingView.subviews) {
        if([itemBtn isKindOfClass:[UIButton class]]){
            if(itemBtn.tag == sender.tag){
                [itemBtn setSelected:YES];
            }else{
                [itemBtn setSelected:NO];
            }
        }
    }
}

- (void)cameraModelChildBtnTouch:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
            _xpkSDK.cameraConfiguration.cameraModelType = CameraModel_Manytimes;
            break;
        case 2:
            _xpkSDK.cameraConfiguration.cameraModelType = CameraModel_Onlyone;
            break;
            
        default:
            break;
    }
    
    for (UIButton *itemBtn in cameraModelSettingView.subviews) {
        if([itemBtn isKindOfClass:[UIButton class]]){
            if(itemBtn.tag == sender.tag){
                [itemBtn setSelected:YES];
            }else{
                [itemBtn setSelected:NO];
            }
        }
    }
}

- (void)cameraWriteToAlbumChildBtnTouch:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
            _xpkSDK.cameraConfiguration.cameraWriteToAlbum = true;
            break;
        case 2:
            _xpkSDK.cameraConfiguration.cameraWriteToAlbum = false;
            break;
        default:
            break;
    }
    
    for (UIButton *itemBtn in cameraWriteToAlbumSettingView.subviews) {
        if([itemBtn isKindOfClass:[UIButton class]]){
            if(itemBtn.tag == sender.tag){
                [itemBtn setSelected:YES];
            }else{
                [itemBtn setSelected:NO];
            }
        }
    }
}

- (void)cancelCameraSettingBtnTouch{
    cameraSettingView.alpha = 0.0;
    _xpkSDK.cameraConfiguration.cameraWriteToAlbum = _cameraConfiguration.cameraWriteToAlbum;
    _xpkSDK.cameraConfiguration.cameraModelType    = _cameraConfiguration.cameraModelType;
    _xpkSDK.cameraConfiguration.cameraCaptureDevicePosition = _cameraConfiguration.cameraCaptureDevicePosition;
    
}

- (void)saveCameraSettingBtnTouch{
    cameraSettingView.alpha = 0.0;
}

#pragma mark- 编辑导出设置
- (void)initSettingView{
    if(settingView.superview){
        [settingView removeFromSuperview];
        settingView = nil;
    }
    
    settingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
    settingView.backgroundColor = UIColorFromRGB(0x27262c);
    
    float width = MIN(settingView.frame.size.width, settingView.frame.size.height);
    UIScrollView *settingScrollView = [[UIScrollView alloc] init];
    settingScrollView.frame = CGRectMake((settingView.frame.size.width - width), 20, width, settingView.frame.size.height - 84);
    if([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height){
        settingView.backgroundColor = [UIColor colorWithRed:39.0/250.0 green:38.0/250.0 blue:44.0/250.0 alpha:0.7];
        settingScrollView.frame = CGRectMake((settingView.frame.size.width - width)/2.0, 0, width, settingView.frame.size.height - 84);
        
    }
    settingScrollView.backgroundColor = self.view.backgroundColor;//[UIColor colorWithWhite:1 alpha:0.9];
    
    [settingView addSubview:settingScrollView];
    
    
    //UI方向
    
    UILabel *deviceOrientationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, 120, 31)];
    deviceOrientationLabel.font = [UIFont systemFontOfSize:16];
    deviceOrientationLabel.backgroundColor = [UIColor clearColor];
    deviceOrientationLabel.textColor = [UIColor whiteColor];
    deviceOrientationLabel.textAlignment = NSTextAlignmentLeft;
    deviceOrientationLabel.text = @"UI方向:";
    deviceOrientationLabel.layer.masksToBounds = YES;
    [settingScrollView addSubview:deviceOrientationLabel];
    
    
    if(supportDeviceOrientationView.superview){
        [supportDeviceOrientationView removeFromSuperview];
        supportDeviceOrientationView = nil;
    }
    supportDeviceOrientationView = [[UIView alloc] initWithFrame:CGRectMake(0, deviceOrientationLabel.frame.size.height + deviceOrientationLabel.frame.origin.y + 10, settingScrollView.frame.size.width, 40)];
    supportDeviceOrientationView.backgroundColor = [UIColor clearColor];
    supportDeviceOrientationView.layer.cornerRadius = 3.0;
    supportDeviceOrientationView.layer.borderWidth = 1;
    supportDeviceOrientationView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    supportDeviceOrientationView.layer.masksToBounds = YES;
    [settingScrollView addSubview:supportDeviceOrientationView];
    
    for (int i = 0 ; i<3 ; i++) {
        UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingItemBtn setBackgroundColor:[UIColor clearColor]];
        
        if(_xpkSDK.editConfiguration.supportDeviceOrientation == i){
            [settingItemBtn setSelected:YES];
        }else{
            [settingItemBtn setSelected:NO];
        }
        [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
        [settingItemBtn addTarget:self action:@selector(supportDeviceOrientationChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        settingItemBtn.layer.cornerRadius = 4.0;
        settingItemBtn.layer.masksToBounds = YES;
        settingItemBtn.tag = i+1;
        switch (i) {
                
            case 0:
            {
                [settingItemBtn setTitle:@"锁定竖屏" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(5, 5, 100, 30);
                
            }
                break;
            case 1:
                [settingItemBtn setTitle:@"锁定横屏" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(110, 5, 100, 30);
                
                break;
            case 2:
            {
                [settingItemBtn setTitle:@"方向自动" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(220, 5, 100, 30);
                
            }
                break;
            default:
                break;
        }
        [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, settingItemBtn.frame.size.width - 20)];
        
        [supportDeviceOrientationView addSubview:settingItemBtn];
    }
    
    
    
    //向导
    if(switchBtn.superview){
        [switchBtn removeFromSuperview];
        switchBtn = nil;
    }
    switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(10, supportDeviceOrientationView.frame.origin.y + supportDeviceOrientationView.frame.size.height + 20, 59, 25)];
    [switchBtn setOnImage:[self ImageWithColor:UIColorFromRGB(0xffffff) cornerRadius:1]];
    [switchBtn setOffImage:[self ImageWithColor:UIColorFromRGB(0x000000) cornerRadius:1]];
    [switchBtn setThumbTintColor:[UIColor whiteColor]];
    [switchBtn addTarget:self action:@selector(wizardValueChanged:) forControlEvents:UIControlEventValueChanged];
    [settingScrollView addSubview:switchBtn];
    
    if(wizardLabel.superview){
        [wizardLabel removeFromSuperview];
        wizardLabel = nil;
    }
    wizardLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, switchBtn.frame.origin.y, settingScrollView.frame.size.width - 120, 31)];
    wizardLabel.font = [UIFont systemFontOfSize:20];
    wizardLabel.backgroundColor = [UIColor clearColor];
    wizardLabel.textColor = [UIColor whiteColor];
    wizardLabel.textAlignment = NSTextAlignmentCenter;
    wizardLabel.text = _xpkSDK.editConfiguration.enableWizard ?  @"开启向导模式": @"关闭向导模式";
    wizardLabel.layer.masksToBounds = YES;
    [settingScrollView addSubview:wizardLabel];
    
    NSArray *editSettings = [[NSArray alloc] initWithObjects:@"配 乐",@"滤 镜",@"配 音",@"字 幕",@"特 效", nil];
    NSArray *fragmentEditSettings = [[NSArray alloc] initWithObjects:@"截 取",@"分 割",@"裁切+旋转",@"调 速",@"调整图片时长",@"复 制",@"调 序",@"文字版",@"画面比例", nil];
    
    if(editSettingView.superview){
        [editSettingView removeFromSuperview];
        editSettingView = nil;
    }
    editSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, switchBtn.frame.size.height + switchBtn.frame.origin.y + 20, settingScrollView.frame.size.width, ceil(editSettings.count/2.0)*80 - 40)];
    editSettingView.backgroundColor = [UIColor clearColor];
    editSettingView.layer.masksToBounds = YES;
    
    
    [settingScrollView addSubview:editSettingView];
    
    
    
    for (int i = 0; i<editSettings.count; i++) {
        int cellIndex = floorf(i/2);
        UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingItemBtn setBackgroundColor:[UIColor clearColor]];
        [settingItemBtn setTitle:editSettings[i] forState:UIControlStateNormal];
        [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateSelected];
        [settingItemBtn setImage:[UIImage imageNamed:@"启用勾_"] forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"不启用_"] forState:UIControlStateSelected];
        [settingItemBtn addTarget:self action:@selector(settingScrollViewChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        switch (i) {
            case 0:
            {
                settingItemBtn.frame = CGRectMake(20, 5, 68, 30);
                NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
                [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
                
                CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
                
                [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 1, 0, settingItemBtn.frame.size.width - 20)];
                [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
                
                [settingItemBtn setBackgroundColor:UIColorFromRGB(0x27262c)];
                [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - 20)];
                [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
                
                if(musicSettingView.superview){
                    [musicSettingView removeFromSuperview];
                    musicSettingView = nil;
                }
                musicSettingView = [[UIView alloc] initWithFrame:CGRectMake(5,settingItemBtn.frame.origin.y + settingItemBtn.frame.size.height - 15, editSettingView.frame.size.width - 10, 40 + 15)];
                musicSettingView.backgroundColor = [UIColor clearColor];
                musicSettingView.layer.cornerRadius = 3.0;
                musicSettingView.layer.borderWidth = 1;
                musicSettingView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
                musicSettingView.layer.masksToBounds = YES;
                [editSettingView addSubview:musicSettingView];
                
                
                
                for (int k = 0; k<2; k++) {
                    UIButton *msettingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [msettingItemBtn setBackgroundColor:[UIColor clearColor]];
                    
                    if(_xpkSDK.editConfiguration.customizationMUSICTYPE == k){
                        [msettingItemBtn setSelected:YES];
                    }else{
                        [msettingItemBtn setSelected:NO];
                    }
                    [msettingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
                    [msettingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
                    [msettingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
                    [msettingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
                    [msettingItemBtn addTarget:self action:@selector(msettingItemChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
                    msettingItemBtn.frame = CGRectMake(musicSettingView.frame.size.width/2.0 * k + 10, 5+15, 70, 30);
                    msettingItemBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                    msettingItemBtn.layer.cornerRadius = 4.0;
                    msettingItemBtn.layer.masksToBounds = YES;
                    msettingItemBtn.tag = k+1;
                    switch (k) {
                        case 0:
                        {
                            [msettingItemBtn setTitle:@"配乐一" forState:UIControlStateNormal];
                        }
                            break;
                        case 1:
                        {
                            [msettingItemBtn setTitle:@"配乐二" forState:UIControlStateNormal];
                        }
                            break;
                        default:
                            break;
                    }
                    
                    [msettingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, msettingItemBtn.frame.size.width - 20)];
                    [msettingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -(msettingItemBtn.frame.size.width - 30), 0, 0)];
                    
                    [musicSettingView addSubview:msettingItemBtn];
                }
                
            }
                break;
                
            case 1:
            {
                settingItemBtn.frame = CGRectMake(20, 80 +5, 68, 30);
                NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
                [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
                
                CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
                
                [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 1, 0, settingItemBtn.frame.size.width - 20)];
                [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
                
                [settingItemBtn setBackgroundColor:UIColorFromRGB(0x27262c)];
                [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - 20)];
                [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
                
                if(filterSettingView.superview){
                    [filterSettingView removeFromSuperview];
                    filterSettingView = nil;
                }
                filterSettingView = [[UIView alloc] initWithFrame:CGRectMake(5,settingItemBtn.frame.origin.y + settingItemBtn.frame.size.height - 15, editSettingView.frame.size.width - 10, 40 + 15)];
                filterSettingView.backgroundColor = [UIColor clearColor];
                filterSettingView.layer.cornerRadius = 3.0;
                filterSettingView.layer.borderWidth = 1;
                filterSettingView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
                filterSettingView.layer.masksToBounds = YES;
                [editSettingView addSubview:filterSettingView];
                
                
                
                for (int k = 0; k<2; k++) {
                    UIButton *fsettingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [fsettingItemBtn setBackgroundColor:[UIColor clearColor]];
                    
                    if(_xpkSDK.editConfiguration.customizationFILTERTYPE == k){
                        [fsettingItemBtn setSelected:YES];
                    }else{
                        [fsettingItemBtn setSelected:NO];
                    }
                    [fsettingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
                    [fsettingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
                    [fsettingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
                    [fsettingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
                    [fsettingItemBtn addTarget:self action:@selector(fsettingItemChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
                    fsettingItemBtn.frame = CGRectMake(filterSettingView.frame.size.width/2.0 * k + 10, 5+15, 70, 30);
                    fsettingItemBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                    fsettingItemBtn.layer.cornerRadius = 4.0;
                    fsettingItemBtn.layer.masksToBounds = YES;
                    fsettingItemBtn.tag = k+1;
                    switch (k) {
                        case 0:
                        {
                            [fsettingItemBtn setTitle:@"滤镜一" forState:UIControlStateNormal];
                        }
                            break;
                        case 1:
                        {
                            [fsettingItemBtn setTitle:@"滤镜二" forState:UIControlStateNormal];
                        }
                            break;
                        default:
                            break;
                    }
                    
                    [fsettingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, fsettingItemBtn.frame.size.width - 20)];
                    [fsettingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -(fsettingItemBtn.frame.size.width - 30), 0, 0)];
                    
                    [filterSettingView addSubview:fsettingItemBtn];
                }
            }
                break;
            case 2:
            {
                settingItemBtn.frame = CGRectMake(20, 2*80+5, settingScrollView.frame.size.width/3-5, 30);
                NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
                [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
                
                CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
                
                [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 1, 0, settingItemBtn.frame.size.width - 20)];
                [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
                
            }
                break;
            case 3:
            {
                settingItemBtn.frame = CGRectMake((settingScrollView.frame.size.width/3 + 5) + 20, 2*80+5, settingScrollView.frame.size.width/3-5, 30);
                NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
                [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
                
                CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
                
                [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 1, 0, settingItemBtn.frame.size.width - 20)];
                [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
                
            }
                break;
            case 4:
            {
                settingItemBtn.frame = CGRectMake((settingScrollView.frame.size.width/3 + 5) * 2 + 20, 2*80+5, settingScrollView.frame.size.width/3-5, 30);
                NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
                [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
                
                CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
                
                [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 1, 0, settingItemBtn.frame.size.width - 20)];
                [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
                
            }
                break;
            default:
                break;
        }
        
        settingItemBtn.layer.cornerRadius = 4.0;
        settingItemBtn.layer.masksToBounds = YES;
        settingItemBtn.tag = i+1;
        
        [editSettingView addSubview:settingItemBtn];
    }
    
    if(fragmentEditBtn.superview){
        [fragmentEditBtn removeFromSuperview];
        fragmentEditBtn = nil;
    }
    fragmentEditBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fragmentEditBtn setBackgroundColor:UIColorFromRGB(0x27262c)];
    [fragmentEditBtn setTitle:@"片段编辑" forState:UIControlStateNormal];
    [fragmentEditBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [fragmentEditBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateSelected];
    [fragmentEditBtn setImage:[UIImage imageNamed:@"启用勾_"] forState:UIControlStateNormal];
    [fragmentEditBtn setImage:[UIImage imageNamed:@"不启用_"] forState:UIControlStateSelected];
    [fragmentEditBtn addTarget:self action:@selector(fragmentEditBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    fragmentEditBtn.frame = CGRectMake(20, editSettingView.frame.origin.y+editSettingView.frame.size.height + 20, 100, 30);
    fragmentEditBtn.layer.masksToBounds = YES;
    NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
    [fontAttributes setObject:fragmentEditBtn.titleLabel.font forKey:NSFontAttributeName];
    CGRect titleContentRect = [fragmentEditBtn.titleLabel.text boundingRectWithSize:CGSizeMake(fragmentEditBtn.frame.size.width, fragmentEditBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
    [fragmentEditBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, fragmentEditBtn.frame.size.width - 20)];
    [fragmentEditBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, fragmentEditBtn.frame.size.width - titleContentRect.size.width - 30)];
    
    
    if(fragmentEditSettingView.superview){
        [fragmentEditSettingView removeFromSuperview];
        fragmentEditSettingView = nil;
    }
    fragmentEditSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, fragmentEditBtn.frame.origin.y+fragmentEditBtn.frame.size.height-15, settingScrollView.frame.size.width,ceil(fragmentEditSettings.count/2.0)*40 + 70)];
    fragmentEditSettingView.backgroundColor = [UIColor clearColor];
    
    fragmentEditSettingView.layer.cornerRadius = 2.0;
    fragmentEditSettingView.layer.borderWidth = 1;
    fragmentEditSettingView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    fragmentEditSettingView.layer.masksToBounds = YES;
    
    [settingScrollView addSubview:fragmentEditSettingView];
    [settingScrollView addSubview:fragmentEditBtn];
    
    for (int i = 0; i<fragmentEditSettings.count; i++) {
        int cellIndex = floorf(i/2);
        UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingItemBtn setTitle:fragmentEditSettings[i] forState:UIControlStateNormal];
        [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateSelected];
        [settingItemBtn setImage:[UIImage imageNamed:@"启用勾_"] forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"不启用_"] forState:UIControlStateSelected];
        [settingItemBtn addTarget:self action:@selector(fragmentEditChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        if(i%2==0){
            settingItemBtn.frame = CGRectMake((settingScrollView.frame.size.width/2 + 5) * (i%2) + 20, cellIndex*40+25, settingScrollView.frame.size.width/2-5, 30);
        }else{
            settingItemBtn.frame = CGRectMake((settingScrollView.frame.size.width/2 + 5) * (i%2)+30, cellIndex*40+25, settingScrollView.frame.size.width/2-5 - 30, 30);
        }
        settingItemBtn.layer.cornerRadius = 4.0;
        settingItemBtn.layer.masksToBounds = YES;
        settingItemBtn.tag = i+1;
        
        NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
        [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
        
        CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
        
        [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 1, 0, settingItemBtn.frame.size.width - 20)];
        [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
        
        
        if(i== fragmentEditSettings.count-1){
            settingItemBtn.frame = CGRectMake(20, cellIndex*40+25, 100, 30);
            [settingItemBtn setBackgroundColor:UIColorFromRGB(0x27262c)];
            [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - 20)];
            [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, settingItemBtn.frame.size.width - titleContentRect.size.width - 30)];
            
            if(proportionSettingView.superview){
                [proportionSettingView removeFromSuperview];
                proportionSettingView = nil;
            }
            proportionSettingView = [[UIView alloc] initWithFrame:CGRectMake(5,settingItemBtn.frame.origin.y + settingItemBtn.frame.size.height - 15, fragmentEditSettingView.frame.size.width - 10, 40 + 15)];
            proportionSettingView.backgroundColor = [UIColor clearColor];
            proportionSettingView.layer.cornerRadius = 3.0;
            proportionSettingView.layer.borderWidth = 1;
            proportionSettingView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
            proportionSettingView.layer.masksToBounds = YES;
            [fragmentEditSettingView addSubview:proportionSettingView];
            
            
            
            for (int k = 0; k<3; k++) {
                UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [settingItemBtn setBackgroundColor:[UIColor clearColor]];
                
                if(_xpkSDK.editConfiguration.customizationPROPORTIONTYPE == i){
                    [settingItemBtn setSelected:YES];
                }else{
                    [settingItemBtn setSelected:NO];
                }
                [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
                [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
                [settingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
                [settingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
                [settingItemBtn addTarget:self action:@selector(proportionSettingChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
                settingItemBtn.frame = CGRectMake(110 * k + 15, 5+15, 90, 30);
                
                settingItemBtn.layer.cornerRadius = 4.0;
                settingItemBtn.layer.masksToBounds = YES;
                settingItemBtn.tag = k+1;
                switch (k) {
                    case 0:
                    {
                        [settingItemBtn setTitle:@"自 动" forState:UIControlStateNormal];
                        
                        
                    }
                        break;
                    case 1:
                    {
                        [settingItemBtn setTitle:@"横 屏" forState:UIControlStateNormal];
                        
                    }
                        break;
                    case 2:
                        [settingItemBtn setTitle:@"1 : 1" forState:UIControlStateNormal];
                        break;
                        
                    default:
                        break;
                }
                
                NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
                [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
                CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
                [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, settingItemBtn.frame.size.width - 20)];
                [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -(settingItemBtn.frame.size.width - titleContentRect.size.width), 0, 0)];
                
                [proportionSettingView addSubview:settingItemBtn];
            }
            
        }else{
            [settingItemBtn setBackgroundColor:[UIColor clearColor]];
        }
        NSLog(@"settingItemBtn.tag:%d",settingItemBtn.tag);
        [fragmentEditSettingView addSubview:settingItemBtn];
    }
    
    //支持的文件类型
    UILabel *supportFileTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, fragmentEditSettingView.frame.origin.y + fragmentEditSettingView.frame.size.height + 30 , 200, 31)];
    supportFileTypeLabel.font = [UIFont systemFontOfSize:18];
    supportFileTypeLabel.backgroundColor = [UIColor clearColor];
    supportFileTypeLabel.textColor = [UIColor whiteColor];
    supportFileTypeLabel.textAlignment = NSTextAlignmentLeft;
    supportFileTypeLabel.text = @"编辑支持的文件类型:";
    supportFileTypeLabel.layer.masksToBounds = YES;
    [settingScrollView addSubview:supportFileTypeLabel];
    
    if(supportFiletypeView.superview){
        [supportFiletypeView removeFromSuperview];
        supportFiletypeView = nil;
    }
    supportFiletypeView = [[UIView alloc] initWithFrame:CGRectMake(0, supportFileTypeLabel.frame.size.height + supportFileTypeLabel.frame.origin.y + 10, settingScrollView.frame.size.width, 40)];
    supportFiletypeView.backgroundColor = [UIColor clearColor];
    supportFiletypeView.layer.cornerRadius = 3.0;
    supportFiletypeView.layer.borderWidth = 1;
    supportFiletypeView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    supportFiletypeView.layer.masksToBounds = YES;
    [settingScrollView addSubview:supportFiletypeView];
    
    for (int i = 0 ; i<3 ; i++) {
        UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingItemBtn setBackgroundColor:[UIColor clearColor]];
        
        if(_xpkSDK.editConfiguration.supportFileType == i){
            [settingItemBtn setSelected:YES];
        }else{
            [settingItemBtn setSelected:NO];
        }
        [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
        [settingItemBtn addTarget:self action:@selector(supportFiletypeChildBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        settingItemBtn.layer.cornerRadius = 4.0;
        settingItemBtn.layer.masksToBounds = YES;
        settingItemBtn.tag = i+1;
        switch (i) {
                
            case 0:
            {
                [settingItemBtn setTitle:@"仅视频" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(5, 5, 90, 30);
                
            }
                break;
            case 1:
                [settingItemBtn setTitle:@"仅图片" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(100, 5, 90, 30);
                
                break;
            case 2:
            {
                [settingItemBtn setTitle:@"视频+图片" forState:UIControlStateNormal];
                settingItemBtn.frame = CGRectMake(190, 5, 120, 30);
                
            }
                break;
            default:
                break;
        }
        [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, settingItemBtn.frame.size.width - 20)];
        
        [supportFiletypeView addSubview:settingItemBtn];
    }
    
    //导出设置
    UILabel *exportSettingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, supportFiletypeView.frame.origin.y + supportFiletypeView.frame.size.height + 30 , 200, 31)];
    exportSettingLabel.font = [UIFont systemFontOfSize:18];
    exportSettingLabel.backgroundColor = [UIColor clearColor];
    exportSettingLabel.textColor = [UIColor whiteColor];
    exportSettingLabel.textAlignment = NSTextAlignmentLeft;
    exportSettingLabel.text = @"视频导出设置:";
    exportSettingLabel.layer.masksToBounds = YES;
    [settingScrollView addSubview:exportSettingLabel];
    
    
    
    
    
    
    if(videoMaxDurationView.superview){
        [videoMaxDurationView removeFromSuperview];
        videoMaxDurationView = nil;
    }
    videoMaxDurationView = [[UIView alloc] initWithFrame:CGRectMake(0, exportSettingLabel.frame.size.height + exportSettingLabel.frame.origin.y + 25, settingScrollView.frame.size.width, 60)];
    videoMaxDurationView.backgroundColor = [UIColor clearColor];
    videoMaxDurationView.layer.cornerRadius = 3.0;
    videoMaxDurationView.layer.borderWidth = 1;
    videoMaxDurationView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    videoMaxDurationView.layer.masksToBounds = YES;
    [settingScrollView addSubview:videoMaxDurationView];
    
    {
        if(videoMaxDurationBtn.superview){
            [videoMaxDurationBtn removeFromSuperview];
            videoMaxDurationBtn = nil;
        }
        videoMaxDurationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [videoMaxDurationBtn setBackgroundColor:UIColorFromRGB(0x27262c)];
        [videoMaxDurationBtn setTitle:@"导出时长限制" forState:UIControlStateNormal];
        [videoMaxDurationBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [videoMaxDurationBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateSelected];
        [videoMaxDurationBtn setImage:[UIImage imageNamed:@"启用勾_"] forState:UIControlStateNormal];
        [videoMaxDurationBtn setImage:[UIImage imageNamed:@"不启用_"] forState:UIControlStateSelected];
        [videoMaxDurationBtn addTarget:self action:@selector(videoMaxDurationTouch:) forControlEvents:UIControlEventTouchUpInside];
        videoMaxDurationBtn.frame = CGRectMake(20, exportSettingLabel.frame.size.height + exportSettingLabel.frame.origin.y + 10, 140, 30);
        videoMaxDurationBtn.layer.masksToBounds = YES;
        [videoMaxDurationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, videoMaxDurationBtn.frame.size.width - 20)];
        [videoMaxDurationBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 1)];
        [settingScrollView addSubview:videoMaxDurationBtn];
        
        exportMaxDurationSettingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20 , 160, 31)];
        exportMaxDurationSettingLabel.font = [UIFont systemFontOfSize:18];
        exportMaxDurationSettingLabel.backgroundColor = [UIColor clearColor];
        exportMaxDurationSettingLabel.textColor = [UIColor whiteColor];
        exportMaxDurationSettingLabel.textAlignment = NSTextAlignmentLeft;
        exportMaxDurationSettingLabel.text = @"视频导出最大时长:";
        exportMaxDurationSettingLabel.layer.masksToBounds = YES;
        [videoMaxDurationView addSubview:exportMaxDurationSettingLabel];
        
        exportVideoMaxDurationField = [[UITextField alloc] init];
        exportVideoMaxDurationField.frame = CGRectMake(180, exportMaxDurationSettingLabel.frame.origin.y, videoMaxDurationView.frame.size.width - 190, 31);
        exportVideoMaxDurationField.layer.borderColor    = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        exportVideoMaxDurationField.layer.borderWidth    = 1;
        exportVideoMaxDurationField.layer.cornerRadius   = 3;
        exportVideoMaxDurationField.layer.masksToBounds  = YES;
        exportVideoMaxDurationField.delegate             = self;
        exportVideoMaxDurationField.returnKeyType        = UIReturnKeyDone;
        exportVideoMaxDurationField.textAlignment        = NSTextAlignmentCenter;
        exportVideoMaxDurationField.textColor            = UIColorFromRGB(0xffffff);
        exportVideoMaxDurationField.placeholder          = @"默认是0,不限制";
        [videoMaxDurationView addSubview:exportVideoMaxDurationField];
    }
    
    
    
    //片尾设置
    {
        if(endPicDisabledBtn.superview){
            [endPicDisabledBtn removeFromSuperview];
            endPicDisabledBtn = nil;
        }
        endPicDisabledBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [endPicDisabledBtn setBackgroundColor:UIColorFromRGB(0x27262c)];
        [endPicDisabledBtn setTitle:@"片尾水印" forState:UIControlStateNormal];
        [endPicDisabledBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [endPicDisabledBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateSelected];
        [endPicDisabledBtn setImage:[UIImage imageNamed:@"启用勾_"] forState:UIControlStateNormal];
        [endPicDisabledBtn setImage:[UIImage imageNamed:@"不启用_"] forState:UIControlStateSelected];
        [endPicDisabledBtn addTarget:self action:@selector(endPicDisabledSwitchBtnValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        endPicDisabledBtn.frame = CGRectMake(20,  videoMaxDurationView.frame.origin.y + videoMaxDurationView.frame.size.height + 10, 100, 30);
        endPicDisabledBtn.layer.masksToBounds = YES;
        NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
        [fontAttributes setObject:endPicDisabledBtn.titleLabel.font forKey:NSFontAttributeName];
        CGRect titleContentRect = [fragmentEditBtn.titleLabel.text boundingRectWithSize:CGSizeMake(endPicDisabledBtn.frame.size.width, endPicDisabledBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
        [endPicDisabledBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, endPicDisabledBtn.frame.size.width - 20)];
        [endPicDisabledBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, endPicDisabledBtn.frame.size.width - titleContentRect.size.width - 30)];
        [settingScrollView addSubview:endPicDisabledBtn];
    }
    
    
    if(waterSettingView.superview){
        [waterSettingView removeFromSuperview];
        waterSettingView = nil;
    }
    waterSettingView = [[UIView alloc] initWithFrame:CGRectMake(5,endPicDisabledBtn.frame.origin.y + endPicDisabledBtn.frame.size.height + 25, settingScrollView.frame.size.width - 10, 40 + 25 + 40)];
    waterSettingView.backgroundColor = [UIColor clearColor];
    waterSettingView.layer.cornerRadius = 3.0;
    waterSettingView.layer.borderWidth = 1;
    waterSettingView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    waterSettingView.layer.masksToBounds = YES;
    [settingScrollView addSubview:waterSettingView];
    
    for (int k = 0; k<2; k++) {
        UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingItemBtn setBackgroundColor:[UIColor clearColor]];
        
        if(!_xpkSDK.exportConfiguration.waterDisabled){
            if(_xpkSDK.exportConfiguration.waterText.length>0 && k == 1){
                [settingItemBtn setSelected:YES];
            }
            if(_xpkSDK.exportConfiguration.waterImage && k == 0){
                [settingItemBtn setSelected:YES];
            }
        }
        
        [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
        [settingItemBtn addTarget:self action:@selector(waterTypeSettingsBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        settingItemBtn.frame = CGRectMake((waterSettingView.frame.size.width/2.0) * k +((waterSettingView.frame.size.width/2.0) - 70)/2.0, 5+15, 70, 30);
        
        settingItemBtn.layer.cornerRadius = 4.0;
        settingItemBtn.layer.masksToBounds = YES;
        settingItemBtn.tag = k+1;
        switch (k) {
            case 0:
                [settingItemBtn setTitle:@"图片" forState:UIControlStateNormal];
                break;
            case 1:
                [settingItemBtn setTitle:@"文字" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
        [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
        CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
        [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, settingItemBtn.frame.size.width - 20)];
        [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -(settingItemBtn.frame.size.width - titleContentRect.size.width), 0, 0)];
        
        [waterSettingView addSubview:settingItemBtn];
    }
    
    
    if(waterPositionView.superview){
        [waterPositionView removeFromSuperview];
        waterPositionView = nil;
    }
    waterPositionView = [[UIView alloc] initWithFrame:CGRectMake(5, 15 + 40, waterSettingView.frame.size.width - 10, 40)];
    waterPositionView.backgroundColor = [UIColor clearColor];
    waterPositionView.layer.cornerRadius = 3.0;
    waterPositionView.layer.borderWidth = 1;
    waterPositionView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    waterPositionView.layer.masksToBounds = YES;
    [waterSettingView addSubview:waterPositionView];
    
    
    if(waterSettingBtn.superview){
        [waterSettingBtn removeFromSuperview];
        waterSettingBtn = nil;
    }
    waterSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [waterSettingBtn setBackgroundColor:UIColorFromRGB(0x27262c)];
    [waterSettingBtn setTitle:@"视频水印" forState:UIControlStateNormal];
    [waterSettingBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [waterSettingBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateSelected];
    [waterSettingBtn setImage:[UIImage imageNamed:@"启用勾_"] forState:UIControlStateNormal];
    [waterSettingBtn setImage:[UIImage imageNamed:@"不启用_"] forState:UIControlStateSelected];
    [waterSettingBtn addTarget:self action:@selector(waterSettingBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    waterSettingBtn.frame = CGRectMake(20, waterSettingView.frame.origin.y - 15, 100, 30);
    waterSettingBtn.layer.masksToBounds = YES;
    NSMutableDictionary *waterAttributes = [[NSMutableDictionary alloc] init];
    [waterAttributes setObject:waterSettingBtn.titleLabel.font forKey:NSFontAttributeName];
    CGRect waterContentRect = [waterSettingBtn.titleLabel.text boundingRectWithSize:CGSizeMake(waterSettingBtn.frame.size.width, waterSettingBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:waterAttributes context:nil];
    [waterSettingBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, waterSettingBtn.frame.size.width - 20)];
    [waterSettingBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, waterSettingBtn.frame.size.width - waterContentRect.size.width - 30)];
    
    [settingScrollView addSubview:waterSettingBtn];
    
    
    for (int k = 0; k<4; k++) {
        UIButton *settingItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingItemBtn setBackgroundColor:[UIColor clearColor]];
        
        if(_xpkSDK.editConfiguration.customizationPROPORTIONTYPE == k){
            [settingItemBtn setSelected:YES];
        }else{
            [settingItemBtn setSelected:NO];
        }
        [settingItemBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [settingItemBtn setTitleColor:UIColorFromRGB(0x7e8181) forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选默认"] forState:UIControlStateNormal];
        [settingItemBtn setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateSelected];
        [settingItemBtn addTarget:self action:@selector(waterPositionSettingsBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        settingItemBtn.frame = CGRectMake(75 * k, 5, 70, 30);
        
        settingItemBtn.layer.cornerRadius = 4.0;
        settingItemBtn.layer.masksToBounds = YES;
        settingItemBtn.tag = k+1;
        switch (k) {
            case 0:
                [settingItemBtn setTitle:@"左上" forState:UIControlStateNormal];
                break;
            case 1:
                [settingItemBtn setTitle:@"左下" forState:UIControlStateNormal];
                break;
            case 2:
                [settingItemBtn setTitle:@"右上" forState:UIControlStateNormal];
                break;
            case 3:
                [settingItemBtn setTitle:@"右下" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        NSMutableDictionary *fontAttributes = [[NSMutableDictionary alloc] init];
        [fontAttributes setObject:settingItemBtn.titleLabel.font forKey:NSFontAttributeName];
        CGRect titleContentRect = [settingItemBtn.titleLabel.text boundingRectWithSize:CGSizeMake(settingItemBtn.frame.size.width, settingItemBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil];
        [settingItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5.5, 1, 5.5, settingItemBtn.frame.size.width - 20)];
        [settingItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -(settingItemBtn.frame.size.width - titleContentRect.size.width), 0, 0)];
        
        [waterPositionView addSubview:settingItemBtn];
    }
    
    
    [settingScrollView setContentSize:CGSizeMake(settingScrollView.frame.size.width,waterSettingView.frame.origin.y + waterSettingView.frame.size.height + 20)];
    
    UIButton *cancelSettingBtn;
    UIButton *saveSettingBtn;
    
    cancelSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelSettingBtn setBackgroundImage:[self ImageWithColor:[UIColor whiteColor] cornerRadius:1] forState:UIControlStateNormal];
    [cancelSettingBtn setBackgroundImage:[self ImageWithColor:[UIColor whiteColor] cornerRadius:1] forState:UIControlStateSelected];
    [cancelSettingBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelSettingBtn setTitleColor:UIColorFromRGB(0x0e0e10) forState:UIControlStateNormal];
    [cancelSettingBtn addTarget:self action:@selector(cancelSettingBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    cancelSettingBtn.frame = CGRectMake(settingScrollView.frame.origin.x, settingView.frame.size.height - 50, settingScrollView.frame.size.width/2.0-5, 40);
    cancelSettingBtn.layer.cornerRadius = 3.0;
    cancelSettingBtn.layer.masksToBounds = YES;
    [settingView addSubview:cancelSettingBtn];
    
    saveSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveSettingBtn setBackgroundImage:[self ImageWithColor:[UIColor whiteColor] cornerRadius:1] forState:UIControlStateNormal];
    [saveSettingBtn setBackgroundImage:[self ImageWithColor:[UIColor whiteColor] cornerRadius:1] forState:UIControlStateSelected];
    [saveSettingBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveSettingBtn setTitleColor:UIColorFromRGB(0x0e0e10) forState:UIControlStateNormal];
    [saveSettingBtn addTarget:self action:@selector(saveSettingBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    saveSettingBtn.frame = CGRectMake(cancelSettingBtn.frame.origin.x + cancelSettingBtn.frame.size.width+10, settingView.frame.size.height - 50 , settingScrollView.frame.size.width/2.0-5, 40);
    saveSettingBtn.layer.cornerRadius = 3.0;
    saveSettingBtn.layer.masksToBounds = YES;
    
    [settingView addSubview:saveSettingBtn];
    [self.navigationController.view addSubview:settingView];
    settingView.alpha = 0.0;
}

- (void)settingBtnTouch:(UIButton *)sender{
    
    settingView.alpha = 1.0;
    _editConfiguration.enableWizard        = _xpkSDK.editConfiguration.enableWizard;
    _editConfiguration.customizationTRIM   = _xpkSDK.editConfiguration.customizationTRIM;
    _editConfiguration.customizationSPLIT  = _xpkSDK.editConfiguration.customizationSPLIT;
    _editConfiguration.customizationEDIT   = _xpkSDK.editConfiguration.customizationEDIT;
    _editConfiguration.customizationSPEEDCONTROL   = _xpkSDK.editConfiguration.customizationSPEEDCONTROL;
    _editConfiguration.customizationCOPY           = _xpkSDK.editConfiguration.customizationCOPY;
    _editConfiguration.customizationSORT           = _xpkSDK.editConfiguration.customizationSORT;
    _editConfiguration.customizationPROPORTION             = _xpkSDK.editConfiguration.customizationPROPORTION;
    _editConfiguration.customizationIMAGE_DURATION_CONTROL = _xpkSDK.editConfiguration.customizationIMAGE_DURATION_CONTROL;
    _editConfiguration.customizationFRAGMENTEDIT           = _xpkSDK.editConfiguration.customizationFRAGMENTEDIT;
    
    _editConfiguration.customizationMUSIC      = _xpkSDK.editConfiguration.customizationMUSIC;
    _editConfiguration.customizationDUBBING    = _xpkSDK.editConfiguration.customizationDUBBING;
    _editConfiguration.customizationSUBTITLE   = _xpkSDK.editConfiguration.customizationSUBTITLE;
    _editConfiguration.customizationFILTER     = _xpkSDK.editConfiguration.customizationFILTER;
    _editConfiguration.customizationEFFECT     = _xpkSDK.editConfiguration.customizationEFFECT;
    
    _exportConfiguration.endPicDisabled          = _xpkSDK.exportConfiguration.endPicDisabled;
    _exportConfiguration.waterDisabled           = _xpkSDK.exportConfiguration.waterDisabled;
    _exportConfiguration.videoMaxDuration        = _xpkSDK.exportConfiguration.videoMaxDuration;
    
    _editConfiguration.customizationTEXTTITLE        = _xpkSDK.editConfiguration.customizationTEXTTITLE;
    _editConfiguration.supportFileType               = _xpkSDK.editConfiguration.supportFileType;
    _editConfiguration.supportDeviceOrientation      = _xpkSDK.editConfiguration.supportDeviceOrientation;
    
    
    wizardLabel.text = _xpkSDK.editConfiguration.enableWizard ?  @"开启向导模式": @"关闭向导模式";
    for (UIButton *itemBtn in supportFiletypeView.subviews) {
        if(itemBtn.tag-1 == _editConfiguration.supportFileType){
            [itemBtn setSelected:YES];
        }else{
            [itemBtn setSelected:NO];
        }
    }
    
    _editConfiguration.customizationMUSICTYPE = _xpkSDK.editConfiguration.customizationMUSICTYPE;
    for (UIButton *itemBtn in musicSettingView.subviews) {
        if(itemBtn.tag-1 == _editConfiguration.customizationMUSICTYPE){
            [itemBtn setSelected:YES];
        }else{
            [itemBtn setSelected:NO];
        }
    }
    _editConfiguration.customizationFILTERTYPE = _xpkSDK.editConfiguration.customizationFILTERTYPE;
    for (UIButton *itemBtn in filterSettingView.subviews) {
        if(itemBtn.tag-1 == _editConfiguration.customizationFILTERTYPE){
            [itemBtn setSelected:YES];
        }else{
            [itemBtn setSelected:NO];
        }
    }
    
    [videoMaxDurationBtn setSelected:(_xpkSDK.exportConfiguration.videoMaxDuration ==0 ? NO : YES)];
    if(videoMaxDurationBtn.selected){
        exportVideoMaxDuration = 0;//不限制
        exportVideoMaxDurationField.enabled = NO;
        exportMaxDurationSettingLabel.textColor = UIColorFromRGB(0x7e8181);
        exportVideoMaxDurationField.layer.borderColor = [UIColorFromRGB(0x7e8181) CGColor];
    }else{
        exportVideoMaxDurationField.enabled = YES;
        exportVideoMaxDuration = [exportVideoMaxDurationField.text intValue];
        exportMaxDurationSettingLabel.textColor = [UIColor whiteColor];
        exportVideoMaxDurationField.layer.borderColor = [UIColorFromRGB(0xffffff) CGColor];
    }
    [waterSettingBtn setSelected:(!_xpkSDK.exportConfiguration.waterDisabled ? NO : YES)];
    if(_exportConfiguration.waterDisabled){
        for (UIButton *itemBtn in waterSettingView.subviews) {
            [itemBtn setEnabled:NO];
        }
    }
}

#pragma mark- 是否打开向导模式
- (void)wizardValueChanged:(UISwitch *)sender{
    if (!sender.on) {
        _xpkSDK.editConfiguration.enableWizard = false;
        
        wizardLabel.text = @"关闭向导模式";
    }else{
        fragmentEditBtn.enabled = YES;
        _xpkSDK.editConfiguration.enableWizard = true;
        wizardLabel.text = @"开启向导模式";
    }
}

- (void)settingScrollViewChildBtnTouch:(UIButton *)sender{
    switch (sender.tag-1) {
        case 0:
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationMUSIC = true;
            }else{
                _xpkSDK.editConfiguration.customizationMUSIC = false;
            }
        }
            break;
        case 1:
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationFILTER = true;
            }else{
                _xpkSDK.editConfiguration.customizationFILTER = false;
            }
        }
            break;
        case 2:
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationDUBBING = true;
            }else{
                _xpkSDK.editConfiguration.customizationDUBBING = false;
            }
        }
            break;
            
        case 3:
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationSUBTITLE = true;
            }else{
                _xpkSDK.editConfiguration.customizationSUBTITLE = false;
            }
        }
            break;
        case 4:
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationEFFECT = true;
            }else{
                _xpkSDK.editConfiguration.customizationEFFECT = false;
            }
        }
            break;
        default:
            break;
    }
    sender.selected = !sender.selected;
}

#pragma mark- 片段编辑功能设置
-(void)fragmentEditChildBtnTouch:(UIButton *)sender{
    if(!_xpkSDK.editConfiguration.customizationFRAGMENTEDIT){
        return;
    }
    switch (sender.tag-1) {
        case 0://@"截 取"
        {
            
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationTRIM = true;
            }else{
                _xpkSDK.editConfiguration.customizationTRIM = false;
            }
        }
            break;
        case 1://@"分 割"
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationSPLIT = true;
            }else{
                _xpkSDK.editConfiguration.customizationSPLIT = false;
            }
        }
            break;
        case 2://@"裁切+旋转"
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationEDIT = true;
            }else{
                _xpkSDK.editConfiguration.customizationEDIT = false;
            }
        }
            break;
        case 3://@"调 速"
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationSPEEDCONTROL = true;
            }else{
                _xpkSDK.editConfiguration.customizationSPEEDCONTROL = false;
            }
        }
            break;
        case 4://@"调整图片时长"
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationIMAGE_DURATION_CONTROL = true;
            }else{
                _xpkSDK.editConfiguration.customizationIMAGE_DURATION_CONTROL = false;
            }
        }
            break;
        case 5://@"复 制"
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationCOPY = true;
            }else{
                _xpkSDK.editConfiguration.customizationCOPY = false;
            }
            break;
        }
        case 6://@"调 序"
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationSORT = true;
            }else{
                _xpkSDK.editConfiguration.customizationSORT = false;
            }
        }
            break;
        case 7://@"文字版"
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationTEXTTITLE = true;
            }else{
                _xpkSDK.editConfiguration.customizationTEXTTITLE = false;
            }
        }
            break;
        case 8://@"画面比例"
        {
            if(sender.selected){
                _xpkSDK.editConfiguration.customizationPROPORTION = true;
            }else{
                _xpkSDK.editConfiguration.customizationPROPORTION = false;
            }
        }
            break;
            
        default:
            break;
    }
    sender.selected = !sender.selected;
}

-(void)fragmentEditBtnTouch:(UIButton *)sender{
    if(sender.selected){
        _xpkSDK.editConfiguration.customizationFRAGMENTEDIT = true;
        _xpkSDK.editConfiguration.customizationTRIM           = true;
        _xpkSDK.editConfiguration.customizationSPLIT          = true;
        _xpkSDK.editConfiguration.customizationEDIT           = true;
        _xpkSDK.editConfiguration.customizationSPEEDCONTROL   = true;
        _xpkSDK.editConfiguration.customizationCOPY           = true;
        _xpkSDK.editConfiguration.customizationSORT           = true;
        _xpkSDK.editConfiguration.customizationPROPORTION     = true;
        _xpkSDK.editConfiguration.customizationIMAGE_DURATION_CONTROL = true;
        for (UIButton *itemBtn in fragmentEditSettingView.subviews) {
            if([itemBtn isKindOfClass:[UIButton class]]){
                [itemBtn setSelected:NO];
                //                [itemBtn setEnabled:YES];
            }
        }
        
    }else{
        _xpkSDK.editConfiguration.customizationFRAGMENTEDIT   = false;
        _xpkSDK.editConfiguration.customizationTRIM           = false;
        _xpkSDK.editConfiguration.customizationSPLIT          = false;
        _xpkSDK.editConfiguration.customizationEDIT           = false;
        _xpkSDK.editConfiguration.customizationSPEEDCONTROL   = false;
        _xpkSDK.editConfiguration.customizationCOPY           = false;
        _xpkSDK.editConfiguration.customizationSORT           = false;
        _xpkSDK.editConfiguration.customizationPROPORTION     = false;
        _xpkSDK.editConfiguration.customizationIMAGE_DURATION_CONTROL = false;
        for (UIButton *itemBtn in fragmentEditSettingView.subviews) {
            if([itemBtn isKindOfClass:[UIButton class]]){
                [itemBtn setSelected:YES];
                //                [itemBtn setEnabled:NO];
            }
        }
    }
    sender.selected = !sender.selected;
}

#pragma mark- 音乐方式设置
- (void)msettingItemChildBtnTouch:(UIButton *)sender{
    
    switch (sender.tag) {
        case 1:
            _xpkSDK.editConfiguration.customizationMUSICTYPE = RDMUSICTYPE_FIRST;
            break;
        case 2:
            _xpkSDK.editConfiguration.customizationMUSICTYPE = RDMUSICTYPE_SECOND;
            break;
        default:
            break;
    }
    
    for (UIButton *itemBtn in musicSettingView.subviews) {
        if([itemBtn isKindOfClass:[UIButton class]]){
            if(itemBtn.tag == sender.tag){
                [itemBtn setSelected:YES];
            }else{
                [itemBtn setSelected:NO];
            }
        }
    }
    
}
#pragma mark- 滤镜方式设置
- (void)fsettingItemChildBtnTouch:(UIButton *)sender{
    
    switch (sender.tag) {
        case 1:
            _xpkSDK.editConfiguration.customizationFILTERTYPE = RDFILTERTYPE_FRIST;
            break;
        case 2:
            _xpkSDK.editConfiguration.customizationFILTERTYPE = RDFILTERTYPE_SECOND;
            break;
        default:
            break;
    }
    
    for (UIButton *itemBtn in filterSettingView.subviews) {
        if([itemBtn isKindOfClass:[UIButton class]]){
            if(itemBtn.tag == sender.tag){
                [itemBtn setSelected:YES];
            }else{
                [itemBtn setSelected:NO];
            }
        }
    }
    
}
- (void)videoMaxDurationTouch:(UIButton *)sender{
    if(!sender.selected){
        exportVideoMaxDuration = 0;//不限制
        exportVideoMaxDurationField.enabled = NO;
        exportMaxDurationSettingLabel.textColor = UIColorFromRGB(0x7e8181);
        exportVideoMaxDurationField.layer.borderColor = [UIColorFromRGB(0x7e8181) CGColor];
    }else{
        exportVideoMaxDurationField.enabled = YES;
        exportVideoMaxDuration = [exportVideoMaxDurationField.text intValue];
        exportMaxDurationSettingLabel.textColor = [UIColor whiteColor];
        exportVideoMaxDurationField.layer.borderColor = [UIColorFromRGB(0xffffff) CGColor];
    }
    sender.selected = !sender.selected;
}

#pragma mark- 是否启用片尾
- (void)endPicDisabledSwitchBtnValueChanged:(UISwitch *)sender{
    if(sender.selected){
        _xpkSDK.exportConfiguration.endPicDisabled = false;
    }else{
        _xpkSDK.exportConfiguration.endPicDisabled = true;
    }
    sender.selected = !sender.selected;
}

#pragma mark- 水印设置
- (void)waterSettingBtnTouch:(UIButton *)sender{
    
    if(!sender.selected){
        _xpkSDK.exportConfiguration.waterDisabled = true;
        for (UIButton *itemBtn in waterSettingView.subviews) {
            [itemBtn setEnabled:NO];
        }
    }else{
        _xpkSDK.exportConfiguration.waterDisabled = false;
        for (UIButton *itemBtn in waterSettingView.subviews) {
            [itemBtn setEnabled:YES];
        }
    }
    sender.selected = !sender.selected;
}
- (void)waterTypeSettingsBtnTouch:(UIButton *)sender{
    if(sender.tag == 1){
        _xpkSDK.exportConfiguration.waterImage = [UIImage imageNamed:@"water_LOGO"];
    }else{
        _xpkSDK.exportConfiguration.waterText = @"waterMark";
    }
    for (UIButton *itemBtn in waterSettingView.subviews) {
        if([itemBtn isKindOfClass:[UIButton class]]){
            if(itemBtn.tag == sender.tag){
                [itemBtn setSelected:YES];
            }else{
                [itemBtn setSelected:NO];
            }
        }
    }
}
//水印位置
- (void)waterPositionSettingsBtnTouch:(UIButton *)sender{
    for (UIButton *itemBtn in waterPositionView.subviews) {
        if([itemBtn isKindOfClass:[UIButton class]]){
            if(itemBtn.tag == sender.tag){
                [itemBtn setSelected:YES];
            }else{
                [itemBtn setSelected:NO];
            }
        }
        
        switch (sender.tag) {
            case 1:
                _xpkSDK.exportConfiguration.waterPosition = WATERPOSITION_LEFTTOP;
                break;
            case 2:
                _xpkSDK.exportConfiguration.waterPosition = WATERPOSITION_LEFTBOTTOM;
                break;
            case 3:
                _xpkSDK.exportConfiguration.waterPosition = WATERPOSITION_RIGHTTOP;
                break;
            case 4:
                _xpkSDK.exportConfiguration.waterPosition = WATERPOSITION_RIGHTBOTTOM;
                break;
                
            default:
                break;
        }
    }
}

#pragma mark- 视频画面比例设置
- (void)proportionSettingChildBtnTouch:(UIButton *)sender{
    
    switch (sender.tag) {
        case 1:
            _xpkSDK.editConfiguration.customizationPROPORTIONTYPE = RDPROPORTIONTYPE_AUDIO;
            break;
        case 2:
            _xpkSDK.editConfiguration.customizationPROPORTIONTYPE = RDPROPORTIONTYPE_LANDSCAPE;
            break;
        case 3:
            _xpkSDK.editConfiguration.customizationPROPORTIONTYPE = RDPROPORTIONTYPE_SQUARE;
            break;
        default:
            break;
    }
    
    for (UIButton *itemBtn in proportionSettingView.subviews) {
        if([itemBtn isKindOfClass:[UIButton class]]){
            if(itemBtn.tag == sender.tag){
                [itemBtn setSelected:YES];
            }else{
                [itemBtn setSelected:NO];
            }
        }
    }
    
}

#pragma mark- 编辑支持的文件类型设置
- (void)supportFiletypeChildBtnTouch:(UIButton *)sender{
    switch (sender.tag - 1) {
        case SUPPORT_ALL:
            _xpkSDK.editConfiguration.supportFileType = SUPPORT_ALL;
            break;
        case ONLYSUPPORT_VIDEO:
            _xpkSDK.editConfiguration.supportFileType = ONLYSUPPORT_VIDEO;
            break;
        case ONLYSUPPORT_IMAGE:
            _xpkSDK.editConfiguration.supportFileType = ONLYSUPPORT_IMAGE;
            break;
        default:
            break;
    }
    for (UIButton *itembtn in supportFiletypeView.subviews) {
        if(itembtn.tag == sender.tag){
            itembtn.selected = YES;
        }else{
            itembtn.selected = NO;
        }
    }
}

#pragma mark- 锁定方向
- (void)supportDeviceOrientationChildBtnTouch:(UIButton *)sender{
    switch (sender.tag - 1) {
        case UIINTERFACEORIENTATION_PORTRAIT:
            _xpkSDK.editConfiguration.supportDeviceOrientation = UIINTERFACEORIENTATION_PORTRAIT;
            break;
        case OUIINTERFACEORIENTATION_LANDSCAPE:
            _xpkSDK.editConfiguration.supportDeviceOrientation = OUIINTERFACEORIENTATION_LANDSCAPE;
            break;
        case UIINTERFACEORIENTATION_AUDIO:
            _xpkSDK.editConfiguration.supportDeviceOrientation = UIINTERFACEORIENTATION_AUDIO;
            break;
        default:
            break;
    }
    for (UIButton *itembtn in supportDeviceOrientationView.subviews) {
        if(itembtn.tag == sender.tag){
            itembtn.selected = YES;
        }else{
            itembtn.selected = NO;
        }
    }
}

- (void)settingScrollViewChildBtnSelectedForIndex:(int)index{
    UIButton *sender = [editSettingView viewWithTag:index];
    switch (sender.tag-1) {
        case 0:
        {
            if(!_xpkSDK.editConfiguration.customizationMUSIC){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 1:
        {
            if(!_xpkSDK.editConfiguration.customizationDUBBING){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 2:
        {
            if(!_xpkSDK.editConfiguration.customizationSUBTITLE){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 3:
        {
            if(!_xpkSDK.editConfiguration.customizationFILTER){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 4:
        {
            if(!_xpkSDK.editConfiguration.customizationEFFECT){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)fragmentEditChildBtnSelectedForIndex:(int)index{
    
    UIButton *sender = [fragmentEditSettingView viewWithTag:index];
    
    switch (sender.tag-1) {
        case 0:
        {
            if(!_xpkSDK.editConfiguration.customizationTRIM){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 1:
        {
            if(!_xpkSDK.editConfiguration.customizationSPLIT){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 2:
        {
            if(!_xpkSDK.editConfiguration.customizationEDIT){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 3:
        {
            if(!_xpkSDK.editConfiguration.customizationSPEEDCONTROL){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 4:
        {
            if(!_xpkSDK.editConfiguration.customizationIMAGE_DURATION_CONTROL){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 5:
        {
            if(!_xpkSDK.editConfiguration.customizationCOPY){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
        case 6:
        {
            if(!_xpkSDK.editConfiguration.customizationSORT){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
        case 7:
        {
            if(_xpkSDK.editConfiguration.customizationTEXTTITLE){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
        case 8:
        {
            if(!_xpkSDK.editConfiguration.customizationPROPORTION){
                sender.selected = YES;
            }else{
                sender.selected = NO;
            }
        }
            break;
            
        default:
            break;
    }
    [sender setEnabled:(!_xpkSDK.editConfiguration.customizationFRAGMENTEDIT ? NO : YES)];
}

- (void)cancelSettingBtnTouch:(UIButton *)sender{
    if(settingView){
        settingView.alpha = 0.0;
    }
    _xpkSDK.editConfiguration.enableWizard        = _editConfiguration.enableWizard;
    _xpkSDK.editConfiguration.customizationTRIM   = _editConfiguration.customizationTRIM;
    _xpkSDK.editConfiguration.customizationSPLIT  = _editConfiguration.customizationSPLIT;
    _xpkSDK.editConfiguration.customizationEDIT   = _editConfiguration.customizationEDIT;
    _xpkSDK.editConfiguration.customizationSPEEDCONTROL = _editConfiguration.customizationSPEEDCONTROL;
    _xpkSDK.editConfiguration.customizationCOPY         = _editConfiguration.customizationCOPY;
    _xpkSDK.editConfiguration.customizationSORT         = _editConfiguration.customizationSORT;
    _xpkSDK.editConfiguration.customizationIMAGE_DURATION_CONTROL   = _editConfiguration.customizationIMAGE_DURATION_CONTROL;
    _xpkSDK.editConfiguration.customizationFRAGMENTEDIT             = _editConfiguration.customizationFRAGMENTEDIT;
    _xpkSDK.editConfiguration.customizationPROPORTION               = _editConfiguration.customizationPROPORTION;
    
    _xpkSDK.editConfiguration.customizationMUSIC      = _editConfiguration.customizationMUSIC;
    _xpkSDK.editConfiguration.customizationDUBBING    = _editConfiguration.customizationDUBBING;
    _xpkSDK.editConfiguration.customizationSUBTITLE   = _editConfiguration.customizationSUBTITLE;
    _xpkSDK.editConfiguration.customizationFILTER     = _editConfiguration.customizationFILTER;
    _xpkSDK.editConfiguration.customizationEFFECT     = _editConfiguration.customizationEFFECT;
    
    _xpkSDK.exportConfiguration.endPicDisabled          = _exportConfiguration.endPicDisabled;
    _xpkSDK.exportConfiguration.waterDisabled           = _exportConfiguration.waterDisabled;
    _xpkSDK.exportConfiguration.videoMaxDuration        = _exportConfiguration.videoMaxDuration;
    _xpkSDK.editConfiguration.customizationTEXTTITLE        = _editConfiguration.customizationTEXTTITLE;
    _xpkSDK.editConfiguration.supportFileType               = _editConfiguration.supportFileType;
    
    _xpkSDK.editConfiguration.customizationMUSICTYPE        = _editConfiguration.customizationMUSICTYPE;
    _xpkSDK.editConfiguration.customizationFILTERTYPE       = _editConfiguration.customizationFILTERTYPE;
    _xpkSDK.editConfiguration.supportDeviceOrientation      = _editConfiguration.supportDeviceOrientation;
    
    for (int i = 0; i<editSettingView.subviews.count; i++) {
        [self settingScrollViewChildBtnSelectedForIndex:i+1];
    }
    for (int i = 0; i<fragmentEditSettingView.subviews.count; i++) {
        [self fragmentEditChildBtnSelectedForIndex:i+1];
    }
    [switchBtn setOn:(_xpkSDK.editConfiguration.enableWizard ? YES : NO)];
    [fragmentEditBtn setSelected:(_xpkSDK.editConfiguration.customizationFRAGMENTEDIT ? NO : YES)];
    [endPicDisabledBtn setSelected:(!_xpkSDK.exportConfiguration.endPicDisabled ? NO : YES)];
    
}

- (void)saveSettingBtnTouch:(UIButton *)sender{
    sender.selected = YES;
    if(settingView){
        settingView.alpha = 0.0;
    }
    
}
- (BOOL)isNumText:(NSString *)str{
    NSString * regex        = @"^\\d*$";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch            = [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.text.length>0){
        if([self isNumText:textField.text]){
            exportVideoMaxDuration = [textField.text intValue];
            [exportVideoMaxDurationField resignFirstResponder];
            return YES;
        }else {
            return NO;
        }
    }
    [exportVideoMaxDurationField resignFirstResponder];
    return YES;
}

//- (bool)isNumeric:(NSString *)str{
//    Pattern pattern = Pattern.compile("[0-9]*");
//    Matcher isNum = pattern.matcher(str);
//    if( !isNum.matches() ){
//        return false;
//    }
//    return true;
//}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if([self isNumText:textField.text]){
        exportVideoMaxDuration = [textField.text intValue];
        [exportVideoMaxDurationField resignFirstResponder];
    }else {
        exportVideoMaxDuration = 0;
    }
    _xpkSDK.exportConfiguration.videoMaxDuration = exportVideoMaxDuration;
    NSLog(@"maxDuration:%ld",_xpkSDK.exportConfiguration.videoMaxDuration);
}

#if 0
#pragma mark- XpkUISDK delegate
- (void)selectVideoAndImageResult:(UINavigationController *)nav callbackBlock:(void (^)(NSArray *))callbackBlock{
    _xpkSDK.addImagesCallbackBlock = nil;
    _xpkSDK.addVideosAndImagesCallbackBlock = callbackBlock;
    if([self checkCameraISOpen]){
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        
        sourceType                      = UIImagePickerControllerSourceTypePhotoLibrary;//相册库
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate                 = self;
        picker.allowsEditing            = NO;
        picker.sourceType               = sourceType;
        [nav presentViewController:picker animated:YES completion:nil];
    }
    
}

- (void)selectVideosResult:(UINavigationController *)nav callbackBlock:(void (^)(NSArray *))callbackBlock{
    _xpkSDK.addVideosCallbackBlock = callbackBlock;
    _xpkSDK.addImagesCallbackBlock = nil;
    _xpkSDK.addVideosAndImagesCallbackBlock = nil;
    
    
    if([self checkCameraISOpen]){
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        sourceType                      = UIImagePickerControllerSourceTypePhotoLibrary;//相册库
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate                 = self;
        picker.allowsEditing            = NO;
        picker.sourceType               = sourceType;
        [nav presentViewController:picker animated:YES completion:nil];
    }
    
    //    NSMutableArray *lists = [[NSMutableArray alloc] init];
    //
    //    NSURL *fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"testFile2" ofType:@"mov"]];
    //    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:fileUrl,kFILEURL,@(kRDFileVideo),kFILETYPE, nil];
    //    [lists addObject:params];
    //    _xpkSDK.addVideosCallbackBlock(lists);//添加视频后回调
}

- (void)selectImagesResult:(UINavigationController *)nav callbackBlock:(void (^)(NSArray *))callbackBlock{
    _xpkSDK.addVideosAndImagesCallbackBlock = nil;
    _xpkSDK.addVideosCallbackBlock = nil;
    _xpkSDK.addImagesCallbackBlock = callbackBlock;
    if([self checkCameraISOpen]){
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        sourceType                      = UIImagePickerControllerSourceTypePhotoLibrary;//相册库
        //UIVideoEditorController
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate                 = self;
        picker.allowsEditing            = NO;
        picker.sourceType               = sourceType;
        [nav presentViewController:picker animated:YES completion:nil];
    }
}

- (BOOL)checkCameraISOpen{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        NSString * errorMessage = @"用户拒绝访问相机,请在<隐私>中开启";
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"无法访问相机!"
                                                           message:errorMessage
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:@"取消", nil];
        alertView.tag = 2000;
        [alertView show];
        return NO;
    }
    
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(_xpkSDK.addVideosCallbackBlock){
        
        //添加视频
        
        NSMutableArray *lists = [[NSMutableArray alloc] init];
        
        NSURL *fileUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:fileUrl,kFILEURL,@(kRDFileVideo),kFILETYPE, nil];
        [lists addObject:params];
        _xpkSDK.addVideosCallbackBlock(lists);//添加视频后回调
        
    }else if(_xpkSDK.addVideosCallbackBlock){
        //添加图片
        NSMutableArray *lists = [[NSMutableArray alloc] init];
        UIImage *imageFullScreen  = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSURL *fileUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        
        NSData *imageDataFullScreen = UIImageJPEGRepresentation(imageFullScreen, 0.9);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fileFolderPath = [documentsDirectory stringByAppendingString:@"/TMPIMAGE"];
        if(![fileManager fileExistsAtPath:fileFolderPath]){
            [fileManager createDirectoryAtPath:fileFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *fileImagePath = [fileFolderPath stringByAppendingString:[NSString stringWithFormat:@"/has_image_%ld",(long)[fileUrl hash]]];
        if([fileManager fileExistsAtPath:fileImagePath]){
            [fileManager removeItemAtPath:fileImagePath error:nil];
        }
        [fileManager createFileAtPath:fileImagePath contents:imageDataFullScreen attributes:nil];
        NSLog(@"document:%@",fileImagePath);
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:fileImagePath,kFILEPATH,@(kRDFileImage),kFILETYPE, nil];
        [lists addObject:params];
        
        _xpkSDK.addImagesCallbackBlock(lists);//selectImageResult 回调
        
        
    }else{
        //添加图片
        NSMutableArray *lists = [[NSMutableArray alloc] init];
        UIImage *imageFullScreen  = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSURL *fileUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        
        NSData *imageDataFullScreen = UIImageJPEGRepresentation(imageFullScreen, 0.9);
        if(imageDataFullScreen){
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *fileFolderPath = [documentsDirectory stringByAppendingString:@"/TMPIMAGE"];
            if(![fileManager fileExistsAtPath:fileFolderPath]){
                [fileManager createDirectoryAtPath:fileFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *fileImagePath = [fileFolderPath stringByAppendingString:[NSString stringWithFormat:@"/has_image_%ld",(long)[fileUrl hash]]];
            if([fileManager fileExistsAtPath:fileImagePath]){
                [fileManager removeItemAtPath:fileImagePath error:nil];
            }
            [fileManager createFileAtPath:fileImagePath contents:imageDataFullScreen attributes:nil];
            NSLog(@"document:%@",fileImagePath);
            
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:fileImagePath,kFILEPATH,@(kRDFileImage),kFILETYPE, nil];
            [lists addObject:params];
        }else{
            NSURL *fileUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:fileUrl,kFILEURL,@(kRDFileVideo),kFILETYPE, nil];
            [lists addObject:params];
        }
        _xpkSDK.addVideosAndImagesCallbackBlock(lists);//selectImageResult 回调
    }
    
}

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

- (UIImage *)imageRotatedByDegrees:(UIImage *)cImage rotation:(float)rotation
{
    /*
     UIImageOrientationLeftMirrored,  // vertical flip
     UIImageOrientationRightMirrored,
     */
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,cImage.size.height, cImage.size.width)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotation));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, DEGREES_TO_RADIANS(rotation));
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-cImage.size.height / 2, -cImage.size.width / 2, cImage.size.height, cImage.size.width), [cImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

#endif

/**
 *  进入系统设置
 */
- (void)enterSystemSetting{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

#pragma mark 创建相册
-(void)createXpkUISDKAlbum{
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups=[[NSMutableArray alloc]init];
    
    __weak ViewController *weakSelf = self;
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         
         if (group)
         {
             [groups addObject:group];
         }
         else
         {
             BOOL haveHDRGroup = NO;
             
             for (ALAssetsGroup *gp in groups)
             {
                 NSString *name =[gp valueForProperty:ALAssetsGroupPropertyName];
                 
                 if ([name isEqualToString:PHOTO_ALBUM_NAME])
                 {
                     haveHDRGroup = YES;
                 }
             }
             //创建相簿
             if (!haveHDRGroup)
             {
                 [ weakSelf createAlbum];
                 haveHDRGroup = YES;
             }
         }
         
     }
                               failureBlock:nil];
    
    
}

-(void)createAlbum{
    
    // PHPhotoLibrary_class will only be non-nil on iOS 8.x.x
    Class PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");
    
    if (PHPhotoLibrary_class) {
        
        // iOS 8..x. . code that has to be called dynamically at runtime and will not link on iOS 7.x.x ...
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:PHOTO_ALBUM_NAME];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error creating album: %@", error);
            }else{
                NSLog(@"Created");
            }
        }];
    }else{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary addAssetsGroupAlbumWithName:PHOTO_ALBUM_NAME resultBlock:^(ALAssetsGroup *group) {
            NSLog(@"adding album:'Compressed Videos', success: %s", group.editable ? "YES" : "NO");
            
            if (group.editable == NO) {
            }
            
        } failureBlock:^(NSError *error) {
            NSLog(@"error adding album");
        }];
    }
}

- (UIImage *) ImageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    CGFloat minEdgeSize = cornerRadius * 2 + 1;
    CGRect rect = CGRectMake(0, 0, minEdgeSize, minEdgeSize);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = 0;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [roundedRect fill];
    [roundedRect stroke];
    [roundedRect addClip];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

@end
