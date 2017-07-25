//
//  Cat+Extend.m
//  RuntimeDemo
//
//  Created by cheyifu on 2017/7/24.
//  Copyright © 2017年 cheyifu. All rights reserved.
//

#import "Cat+Extend.h"

@implementation Cat (Extend)

//5.
- (void)setColor:(NSString *)color{
    objc_setAssociatedObject(self, "color", color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)color{
    return objc_getAssociatedObject(self, "color");
}

@end
