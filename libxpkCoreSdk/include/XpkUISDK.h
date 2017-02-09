//
//  XpkUISDK.h
//  XpkUISDK
//
//  Created by emmet on 15/12/7.
//  Copyright © 2015年 XpkUISDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//#import "lame.h"

////! Project version number for XpkUISDK.
//FOUNDATION_EXPORT double XpkUISDKVersionNumber;
//
////! Project version string for XpkUISDK.
//FOUNDATION_EXPORT const unsigned char XpkUISDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <XpkUISDK/PublicHeader.h>


@protocol XpkUISDKDelegate <NSObject>

@optional
/*
 *如果需要自定义相册则需要实现此函数
 */
- (void)selectVideoAndImageResult:(UINavigationController *)nav callbackBlock:(void (^)(NSArray *lists))callbackBlock;

/*
 *如果需要自定义相册则需要实现此函数（添加视频）
 */
- (void)selectVideosResult:(UINavigationController *)nav callbackBlock:(void (^)(NSArray *lists))callbackBlock;

/*
 *如果需要自定义相册则需要实现此函数（添加图片）
 */
- (void)selectImagesResult:(UINavigationController *)nav callbackBlock:(void (^)(NSArray *lists))callbackBlock;


@end

typedef NS_ENUM(NSInteger,RDFileType){
    kRDFileVideo,
    kRDFileImage,
} ;

static NSString *kFILEURL = @"kFILEURL";
static NSString *kFILEPATH = @"kFILEPATH";
static NSString *kFILETYPE = @"kFILETYPE";

@interface XpkUISDK : NSObject

@property (nonatomic,assign)id<XpkUISDKDelegate> delegate;


/*
 *初始化
 */
typedef NS_ENUM(NSInteger, RDDeviceOrientation){
    RDDeviceOrientationUnknown,
    RDDeviceOrientationPortrait,
    RDDeviceOrientationLandscape
};
typedef NS_ENUM(NSInteger, RDCutVideoReturnType){
    RDCutVideoReturnTypeAuto,
    RDCutVideoReturnTypePath,
    RDCutVideoReturnTypeTime
    
};
//编辑完成导出结束回调
typedef void(^XpkCallbackBlock) (NSString *videoPath);
typedef void(^XpkAddVideosAndImagesCallbackBlock) (NSArray *list);
typedef void(^XpkAddVideosCallbackBlock) (NSArray *list);
typedef void(^XpkAddImagesCallbackBlock) (NSArray *list);
typedef void(^Xpk_CallbackBlock) (RDCutVideoReturnType cutType,NSString *videoPath,CMTime startTime,CMTime endTime);

/*
 *相册选择视频完成回调
 */
@property (nonatomic,strong)XpkAddVideosAndImagesCallbackBlock addVideosAndImagesCallbackBlock;
@property (nonatomic,strong)XpkAddVideosCallbackBlock addVideosCallbackBlock;
@property (nonatomic,strong)XpkAddImagesCallbackBlock addImagesCallbackBlock;

//编辑取消回调
typedef void(^XpkCancelBlock) ();
//编辑取消回调
typedef void(^XpkFailBlock) (NSError *error);
//文件夹类型
typedef NS_ENUM(NSInteger,FolderType){
    kFolderDocuments,
    kFolderLibrary,
    kFolderTemp
};

typedef NS_ENUM(NSUInteger, RecordVideoSizeType) {
    RecordVideoTypeSquare = 1 << 0, // 正方形录制  only
    RecordVideoTypeNotSquare = 1 << 1, // 非正方形录制 only
    RecordVideoTypeMixed = 1 << 2, // 混合 可切换
};

//此参数在非方形录制下生效
typedef NS_ENUM(NSUInteger, RecordVideoOrientation) {
    RecordVideoOrientationAuto = 1 << 0, // 横竖屏自动切换切换
    RecordVideoOrientationPortrait = 1 << 1, // 保持竖屏
    RecordVideoOrientationLeft = 1 << 2, // 保持横屏
};

typedef NS_ENUM(NSUInteger, Record_Type) {
    RecordType_Photo = 1 << 0,//拍照
    RecordType_Video = 1 << 1,//录制
};
@property (assign, nonatomic) RecordVideoSizeType recordSizeType;
@property (assign, nonatomic) RecordVideoOrientation recordOrientation;
@property (assign, nonatomic) UIInterfaceOrientation deviceOrientation;
@property (assign, nonatomic) BOOL                   orientationLock;

/*
 是否禁用片尾
 */
@property (nonatomic,assign)BOOL endWaterPicDisabled;
/*
 片尾显示的用户名
 */
@property (nonatomic,strong)NSString *endWaterPicUserName;

/**
 *  初始化对象
 *
 *  @param appkey          appkey description
 *  @param appsecret       appsecret description
 *  @param resultFailBlock 返回错误信息
 *
 *  @return
 */
- (id)initWithAPPKey:(NSString *)appkey
           APPSecret:(NSString *)appsecret
          resultFail:(XpkFailBlock)resultFailBlock;
/*
 *自定义截取返回方式
 */
@property(nonatomic, copy) void (^rd_CutVideoReturnType)(RDCutVideoReturnType*);

/**
 *  截取视频(真正的截取，回传截取过后的视频)
 *
 *  @param viewController  源控制器
 *  @param controllerTitle 导航栏标题
 *  @param backgroundColor 背景色
 *  @param cancelButtonTitle 取消按钮文字
 *  @param cancelButtonTitleColor 取消按钮标题颜色
 *  @param cancelButtonBackgroundColor 取消按钮背景色
 *  @param otherButtonTitle  完成按钮文字
 *  @param otherButtonTitleColor  完成按钮标题颜色
 *  @param otherButtonBackgroundColor 完成按钮背景色
 *  @param assetPath       数据源
 *  @param outputVideoPath 视频输出路径
 *  @param callbackBlock   截取完成回调
 *  @param failback        截取失败回调
 *  @param cancelBlock     取消截取回调
 
 */

- (void)cutVideoWithSuperController:(UIViewController *)viewController
                    controllerTitle:(NSString *) title
                    backgroundColor:(UIColor  *) backgroundColor
                  cancelButtonTitle:(NSString *) cancelButtonTitle
             cancelButtonTitleColor:(UIColor  *) cancelButtonTitleColor
        cancelButtonBackgroundColor:(UIColor  *) cancelButtonBackgroundColor
                   otherButtonTitle:(NSString *) otherButtonTitle
              otherButtonTitleColor:(UIColor  *) otherButtonTitleColor
         otherButtonBackgroundColor:(UIColor  *) otherButtonBackgroundColor
                          assetPath:(NSString *) assetPath
                         outputPath:(NSString *) outputVideoPath
                      callbackBlock:(Xpk_CallbackBlock  ) callbackBlock
                           failback:(XpkFailBlock       ) failback
                             cancel:(XpkCancelBlock     ) cancelBlock;
/*
 *  @param minDuration     偏小截取时间 默认6s
 */
@property (nonatomic,assign) float minDuration;
/*
 *  @param maxDuration     偏大截取时间 默认12s
 */
@property (nonatomic,assign) float maxDuration;  // 默认 12s

- (void)cutVideo_withCutType:(RDCutVideoReturnType )type;

/**
 *  编辑视频
 *
 *  @param viewController  源控制器
 *  @param assets          数据源（NSMutableArray[AVURLAsset]）
 *  @param outputVideoPath 视频输出路径
 *  @param callbackBlock   完成编辑回调
 *  @param cancelBlock     取消编辑回调
 */
- (void)editVideoWithSuperController:(UIViewController *)viewController
                              assets:(NSMutableArray *)assets
                          outputPath:(NSString *)outputVideoPath
                            callback:(XpkCallbackBlock )callbackBlock
                              cancel:(XpkCancelBlock )cancelBlock;
/**
 *  编辑视频(需扫描缓存文件夹)
 *
 *  @param viewController    源控制器
 *  @param foldertype        缓存文件夹类型 （Documents、Library、Temp)
 *  @param appAlbumCacheName 需扫描的缓存文件夹名称
 *  @param assets            数据源（NSMutableArray[AVURLAsset]）
 *  @param outputVideoPath   视频输出路径
 *  @param callbackBlock     完成编辑回调
 *  @param cancelBlock       取消编辑回调
 */
- (void)editVideoWithSuperController:(UIViewController *)viewController
                          foldertype:(FolderType)foldertype
                   appAlbumCacheName:(NSString *)appAlbumCacheName
                              assets:(NSMutableArray *)assets
                          outputPath:(NSString *)outputVideoPath
                            callback:(XpkCallbackBlock )callbackBlock
                              cancel:(XpkCancelBlock )cancelBlock;

/**
 *  视频录制
 *
 *  @param source        源视图控制器
 *  @param postion       前/后置摄像头
 *  @param frameRate     帧率
 *  @param bitRate       码率
 *  @param size          录制视频尺寸
 *  @param record_Type   录制还是拍照
 *  @param outputPath    视频输出路径
 *  @param callbackBlock 完成录制回调
 *  @param cancelBlock   取消录制回调
 */

- (void)videoRecordWithSourceController: (UIViewController*)source
                         cameraPosition: (AVCaptureDevicePosition )postion
                              frameRate: (int32_t) frameRate
                                bitRate: (int32_t) bitRate
                             recordSize: (CGSize) size
                            Record_Type: (Record_Type)record_Type
                             outputPath: (NSString*)outputPath
                              videoPath: (XpkCallbackBlock)callbackBlock
                                 cancel: (XpkCancelBlock)cancelBlock;


/**
 *  自动选择录制合适尺寸
 *
 *  @param source        源视图控制器
 *  @param postion       前/后置摄像头
 *  @param frameRate     帧率
 *  @param bitRate       码率
 *  @param record_Type   录制还是拍照
 *  @param outputPath    视频输出路径
 *  @param callbackBlock 完成录制回调
 *  @param cancelBlock   取消录制回调
 */
- (void)videoRecordAutoSizeWithSourceController: (UIViewController*)source
                                 cameraPosition: (AVCaptureDevicePosition )postion
                                      frameRate: (int32_t)frameRate
                                        bitRate: (int32_t)bitRate
                                    Record_Type: (Record_Type)record_Type
                                     outputPath: (NSString*)outputPath
                                      videoPath: (XpkCallbackBlock)callbackBlock
                                         cancel: (XpkCancelBlock)cancelBlock;



/**
 *  录制方形视频
 *
 *  @param source        源视图控制器
 *  @param postion       前/后置摄像头
 *  @param frameRate     帧率
 *  @param bitRate       码率
 *  @param record_Type   录制还是拍照
 *  @param outputPath    视频输出路径
 *  @param callbackBlock 完成录制回调
 *  @param cancelBlock   取消录制回调
 */
- (void)videoRecordWidthEqualToHeightWithSourceController: (UIViewController*)source
                                           cameraPosition: (AVCaptureDevicePosition )postion
                                                frameRate: (int32_t)frameRate
                                                  bitRate: (int32_t)bitRate
                                              Record_Type: (Record_Type)record_Type
                                               outputPath: (NSString*)outputPath
                                                videoPath: (XpkCallbackBlock)callbackBlock
                                                   cancel: (XpkCancelBlock)cancelBlock;

/**
 *  添加文字水印
 *
 *  @param waterString 文字内容
 *  @param waterRect   水印在视频中的位置
 */
- (void)addTextWater:(NSString *)waterString waterRect:(CGRect)waterRect;

/**
 *  添加图片水印
 *
 *  @param waterImage 水印图片
 *  @param waterRect  水印在视频中的位置
 */
- (void)addImageWater:(UIImage *)waterImage waterRect:(CGRect)waterRect;

/**
 *  设置视频输出码率
 *
 *  @param videoAverageBitRate  码率(单位是M,默认是6M),建议设置大于1M
 */
- (void)setOutPutVideoAverageBitRate:(float)videoAverageBitRate;

@end


/**
 *    播放器  针对iOS10.0+系统上AVPlayer播放黑屏问题   本地 网络支持 缓存支持
 */

typedef NS_ENUM(NSInteger, RDPlayerState) {
    RDPlayerStateBuffering = 1,
    RDPlayerStatePlaying   = 2,
    RDPlayerStateStopped   = 3,
    RDPlayerStatePause     = 4,
    RDPlayerStateEnd       = 5,
    RDPlayerStateBufferStart = 6,
    RDPlayerStateBufferEnd = 7,
    RDPlayerStateReadyToPlay = 8
};

@protocol RDPlayerDelegate <NSObject>
@optional
/*
 * 播放结束
 */
- (void) playerToEnd;
/*
 * seek 结束
 */
- (void) seektimesyncBlock;
/*
 * 当前播放时间/总时间  比例
 */
- (void) currentTimeValue:(float) value;
/*
 *
 * 当前缓冲进度
 */
- (void) currentDownloadProgressValue: (float) value;

/*
 * 状态
 */
- (void) currentPlayerState : (RDPlayerState ) state;
@end


@interface RDPlayer : NSObject
@property(nonatomic,assign) id<RDPlayerDelegate> delegate;
@property (nonatomic,readonly) UIView* view;
/*
 * 初始化
 */
- (id)initWithURL:(NSURL *)videoURL frame:(CGRect )frame;

/*
 * 播放
 */
- (void) play;

/*
 * 暂停
 */
- (void) pause;

/*
 * 停止
 */
- (void) stop;

/*
 * 获取当前时间
 */
- (CMTime)currentTime;

/**
 *  seek 播放器时间
 *
 *  @param value seek比例
 */
- (void)seekToTime:(float)value;
@end





