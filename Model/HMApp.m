//
//  HMApp.m
//  SDWebImagePrac
//
//  Created by RainShen on 15/9/7.
//  Copyright (c) 2015年 小雨. All rights reserved.
//

#import "HMApp.h"

@implementation HMApp

+ (instancetype)appWithDict:(NSDictionary *)dict {
    
    HMApp * app = [[self alloc] init];
    [app setValuesForKeysWithDictionary:dict];
    return app;
}

@end
