//
//  PlayVideoController.m
//  XpkUISDKDemo
//
//  Created by emmet on 16/1/15.
//  Copyright © 2016年 XpkUISDKDemo. All rights reserved.
//

#import "PlayVideoController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "XpkUISDK.h"//引用头文件
#define PHOTO_ALBUM_NAME @"XpkUISDKDemo"
@interface PlayVideoController ()<RDPlayerDelegate>
{
    UIView                  *_playerView;
    UIView                  *_syncContainer;

    
    UIButton                *_playBtn;
    UIButton                *_savePhotosAlbumBtn;
    UIButton                *_deletedBtn;
    RDPlayer*    _player;
    UISlider* _slider;
}


@end

@implementation PlayVideoController
#define kHeight self.view.frame.size.height
#define kWidth  self.view.frame.size.width
#define MARK true

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initPlayerView];
    [self initPlayer];
    

}



- (void)initPlayer{
    
    _player = [[RDPlayer alloc] initWithURL:[NSURL fileURLWithPath:_outputPath] frame:CGRectMake(0, 0, _playerView.frame.size.width, _playerView.frame.size.height)];
    _player.delegate = self;
    [_playerView insertSubview:_player.view atIndex:0];
    [self performSelector:@selector(playWith) withObject:nil afterDelay:0.5];
    
}
- (void) playWith{
    [_player play];
}
- (void) initPlayerView{
    
    
    if(_playerView){
       
        [_playerView removeFromSuperview];
     
        _playerView = nil;
     
    }
    
    _playerView= [[UIView alloc]init];
    
    if(_deviceOrientation == UIInterfaceOrientationLandscapeRight || _deviceOrientation == UIInterfaceOrientationLandscapeLeft){
     
        _playerView.frame=CGRectMake(60, 0,[UIScreen mainScreen].bounds.size.width - 120, [UIScreen mainScreen].bounds.size.height - 66);
            
    
    }else{
    
        _playerView.frame=CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, ([UIScreen mainScreen].bounds.size.width));
    
    }
    
    _playerView.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:_playerView];


        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.layer.cornerRadius = 5;
        _playBtn.layer.masksToBounds = YES;
        _playBtn.backgroundColor = UIColorFromRGB(0x0e0e10);
        [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [_playBtn setTitle:@"暂停" forState:UIControlStateSelected];
        [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_playBtn];
        
        _savePhotosAlbumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _savePhotosAlbumBtn.backgroundColor = UIColorFromRGB(0x0e0e10);
        [_savePhotosAlbumBtn setTitle:@"保存到相册" forState:UIControlStateNormal];
        _savePhotosAlbumBtn.titleLabel.adjustsFontSizeToFitWidth =YES;
        [_savePhotosAlbumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_savePhotosAlbumBtn addTarget:self action:@selector(savePhotosAlbum) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_savePhotosAlbumBtn];
        _savePhotosAlbumBtn.layer.cornerRadius = 5;
        _savePhotosAlbumBtn.layer.masksToBounds = YES;
        
        _deletedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deletedBtn.backgroundColor = UIColorFromRGB(0x0e0e10);
        [_deletedBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deletedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_deletedBtn addTarget:self action:@selector(deletedVideo) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_deletedBtn];
        _deletedBtn.layer.cornerRadius = 5;
        _deletedBtn.layer.masksToBounds = YES;
        
        _playBtn.selected = YES;
        UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if(deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight){
            _playerView.frame = CGRectMake(60, 0, [UIScreen mainScreen].bounds.size.width - 120, [UIScreen mainScreen].bounds.size.height - 66);
        }else{
            _playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
        }
        _playBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-30, _playerView.frame.size.height, 60,40);
        _savePhotosAlbumBtn.frame = CGRectMake(10, _playerView.frame.size.height, 80,40);
        _deletedBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-90, _playerView.frame.size.height, 80,40);
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, _playerView.frame.origin.y + _playerView.frame.size.height + 50, _playerView.frame.size.width, 25)];
    _slider.backgroundColor = [UIColor clearColor];
    [_slider addTarget:self action:@selector(beginScrub:) forControlEvents:UIControlEventTouchDown];

    [_slider addTarget:self action:@selector(seektime:) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(seektime:) forControlEvents:UIControlEventTouchCancel];
    
    [self.view insertSubview:_slider aboveSubview:_playerView];

        [self.view bringSubviewToFront:_playerView];
}
static bool seek = false;
- (void) seektime: (UISlider *) sender{
    float value = sender.value;
    [_player seekToTime:value];
}
- (void)seektimesyncBlock{
    if (seek) {
        [_player play];
        seek = false;
    }

}
- (void) beginScrub:(UISlider*)sender{
    seek = true;

}

- (void)playerToEnd{
    [_player seekToTime:0];
    _playBtn.selected = NO;
}


- (void)currentTimeValue:(float)value{
//    NSLog(@"%f",value);
    if (!seek) {
        _slider.value = value;
    }
}

- (void)playVideo:(UIButton *)sender{
    sender.selected = !sender.selected;
    if(sender.selected){
        [_player play];
        
    }else{
        [_player pause];
    }
}

- (void)savePhotosAlbum{
    [self saveVideoToCameraRoll:_outputPath];
}
- (void)deletedVideo{
   
#if 0
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if([filemanager fileExistsAtPath:_outputPath]){
        NSError *error;
        BOOL suc = [filemanager removeItemAtPath:_outputPath error:&error];
        if(suc){
            [_player pause];
            [_playerView removeFromSuperview];
            _playerView = nil;
            [_playBtn removeFromSuperview];
            _playBtn = nil;
            [_savePhotosAlbumBtn removeFromSuperview];
            _savePhotosAlbumBtn = nil;
            [_deletedBtn removeFromSuperview];
            _deletedBtn = nil;
            
        }
    }
#endif
    [_player seekToTime:0];
    [_player play];

}

-(void) saveVideoToCameraRoll:(NSString *)path{
    if(_savePhotosAlbumBtn.selected){
        return;
    }
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    __weak PlayVideoController *weakSelf = self;
    
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path] completionBlock:^(NSURL *assetURL, NSError *error){
        
        if(error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"保存提示" message:[NSString stringWithFormat:@"保存到相册失败!"] delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            });
        }
        
        else {
            
            __block ALAssetsGroup* groupToAddTo;
            [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                   usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                       if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:PHOTO_ALBUM_NAME]) {
                                           groupToAddTo = group;
                                       }
                                   }
                                 failureBlock:^(NSError* error) {
                                 }];
            [library assetForURL:assetURL resultBlock:^(ALAsset *addAsset){
                BOOL suc=[groupToAddTo addAsset:addAsset];
                if (suc) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _savePhotosAlbumBtn.selected = YES;
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"保存提示" message:[NSString stringWithFormat:@"保存到相册成功!"] delegate:weakSelf cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
                        [alert show];
                    });
                    
                }
            }failureBlock:^(NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf performSelector:@selector(initPlayerView) withObject:nil afterDelay:0.0];
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"保存提示" message:[NSString stringWithFormat:@"保存到相册失败!"] delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                });
            }];
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"%s",__func__);
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    [_player pause];
//    [_player removeObserver:self forKeyPath:@"status" context:nil];
    _player = nil;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
