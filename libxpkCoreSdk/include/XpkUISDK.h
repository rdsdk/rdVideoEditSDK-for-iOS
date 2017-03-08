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

/**编辑所支持的文件类型
 */
typedef NS_ENUM(NSInteger, SUPPORT_UIINTERFACEORIENTATION){
    UIINTERFACEORIENTATION_PORTRAIT,    //竖
    OUIINTERFACEORIENTATION_LANDSCAPE,  //横向
    UIINTERFACEORIENTATION_AUDIO        //自动
    
};

/**编辑所支持的文件类型
 */
typedef NS_ENUM(NSInteger, SUPPORTFILETYPE){
    ONLYSUPPORT_VIDEO,      //仅支持视频
    ONLYSUPPORT_IMAGE,      //仅支持图片
    SUPPORT_ALL             //支持视频和图片

};

/**视频输出方式
 */
typedef NS_ENUM(NSInteger, RDPROPORTIONTYPE){
    RDPROPORTIONTYPE_AUDIO      = 0,//自动
    RDPROPORTIONTYPE_LANDSCAPE  = 1,//横
    RDPROPORTIONTYPE_SQUARE     = 2//正方形
};

/**默认选中视频还是图片
 */
typedef NS_ENUM(NSInteger, RDDEFAULTSELECTALBUM){
    
    RDDEFAULTSELECTALBUM_VIDEO,
    RDDEFAULTSELECTALBUM_IMAGE
};

/**配乐方式
 */
typedef NS_ENUM(NSInteger, RDMUSICTYPE){
    RDMUSICTYPE_FIRST,
    RDMUSICTYPE_SECOND
};

/**滤镜方式
 */
typedef NS_ENUM(NSInteger, RDFILTERTYPE){
    RDFILTERTYPE_FRIST,
    RDFILTERTYPE_SECOND
};

/**方向
 */
typedef NS_ENUM(NSInteger, RDDeviceOrientation){
    RDDeviceOrientationUnknown,
    RDDeviceOrientationPortrait,
    RDDeviceOrientationLandscape
};
/**定长截取还是自由截取
 */
typedef NS_ENUM(NSInteger, TRIMMODE){
    TRIMMODESPECIFYTIME,
    TRIMMODENOTSPECIFYTIME
};

/**截取之后返回的类型
 */
typedef NS_ENUM(NSInteger, RDCutVideoReturnType){
    RDCutVideoReturnTypeAuto,
    RDCutVideoReturnTypePath,
    RDCutVideoReturnTypeTime
    
};
/**截取界面默认选中最大值还是最小值（定值截取才会设置）
 */
typedef NS_ENUM(NSInteger,RDdefaultSelectCutMinOrMax){
    kRDDefaultSelectCutMin,
    kRDDefaultSelectCutMax,
} ;
/**水印位置
 */
typedef NS_ENUM(NSInteger,RDWATERPOSITION){
    WATERPOSITION_LEFTTOP,
    WATERPOSITION_RIGHTTOP,
    WATERPOSITION_LEFTBOTTOM,
    WATERPOSITION_RIGHTBOTTOM
} ;
@interface ExportConfiguration : NSObject

#pragma mark- 设置视频水印和码率

NS_ASSUME_NONNULL_BEGIN
/** 设置视频输出码率 (单位是兆,默认是6M),建议设置大于1M
 */
@property (nonatomic,assign)float   videoBitRate;
/** 设置视频输出最大时长 (单位是秒) 不限制则传0，默认不限制
 */
@property (nonatomic,assign)long int   videoMaxDuration;
/** 是否禁用片尾
 */
@property (nonatomic,assign)bool    endPicDisabled;
/** 片尾显示的用户名
 */
@property (nonatomic,strong)NSString *endPicUserName;
/** 片尾显示的图片路径
 */
@property (nonatomic,strong)NSString *endPicImagepath;
/** 是否禁用水印
 */
@property (nonatomic,assign)bool     waterDisabled;
/** 文字水印
 */
@property (nonatomic,strong)NSString *waterText;
/** 图片水印
 */
@property (nonatomic,strong)UIImage *waterImage;
/** 显示位置
 */
@property (nonatomic,assign)RDWATERPOSITION  waterPosition;
NS_ASSUME_NONNULL_END
@end

@interface EditConfiguration : NSObject

NS_ASSUME_NONNULL_BEGIN

/** enableWizard 如果需要自己删除一些功能 则需启用此参数  default false
 */
@property (assign, nonatomic)bool enableWizard;
/** 编辑视频所支持的文件类型 (default all)
 */
@property (assign, nonatomic)SUPPORTFILETYPE supportFileType;

/**设备方向(UIInterfaceOrientationUnknown,UIInterfaceOrientationPortrait,UIInterfaceOrientationPortraitUpsideDown, UIInterfaceOrientationLandscapeLeft,UIInterfaceOrientationLandscapeRight)
 */

@property (assign, nonatomic) SUPPORT_UIINTERFACEORIENTATION supportDeviceOrientation;

/** 默认选中视频还是图片
 */
@property (nonatomic,assign) RDDEFAULTSELECTALBUM defaultSelectAlbum;


#pragma mark- 设置截取界面
/** 偏小截取时间 默认12s
 */
@property (nonatomic,assign) float trimMinDuration;
/** 偏大截取时间 默认30s
 */
@property (nonatomic,assign) float trimMaxDuration;
/** 默认选中小值还是大值
 */
@property (nonatomic,assign) RDdefaultSelectCutMinOrMax  defaultSelectMinOrMax;

#pragma mark- 设置视频编辑界面
/** 截取 (default true)
 */
@property (nonatomic,assign) bool customizationTRIM;
/** 分割 (default true)
 */
@property (nonatomic,assign) bool customizationSPLIT;
/** 裁切 (default true)
 */
@property (nonatomic,assign) bool customizationEDIT;
/** 变速 (default true)
 */
@property (nonatomic,assign) bool customizationSPEEDCONTROL;
/** 复制 (default true)
 */
@property (nonatomic,assign) bool customizationCOPY;
/** 调整顺序 (default true)
 */
@property (nonatomic,assign) bool customizationSORT;
/** 调整视频比例 (default true)
 */
@property (nonatomic,assign) bool customizationPROPORTION;
/** 调整图片显示时长 (default true)
 */
@property (nonatomic,assign) bool customizationIMAGE_DURATION_CONTROL;
/** 文字版 (default true)
 */
@property (nonatomic,assign) bool customizationTEXTTITLE;

/** 默认视频输出方式（自动，横屏，1 ：1）
 */
@property (nonatomic,assign) RDPROPORTIONTYPE customizationPROPORTIONTYPE;

#pragma mark- 设置高级编辑界面
/** 配乐 (default true)
 */
@property (nonatomic,assign) bool customizationMUSIC;

/** 配乐类型 (default true)
 */
@property (nonatomic,assign) RDMUSICTYPE customizationMUSICTYPE;

/** 配音 (default true)
 */
@property (nonatomic,assign) bool customizationDUBBING;
/** 字幕 (default true)
 */
@property (nonatomic,assign) bool customizationSUBTITLE;
/** 滤镜 (default true)
 */
@property (nonatomic,assign) bool customizationFILTER;
/** 滤镜类型 ()
 */
@property (nonatomic,assign) RDFILTERTYPE customizationFILTERTYPE;
/** 特效 (default true)
 */
@property (nonatomic,assign) bool customizationEFFECT;
/** 片段编辑 (default true)
 */
@property (nonatomic,assign) bool customizationFRAGMENTEDIT;


NS_ASSUME_NONNULL_END


@end

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

typedef NS_ENUM(NSUInteger, CameraCollocationPositionType) {
    CameraCollocationPositionTop    = 1 << 0,//顶部
    CameraCollocationPositionBottom = 1 << 1,//底部
};

typedef NS_ENUM(NSUInteger, CameraModelType) {
    CameraModel_Onlyone    = 1 << 0,//录制完成立即返回
    CameraModel_Manytimes = 1 << 1,//录制完成保存到相册并不立即返回，可多次录制或拍照
};

@interface CameraConfiguration : NSObject

NS_ASSUME_NONNULL_BEGIN
/** 拍摄模式 default CameraModel_Onlyone
 */
@property (nonatomic,assign) CameraModelType                cameraModelType;

/** 是否在拍摄完成就保存到相册再返回 default false 该参数只有在 CameraModel_Onlyone 模式下才生效
 */
@property (nonatomic,assign) bool                           cameraWriteToAlbum;

/** 前/后置摄像头 default AVCaptureDevicePositionFront
 */
@property (nonatomic,assign) AVCaptureDevicePosition        cameraCaptureDevicePosition;

/** 相机的方向 default RecordVideoOrientationAuto
 */
@property (nonatomic,assign) RecordVideoOrientation         cameraRecordOrientation;

/** 相机录制大小（正方形录制，非正方形录制）
 */
@property (nonatomic,assign) RecordVideoSizeType            cameraRecordSizeType;

/** 录制视频帧率 default 30
 */
@property (nonatomic,assign) int32_t                        cameraFrameRate;

/** 录制视频码率 default 4000000
 */
@property (nonatomic,assign) int32_t                        cameraBitRate;

/** 录制还是拍照 default RecordVideoOrientationAuto
 */
@property (nonatomic,assign) Record_Type                    cameraRecord_Type;

/** 视频输出路径
 */
@property (nonatomic,strong) NSString                       *cameraOutputPath;

/**录制的视频的大小 (如：{720,1280}) dealft auto
 */
@property (nonatomic,assign) CGSize                         cameraOutputSize;

/** 正方形录制时配置按钮的位置（美颜，延时，摄像头切换 三个按钮的位置）
 */
@property (nonatomic,assign) CameraCollocationPositionType   cameraCollocationPosition;

/** 正方形录制最大时长(default 10 )
 */
@property (nonatomic,assign) float                           cameraSquare_MaxVideoDuration;

/** 非正方形录制最大时长 (default 0 ，不限制)
 */
@property (nonatomic,assign) float                           cameraNotSquare_MaxVideoDuration;


NS_ASSUME_NONNULL_END

@end

@protocol XpkUISDKDelegate <NSObject>

@optional
NS_ASSUME_NONNULL_BEGIN
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

NS_ASSUME_NONNULL_END

@end

//文件夹类型
typedef NS_ENUM(NSInteger,FolderType){
    kFolderDocuments,
    kFolderLibrary,
    kFolderTemp,
    kFolderNone
};

typedef NS_ENUM(NSInteger,RDFileType){
    kRDFileVideo,
    kRDFileImage,
};

//选择相册类型
typedef NS_ENUM(NSInteger, ALBUMTYPE){
    kALBUMALL,
    kONLYALBUMVIDEO,
    kONLYALBUMIMAGE
};

NS_ASSUME_NONNULL_BEGIN

static NSString *kFILEURL = @"kFILEURL";
static NSString *kFILEPATH = @"kFILEPATH";
static NSString *kFILETYPE = @"kFILETYPE";

NS_ASSUME_NONNULL_END

@interface XpkUISDK : NSObject

NS_ASSUME_NONNULL_BEGIN
@property (nonatomic,assign)id<XpkUISDKDelegate> delegate;
/**   视频导出设置
 */
@property (nonatomic,strong) ExportConfiguration     *exportConfiguration;
/**   编辑设置
 */
@property (nonatomic,strong) EditConfiguration        * editConfiguration;
/**  拍摄功能设置
 */
@property (nonatomic,strong) CameraConfiguration    * cameraConfiguration;


typedef void(^XpkCallbackBlock) (NSString * videoPath);//编辑完成导出结束回调
typedef void(^XpkFailBlock) (NSError * error);
typedef void(^XpkAddVideosAndImagesCallbackBlock) (NSArray * list);
typedef void(^OnXpkAlbumCallbackBlock) (NSArray * videoAssets,NSArray * imageAssets);
typedef void(^XpkAddVideosCallbackBlock) (NSArray * list);
typedef void(^XpkAddImagesCallbackBlock) (NSArray * list);
typedef void(^Xpk_CallbackBlock) (RDCutVideoReturnType cutType,NSString * videoPath,CMTime startTime,CMTime endTime);

/**相册选择视频完成回调
 */
@property (nonatomic,strong)XpkAddVideosAndImagesCallbackBlock addVideosAndImagesCallbackBlock;
@property (nonatomic,strong)XpkAddVideosCallbackBlock addVideosCallbackBlock;
@property (nonatomic,strong)XpkAddImagesCallbackBlock addImagesCallbackBlock;

//编辑取消回调
typedef void(^XpkCancelBlock) ();
//编辑取消回调
typedef void(^XpkFailBlock) (NSError * error);

@property (assign, nonatomic) RecordVideoSizeType recordSizeType;
@property (assign, nonatomic) RecordVideoOrientation recordOrientation;

@property (assign, nonatomic) UIInterfaceOrientation deviceOrientation;
@property (assign, nonatomic) BOOL                   orientationLock;

/** 自定义截取返回方式
 */
@property(nonnull, copy) void (^rd_CutVideoReturnType)(RDCutVideoReturnType*);


/**  初始化对象
 *
 *  @param appkey          appkey description
 *  @param appsecret       appsecret description
 *  @param resultFailBlock 返回错误信息
 *
 *  @return
 */
- (instancetype)initWithAPPKey:(NSString *)appkey
           APPSecret:(NSString *)appsecret
          resultFail:(XpkFailBlock )resultFailBlock;
/**选择视频或图片
 * @param: viewController  源控制器
 * @param: albumType选择相册类型（仅选图片，仅选视频，两者皆可）
 * @param: callbackBlock 返回的内容
 */
- (void)onXpkAlbumWithSuperController:(UIViewController *)viewController
                            albumType:(ALBUMTYPE)albumType
                            callback:(OnXpkAlbumCallbackBlock) callbackBlock;

/**  截取视频
 *  @param viewController               源控制器
 *  @param trimMode                     截取模式（定长截取还是自由截取）
 *  @param controllerTitle              导航栏标题
 *  @param backgroundColor              背景色
 *  @param cancelButtonTitle            取消按钮文字
 *  @param cancelButtonTitleColor       取消按钮标题颜色
 *  @param cancelButtonBackgroundColor  取消按钮背景色
 *  @param otherButtonTitle             完成按钮文字
 *  @param otherButtonTitleColor        完成按钮标题颜色
 *  @param otherButtonBackgroundColor   完成按钮背景色
 *  @param assetPath                    数据源
 *  @param outputVideoPath              视频输出路径
 *  @param callbackBlock                截取完成回调
 *  @param failback                     截取失败回调
 *  @param cancelBlock                  取消截取回调
 
 */

- (void)trimVideoWithSuperController:(UIViewController *)viewController controllerTrimMode:(TRIMMODE) trimMode
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


/**设置截取返回类型
 */
- (void)trimVideoWithType:(RDCutVideoReturnType )type;

/**   编辑视频(需扫描缓存文件夹)
 *
 *  @param viewController    源控制器
 *  @param foldertype        缓存文件夹类型 （Documents、Library、Temp,None)
 *  @param appAlbumCacheName 需扫描的缓存文件夹名称
 *  @param assets            视频(NSMutableArray <AVURLAsset*>)
 *  @param imagePaths        图片路径(NSMutableArray <NSString*>)
 *  @param outputVideoPath   视频输出路径
 *  @param callbackBlock     完成编辑回调
 *  @param cancelBlock       取消编辑回调
 */
- (void)editVideoWithSuperController:(UIViewController *)viewController
                          foldertype:(FolderType)foldertype
                   appAlbumCacheName:(NSString *)appAlbumCacheName
                              assets:(NSMutableArray *)assets
                          imagePaths:(NSMutableArray *)imagePaths
                          outputPath:(NSString *)outputVideoPath
                            callback:(XpkCallbackBlock )callbackBlock
                              cancel:(XpkCancelBlock )cancelBlock;


/** 录制视频 参数设置(cameraConfiguration)
 *  @param source        源视图控制器
 *  @param callbackBlock 完成录制回调
 *  @param imagebackBlock 拍照完成回调
 *  @param cancelBlock   取消录制回调
 */

- (void)videoRecordAutoSizeWithSourceController: (UIViewController*)source
                                  callbackBlock: (XpkCallbackBlock)callbackBlock
                                 imagebackBlock:(XpkCallbackBlock)imagebackBlock
                                     faileBlock:(XpkFailBlock)failBlock
                                         cancel: (XpkCancelBlock)cancelBlock;



/*
 *TODO:======================以下参数和接口不推荐使用=====================
 */

/**是否禁用片尾
 */
@property (nonatomic,assign)BOOL endWaterPicDisabled;
/**片尾显示的用户名
 */
@property (nonnull,strong)NSString *endWaterPicUserName;
/** 设置视频输出码率
 *
 *  @param videoAverageBitRate  码率(单位是M,默认是6M),建议设置大于1M
 */
- (void)setOutPutVideoAverageBitRate:(float)videoAverageBitRate;


/**  截取视频(真正的截取，回传截取过后的视频)---->(老接口不推荐使用)
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
/**偏小截取时间 默认6s
 */
@property (nonatomic,assign) float minDuration;
/**偏大截取时间 默认12s
 */
@property (nonatomic,assign) float maxDuration;  // 默认 12s
/**@param defaultSelectMinOrMax 默认选中小值还是大值
 */
@property (nonatomic,assign) RDdefaultSelectCutMinOrMax  defaultSelectMinOrMax; //default kRDCutSelectDefaultMin

- (void)cutVideo_withCutType:(RDCutVideoReturnType )type;

/**   视频录制(老接口不推荐使用)
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


/**   自动选择录制合适尺寸(老接口不推荐使用)
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



/**   录制方形视频(老接口不推荐使用)
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

/** 添加文字水印(老接口不推荐使用)
 *
 *  @param waterString 文字内容
 *  @param waterRect   水印在视频中的位置
 */
- (void)addTextWater:(NSString *)waterString waterRect:(CGRect)waterRect NS_DEPRECATED_IOS(6_0, 7_0);

/**   添加图片水印(老接口不推荐使用)
 *
 *  @param waterImage 水印图片
 *  @param waterRect  水印在视频中的位置
 */
- (void)addImageWater:(UIImage *)waterImage waterRect:(CGRect)waterRect NS_DEPRECATED_IOS(6_0, 7_0);


/**  编辑视频
 *
 *  @param viewController  源控制器
 *  @param assets          数据视频源(video:NSMutableArray <AVURLAsset*> image: NSMutableArray <NSString*>)
 *  @param outputVideoPath 视频输出路径
 *  @param callbackBlock   完成编辑回调
 *  @param cancelBlock     取消编辑回调
 */
- (void)editVideoWithSuperController:(UIViewController *)viewController
                              assets:(NSMutableArray *)assets
                          outputPath:(NSString *)outputVideoPath
                            callback:(XpkCallbackBlock )callbackBlock
                              cancel:(XpkCancelBlock )cancelBlock;

/**   编辑视频(需扫描缓存文件夹)
 *
 *  @param viewController    源控制器
 *  @param foldertype        缓存文件夹类型 （Documents、Library、Temp)
 *  @param appAlbumCacheName 需扫描的缓存文件夹名称
 *  @param assets            数据源(video:NSMutableArray <AVURLAsset*> image: NSMutableArray <NSString*>)
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

//TODO:===========================================================
NS_ASSUME_NONNULL_END

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

NS_ASSUME_NONNULL_BEGIN
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
NS_ASSUME_NONNULL_END
@end


@interface RDPlayer : NSObject
NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
@end





