//
//  PlayVideoController.h
//  XpkUISDKDemo
//
//  Created by emmet on 16/1/15.
//  Copyright © 2016年 XpkUISDKDemo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface PlayVideoController : UIViewController
@property (nonatomic,strong)NSString *outputPath;
@property (nonatomic,assign)UIInterfaceOrientation deviceOrientation;
@end
