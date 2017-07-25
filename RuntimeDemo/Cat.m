//
//  Cat.m
//  RuntimeDemo
//
//  Created by cheyifu on 2017/7/24.
//  Copyright © 2017年 cheyifu. All rights reserved.
//

#import "Cat.h"

@implementation Cat

//1.
- (void)eat{

    NSLog(@"I like eat fish");
}

- (void)shirt{
    NSLog(@"cat shirt....");
}
//2.
+ (void)load{
    Method eatMethod = class_getInstanceMethod(self, @selector(eat));
    Method shirtMethod = class_getInstanceMethod(self, @selector(shirt));
    
    method_exchangeImplementations(eatMethod, shirtMethod);
}

/*
//3.
void run(id self, SEL _cmd, NSNumber *number){
    NSLog(@"run for %@", number);
}

//收到run:消息时候，为该类添加一个方法实现
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if(sel == NSSelectorFromString(@"run:")){
        class_addMethod(self, @selector(run:), (IMP)run, "v@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

//另外针对类方法的为 resolveClassMethod
*/

//4.
//  第一步，消息接收者没有找到对应的方法时候，会先调用此方法，可在此方法实现中动态添加新的方法
//  返回YES表示相应selector的实现已经被找到，或者添加新方法到了类中，否则返回NO
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return YES;
}

//  第二步， 如果第一步的返回NO或者直接返回了YES而没有添加方法，该方法被调用
//  在这个方法中，我们可以指定一个可以返回一个可以响应该方法的对象， 注意如果返回self就会死循环
- (id)forwardingTargetForSelector:(SEL)aSelector {
//    if ([NSStringFromSelector(aSelector) isEqualToString:@"run:"]) {
//        return [[RuntimeMethodHelper alloc] init];
//    }
//    return [super forwardingTargetForSelector:aSelector];
    return nil;
}

//  第三步， 如果forwardingTargetForSelector:返回了nil，则该方法会被调用，系统会询问我们要一个合法的『类型编码(Type Encoding)』
//  函数的最后一个参数 types 是描述方法返回值和参数列表的字符串，我们的代码中的用到的 i@:@ 四个字符分别对应着：返回值 int32_t、参数 id self、参数 SEL _cmd、参数 NSDictionary *dic,即类型编码。
//  若返回 nil，则不会进入下一步，而是无法处理消息
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([NSStringFromSelector(aSelector) isEqualToString:@"run:"]){
            return [NSMethodSignature signatureWithObjCTypes:"v@:"];
        }
        return [super methodSignatureForSelector: aSelector];
    }
    return signature;
}

// 当实现了此方法后，-doesNotRecognizeSelector: 将不会被调用
// 在这里进行消息转发
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    if ([RuntimeMethodHelper instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:[[RuntimeMethodHelper alloc] init]];
    }
    
//    // 在这里可以改变方法选择器
//    [anInvocation setSelector:@selector(run:)];
//    // 改变方法选择器后，需要指定消息的接收者
//    [anInvocation invokeWithTarget:self];
}

//- (void)run:(NSNumber *)num {
//    NSLog(@"---%@", num); // Print: <RuntimeMethodHelper: 0x7f814b498ee0>, 0x102d79929
//}

// 如果没有实现消息转发 forwardInvocation  则调用此方法
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"unresolved method ：%@", NSStringFromSelector(aSelector));
}


//6.
+ (instancetype)modelWithDict:(NSDictionary *)dict{
    id model = [[self alloc] init];
    unsigned int count = 0;
    
    Ivar *ivars = class_copyIvarList(self, &count);
    for (int i = 0 ; i < count; i++) {
        Ivar ivar = ivars[i];
        
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        //这里注意，拿到的成员变量名为_cid,_age
        ivarName = [ivarName substringFromIndex:1];
        id value = dict[ivarName];
        
        [model setValue:value forKeyPath:ivarName];
    }
    
    return model;
}

@end
