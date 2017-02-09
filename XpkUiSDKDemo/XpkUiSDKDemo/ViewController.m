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

#define PHOTO_ALBUM_NAME @"XpkUISDKDemo"
#define VideoAverageBitRate 2.5

NSString *const APPKEY = @"27eb1f31f0f52501";
NSString *const APPSECRET = @"3ac8a8b40ce5bd5c37642978ef097731TDgMqucwJLGDvj09ws+W82FH8K5E5H6onCA01GRnpc0BSFM1ih2nXeX5aHyRfjlZY5hbwHrXlyTcH3i3cDebjS//Q++L5M30pIHb4S/4W6gGO4rIzup6ImsxgHExwqy/k/08HScy8OSkjK67JlkaS3ivejvTZpMGlst/hizafT4JkrarYi3vSBmin2i+4kKc4BuJHNAfORV3JnJi52A/nbPhbSCulMUWAC/ccw+f1a5RBWY6ZMl4VB4hpCx87tvKpF9Ctzf0XuaoNWSWlYSAyNoAp1UhM5nlEk0nf2nzScTovrt4CfR1qq5vrifqMubvSfjAT4y4jck30YFyxRnJLXAcWPKoUisUCwhelVMc2o+4s+UlIBDtsm/5rhddUoPmWRBsKllAENGsCD1oRJMeRiA0Wr/EgZ+XNu6NMC3PrQcaw/HWaM1dwT4c3o2z9yXh3zokTvDVjR5SmX0ab19YanCEy4vlfobIaJoBFbIbzlfymJGnpkfoObHN9b7qjYwA";

@interface ViewController ()<UIActionSheetDelegate,UIAlertViewDelegate,XpkUISDKDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
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
    UIButton *btn;
    UIButton *cameraBtn;
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

- (void)addVideoWater{
    UIImage *water = [UIImage imageNamed:@"waterImage"];
    [_xpkSDK addImageWater:water waterRect:CGRectMake(0, 0, water.size.width, water.size.height)];
}

- (void)showPicker:(NSInteger)index{
    
    
    NSMutableArray *fileLists = [[NSMutableArray alloc] init];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testFile1" ofType:@"mov"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    [fileLists addObject:[AVURLAsset URLAssetWithURL:url options:opts]];
    NSString * exportPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/exportVideoFile.mp4"];
    
    [self initXpkSdk];
    
    if (index ==0) {
        
        __weak ViewController *weakSelf = self;
        [_xpkSDK editVideoWithSuperController:self assets:fileLists outputPath:exportPath callback:^(NSString *videoPath) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _exportVideoPath = videoPath;
                [weakSelf enterPlayView];
            });
        } cancel:^{
            
            [weakSelf cancelOutput];
            
        }];
        
        //设置视频输出码率
        [_xpkSDK setOutPutVideoAverageBitRate:VideoAverageBitRate];
        
        
    }else if(index ==1){
        
        __weak ViewController *weakSelf = self;
        [_xpkSDK editVideoWithSuperController:self assets:nil outputPath:exportPath callback:^(NSString *videoPath) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _exportVideoPath = videoPath;
                [weakSelf enterPlayView];
            });
        } cancel:^{
            
            [weakSelf cancelOutput];
            
        }];
        
        //设置视频输出码率
        [_xpkSDK setOutPutVideoAverageBitRate:VideoAverageBitRate];
        
    }else{
        
        __weak ViewController *weakSelf = self;
        
        //实例化XpkUiSDK对象（选择视频是需要扫描缓存文件“library/MyVideo”文件夹）
        [_xpkSDK editVideoWithSuperController:self foldertype:kFolderDocuments appAlbumCacheName:@"MyVideo" assets:nil outputPath:exportPath callback:^(NSString *videoPath) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _exportVideoPath = videoPath;
                [weakSelf enterPlayView];
            });
        } cancel:^{
            
            [weakSelf cancelOutput];
            
        }];
        
        //设置视频输出码率
        [_xpkSDK setOutPutVideoAverageBitRate:VideoAverageBitRate];
        
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
    [self viewDidLoad];
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
            [_xpkSDK cutVideo_withCutType:RDCutVideoReturnTypeTime];
        }else{
            [_xpkSDK cutVideo_withCutType:RDCutVideoReturnTypePath];
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
        if(deviceOrientation == UIInterfaceOrientationLandscapeLeft){
            _deviceOrientation = UIInterfaceOrientationLandscapeLeft;
        }else if(deviceOrientation == UIInterfaceOrientationLandscapeRight){
            _deviceOrientation = UIInterfaceOrientationLandscapeRight;
        }
        _functionListTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-44);
        
    }
    else if(deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        if(self.navigationController.visibleViewController == self){
            NSLog(@"纵向");
            self.navigationController.navigationBarHidden=NO;//emmet20160829
            self.navigationController.navigationBar.translucent=NO;
            [self.navigationController setNavigationBarHidden: NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
        
        _deviceOrientation = UIInterfaceOrientationPortrait;
        _functionListTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
        
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
        _xpkSDK.orientationLock      = YES;
        _xpkSDK.recordSizeType = RecordVideoTypeMixed;
        _xpkSDK.recordOrientation = RecordVideoOrientationAuto;
        _xpkSDK.deviceOrientation = _deviceOrientation;
        
        _xpkSDK.minDuration = 12.0;
        _xpkSDK.maxDuration = 30.0;
        //TODO:是否禁用片尾
        _xpkSDK.endWaterPicDisabled = NO;// default NO
        //TODO:设置到处视频结尾水印的用户名
        [_xpkSDK setEndWaterPicUserName:@"极录客"];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
        self.navigationController.navigationBarHidden = NO;
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else{
        self.navigationController.navigationBarHidden=NO;
        self.navigationController.navigationBar.translucent=NO;
        [self.navigationController setNavigationBarHidden: NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }

    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    self.title = @"iOS锐动视频编辑SDK";
  
    [self createXpkUISDKAlbum];
    
    
    
    _functionList = [[NSMutableArray alloc] init];
    
    NSMutableArray *functions_1 = [[NSMutableArray alloc] init];
    
    NSMutableArray *functions_2 = [[NSMutableArray alloc] init];
    NSMutableArray *functions_3 = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *functions_Dic1 = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *functions_Dic2 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *functions_Dic3 = [[NSMutableDictionary alloc] init];
    
    
    [functions_1 addObject:@"方式一:(混合,可切换)"];
    [functions_1 addObject:@"方式二:(非正方形录制)"];
    [functions_1 addObject:@"方式三:(正方形录制)"];
    
    [functions_Dic1 setObject:@"录制" forKey:@"title"];
    [functions_Dic1 setObject:functions_1 forKey:@"functionList"];
    
    [functions_2 addObject:@"方式一:直接进入编辑"];
    [functions_2 addObject:@"方式二:选择相册(不需要扫描)"];
    [functions_2 addObject:@"方式三:选择相册(需要扫描)"];
    
    [functions_Dic2 setObject:@"编辑" forKey:@"title"];
    [functions_Dic2 setObject:functions_2 forKey:@"functionList"];
    
    [functions_3 addObject:@"方式一:返回截取后的路径"];
    [functions_3 addObject:@"方式二:返回开始时间和结束时间"];
    [functions_3 addObject:@"方式三:自定义返回类型"];
    
    [functions_Dic3 setObject:@"截取" forKey:@"title"];
    [functions_Dic3 setObject:functions_3 forKey:@"functionList"];
    
    
    [_functionList addObject:functions_Dic1];
    [_functionList addObject:functions_Dic2];
    [_functionList addObject:functions_Dic3];
    
    CGRect rect;
    if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
        rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }else{
        rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    }
    
    _functionListTable = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _functionListTable.backgroundView = nil;
    _functionListTable.backgroundColor = [UIColor whiteColor];
    _functionListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _functionListTable.delegate = self;
    _functionListTable.dataSource = self;
    
    [self.view addSubview:_functionListTable];
    
}

- (void)recordVideo:(NSInteger)index{
    
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
    
    if(index == 0){
        
        //方式一（自适应尺寸）
        _xpkSDK.recordSizeType = RecordVideoTypeMixed;//设置输出视频是正方形还是长方形
        _xpkSDK.recordOrientation = RecordVideoOrientationAuto;//设置界面方向（竖屏还是横屏）
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
        _xpkSDK.recordSizeType = RecordVideoTypeNotSquare;//设置输出视频是正方形还是长方形
        _xpkSDK.recordOrientation = RecordVideoOrientationAuto;//设置界面方向（竖屏还是横屏）
        [_xpkSDK videoRecordWithSourceController:self
                                  cameraPosition:AVCaptureDevicePositionFront
                                       frameRate:30
                                         bitRate:(4 * 1000 * 1000)
                                      recordSize:CGSizeMake(960, 1280)
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
        _xpkSDK.recordSizeType = RecordVideoTypeSquare;
        _xpkSDK.recordOrientation = RecordVideoOrientationAuto;
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
}

- (void)cutVideo:(NSString *)path index:(NSInteger)index{
    
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
    
    
    [_xpkSDK cutVideoWithSuperController:self
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

- (void)editVideoWithPath:(NSString *)path {
    if(!(path.length>0)){
        return;
    }
    NSMutableArray *fileLists = [[NSMutableArray alloc] init];
    AVURLAsset *assets = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    [fileLists addObject:assets];
    
    __weak ViewController *weakSelf = self;
    //实例化XpkUiSDK对象
    NSString * exportPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/exportVideoFile.mp4"];
    
    [self initXpkSdk];
    
    [_xpkSDK editVideoWithSuperController:self assets:fileLists outputPath:exportPath callback:^(NSString *videoPath) {
        _exportVideoPath = videoPath;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
            if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
                if(self.navigationController.visibleViewController == self){
                    NSLog(@"横向");
                    self.navigationController.navigationBarHidden = YES;//emmet20160829
                    self.navigationController.navigationBar.translucent = YES;
                    [self.navigationController setNavigationBarHidden:YES];
                    [[UIApplication sharedApplication] setStatusBarHidden:YES];
                }
                _functionListTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                
            }
            else if(deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown){
                if(self.navigationController.visibleViewController == self){
                    NSLog(@"纵向");
                    self.navigationController.navigationBarHidden=NO;//emmet20160829
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
    [_xpkSDK setOutPutVideoAverageBitRate:VideoAverageBitRate];
    
}

- (void)cancelOutput{
    _xpkSDK = nil;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_functionList[section] objectForKey:@"title"];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        [self recordVideo:indexPath.row];
        
    }
    if(indexPath.section == 1){
        [self showPicker:indexPath.row];
        
    }
    if(indexPath.section == 2){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"testFile1" ofType:@"mov"];
        
        [self cutVideo:path index:indexPath.row];
        
    }
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
    NSMutableArray *lists = [[NSMutableArray alloc] init];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"testFile1" ofType:@"mov"]];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:fileUrl,kFILEURL,@(kRDFileVideo),kFILETYPE, nil];
    [lists addObject:params];
    _xpkSDK.addVideosCallbackBlock(lists);//添加视频后回调
}

- (void)selectImagesResult:(UINavigationController *)nav callbackBlock:(void (^)(NSArray *))callbackBlock{
    _xpkSDK.addVideosAndImagesCallbackBlock = nil;
    _xpkSDK.addImagesCallbackBlock = callbackBlock;
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

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *lists = [[NSMutableArray alloc] init];
    UIImage *imageFullScreen  = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *fileUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    
    if(imageFullScreen){
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
    }else{
        NSURL *fileUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:fileUrl,kFILEURL,@(kRDFileVideo),kFILETYPE, nil];
        [lists addObject:params];
        
    }
    
    if(_xpkSDK.addImagesCallbackBlock){
        _xpkSDK.addImagesCallbackBlock(lists);//selectImageResult 回调
    }else{
        _xpkSDK.addVideosAndImagesCallbackBlock(lists);//selectVideoAndImageResult 回调
        
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

@end
