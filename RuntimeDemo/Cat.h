//
//  Cat.h
//  RuntimeDemo
//
//  Created by cheyifu on 2017/7/24.
//  Copyright © 2017年 cheyifu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "RuntimeMethodHelper.h"

@interface Cat : NSObject

@property (nonatomic,copy) NSString *name;
@property(nonatomic, copy) NSString *cid;
@property(nonatomic, copy) NSString *age;

- (void)eat;
- (void)shirt;
+ (void)load;


+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
