//
//  RuntimeMethodHelper.m
//  RuntimeDemo
//
//  Created by cheyifu on 2017/6/13.
//  Copyright © 2017年 cheyifu. All rights reserved.
//

#import "RuntimeMethodHelper.h"

@implementation RuntimeMethodHelper

- (void)unknownMethod2 {
    NSLog(@"%@, %p", self, _cmd); // Print: <RuntimeMethodHelper: 0x7fb61042f410>, 0x10170d99a
}
- (void)unknownMethod3 {
    NSLog(@"%@, %p", self, _cmd); // Print: <RuntimeMethodHelper: 0x7f814b498ee0>, 0x102d79929
}

- (void)run:(NSNumber *)num {
    NSLog(@"%@", num); // Print: <RuntimeMethodHelper: 0x7f814b498ee0>, 0x102d79929
}

@end
