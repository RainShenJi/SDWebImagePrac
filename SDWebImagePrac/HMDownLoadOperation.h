//
//  HMDownLoadOperation.h
//  SDWebImagePrac
//
//  Created by RainShen on 15/9/11.
//  Copyright (c) 2015年 小雨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class HMDownLoadOperation;

@protocol HMDownLoadOperationDelegate <NSObject>

@optional //写方法的规范就是以当前类名开头并且删掉前缀，就像系统tableView,scrollView等等代理一样写法
- (void)downLoadOperation:(HMDownLoadOperation *)operation didFinishDownLoad:(UIImage *)image;
/**
 *  （1）downLoadOperation一个下载操作didFinishDownLoad完成下载，但是哪个下载操作啊，好，我把下载操作传给你(HMDownLoadOperation *)operation写在downLoadOperation后面就好了
 *  （2）我只是想告诉你，我图片下载完了，我传给你，你拿去用吧
 */

@end

//上面用代理实现的，同样也可以用block实现
typedef void(^DownLoadOperationBLock)(UIImage * image);

@interface HMDownLoadOperation : NSOperation

@property (nonatomic, copy) NSString * imageUrl; //作为下载操作要知道自己下什么东西啊,当前类负责下载图片，由外界传进来
@property (nonatomic, strong) NSIndexPath * indexpath;

@property (nonatomic, weak) id<HMDownLoadOperationDelegate>delegate;

@property (nonatomic, strong) DownLoadOperationBLock block;

@property (nonatomic, strong) UIImage * image;
- (void)downLoadBlock:(DownLoadOperationBLock)loadBLock;

@end
