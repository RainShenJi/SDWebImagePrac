//
//  HMApp.h
//  SDWebImagePrac
//
//  Created by RainShen on 15/9/7.
//  Copyright (c) 2015年 小雨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMApp : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * icon;
@property (nonatomic, copy) NSString * download;

+ (instancetype)appWithDict:(NSDictionary *)dict;

@end
