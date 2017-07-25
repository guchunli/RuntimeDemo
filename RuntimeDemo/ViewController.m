//
//  ViewController.m
//  RuntimeDemo
//
//  Created by cheyifu on 2017/6/13.
//  Copyright © 2017年 cheyifu. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "SubClass.h"
#import "UIViewController+Runtime.h"
#import "RuntimeMethodHelper.h"
#import <objc/message.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self aboutClass];
    //    [self runtimeConstruct];
    //    [self aboutIvarAndProperty];
    //    [self aboutMessage];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    //    [self performSelector:@selector(unknownMethod)];
    //    [self performSelector:@selector(unknownMethod2)];
    //    [self performSelector:@selector(unknownMethod3)];
    if ([self respondsToSelector:@selector(unknownMethod4)]) {
        [self performSelector:@selector(unknownMethod4)];
    }
    //    [self performSelector:@selector(unknownMethod4)];
#pragma clang diagnostic pop
}

void dealWithExceptionForUnknownMethod(id self, SEL _cmd) {
    NSLog(@"%@, %p", self, _cmd); // Print: <ViewController: 0x7ff96be33e60>, 0x1078259fc
}
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selectorString = NSStringFromSelector(sel);
    if ([selectorString isEqualToString:@"unknownMethod"]) {
        class_addMethod(self.class, @selector(unknownMethod), (IMP) dealWithExceptionForUnknownMethod, "v@:");
    }
    return [super resolveInstanceMethod:sel];
}

// Deal with unknownMethod2.
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSString *selectorString = NSStringFromSelector(aSelector);
    if ([selectorString isEqualToString:@"unknownMethod2"]) {
        return [[RuntimeMethodHelper alloc] init];
    }
    return [super forwardingTargetForSelector:aSelector];
}

// Deal with unknownMethod3.
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([RuntimeMethodHelper instancesRespondToSelector:aSelector]) {
            signature = [RuntimeMethodHelper instanceMethodSignatureForSelector:aSelector];
        }
    }
    
    return signature;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([RuntimeMethodHelper instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:[[RuntimeMethodHelper alloc] init]];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    else {
        NSLog(@"There is not this funtion");
    }
    return NO;
}

#pragma mark - 实例、类、父类、元类关系结构的示例代码
-(void)aboutClass {
    
    // Use "object_getClass()" to get "isa".
    
    SubClass *sub = [[SubClass alloc] init];
    NSLog(@"%@, %@", object_getClass(sub), class_getSuperclass(object_getClass(sub))); // Print: SubClass, SuperClass
    Class cls = objc_getMetaClass("SubClass");
    if (class_isMetaClass(cls)) {
        NSLog(@"YES, %@, %@, %@", cls, class_getSuperclass(cls), object_getClass(cls)); // Print: YES, SubClass, SuperClass, NSObject
    }
    else {
        NSLog(@"NO");
    }
    
    SuperClass *sup = [[SuperClass alloc] init];
    NSLog(@"%@, %@", object_getClass(sup), class_getSuperclass(object_getClass(sup))); // Print: SuperClass, NSObject
    cls = objc_getMetaClass("SuperClass");
    if (class_isMetaClass(cls)) {
        NSLog(@"YES, %@, %@, %@", cls, class_getSuperclass(cls), object_getClass(cls)); // Print: YES, SuperClass, NSObject, NSObject
    }
    else {
        NSLog(@"NO");
    }
    
    
    cls = objc_getMetaClass("UIView");
    if (class_isMetaClass(cls)) {
        NSLog(@"YES, %@, %@, %@", cls, class_getSuperclass(cls), object_getClass(cls)); // Print: YES, UIView, UIResponder, NSObject
    }
    else {
        NSLog(@"NO");
    }
    cls = objc_getMetaClass("NSObject");
    if (class_isMetaClass(cls)) {
        NSLog(@"YES, %@, %@, %@", cls, class_getSuperclass(cls), object_getClass(cls)); // Print: YES, NSObject, NSObject, NSObject
    }
    else {
        NSLog(@"NO");
    }
}

#pragma mark - 动态操作类与实例的示例代码
int32_t testRuntimeMethodIMP(id self, SEL _cmd, NSDictionary *dic) {
    NSLog(@"testRuntimeMethodIMP: %@", dic);
    // Print:
    // testRuntimeMethodIMP: {
    //     a = "para_a";
    //     b = "para_b";
    // }
    
    return 99;
}
- (void)runtimeConstruct {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // 1: Create and register class, add method to class.
    Class cls = objc_allocateClassPair(SuperClass.class, "RuntimeSubClass", 0);
    // Method returns: "int32_t"; accepts: "id self", "SEL _cmd", "NSDictionary *dic". So use "i@:@" here.
    class_addMethod(cls, @selector(testRuntimeMethod), (IMP) testRuntimeMethodIMP, "i@:@");
    // You can only register a class once.
    objc_registerClassPair(cls);
    
    // 2: Create instance of class, print some info about class and associated meta class.
    id sub = [[cls alloc] init];
    NSLog(@"%@, %@", object_getClass(sub), class_getSuperclass(object_getClass(sub))); // Print: RuntimeSubClass, SuperClass
    Class metaCls = objc_getMetaClass("RuntimeSubClass");
    if (class_isMetaClass(metaCls)) {
        NSLog(@"YES, %@, %@, %@", metaCls, class_getSuperclass(metaCls), object_getClass(metaCls)); // Print: YES, RuntimeSubClass, SuperClass, NSObject
    }
    else {
        NSLog(@"NO");
    }
    
    // 3: Methods of class.
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList(cls, &outCount);
    for (int32_t i = 0; i < outCount; i++) {
        Method method = methods[i];
        NSLog(@"%@, %s", NSStringFromSelector(method_getName(method)), method_getTypeEncoding(method));
    }
    // Print: testRuntimeMethod, i@:@
    free(methods);
    
    
    // 4: Call method.
    int32_t result = (int) [sub performSelector:@selector(testRuntimeMethod) withObject:@{@"a":@"para_a", @"b":@"para_b"}];
    NSLog(@"%d", result); // Print: 99
    
    
    // 5: Destory instances and class.
    // Destroy instances of cls class before destroy cls class.
    sub = nil;
    // Do not call this function if instances of the cls class or any subclass exist.
    objc_disposeClassPair(cls);
    
#pragma clang diagnostic pop
}

#pragma mark - 运行时操作成员变量和属性的代码示例
NSString * runtimePropertyGetterIMP(id self, SEL _cmd) {
    Ivar ivar = class_getInstanceVariable([self class], "_runtimeProperty");
    
    return object_getIvar(self, ivar);
}
void runtimePropertySetterIMP(id self, SEL _cmd, NSString *s) {
    Ivar ivar = class_getInstanceVariable([self class], "_runtimeProperty");
    NSString *old = (NSString *) object_getIvar(self, ivar);
    if (![old isEqualToString:s]) {
        object_setIvar(self, ivar, s);
    }
}
- (void)aboutIvarAndProperty {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // 1: Add property and getter/setter.
    Class cls = objc_allocateClassPair(SuperClass.class, "RuntimePropertySubClass", 0);
    
    BOOL b = class_addIvar(cls, "_runtimeProperty", sizeof(cls), log2(sizeof(cls)), @encode(NSString));
    NSLog(@"%@", b ? @"YES" : @"NO"); // Print: YES
    
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t ownership = {"C", ""}; // C = copy
    objc_property_attribute_t isAtomic = {"N", ""}; // N = nonatomic
    objc_property_attribute_t backingivar  = {"V", "_runtimeProperty"};
    objc_property_attribute_t attrs[] = {type, ownership, isAtomic, backingivar};
    class_addProperty(cls, "runtimeProperty", attrs, 4);
    class_addMethod(cls, @selector(runtimeProperty), (IMP) runtimePropertyGetterIMP, "@@:");
    class_addMethod(cls, @selector(setRuntimeProperty), (IMP) runtimePropertySetterIMP, "v@:@");
    
    // You can only register a class once.
    objc_registerClassPair(cls);
    
    // 2: Print all properties.
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int32_t i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSLog(@"%s, %s\n", property_getName(property), property_getAttributes(property));
    }
    // Print:
    // runtimeProperty, T@"NSString",C,N,V_runtimeProperty
    free(properties);
    
    
    // 3: Print all ivars.
    Ivar *ivars = class_copyIvarList(cls, &outCount);
    for (int32_t i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"%s, %s\n", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    // Print:
    // _runtimeProperty, {NSString=#}
    free(ivars);
    
    
    // 4: Use runtime property.
    id sub = [[cls alloc] init];
    [sub performSelector:@selector(setRuntimeProperty) withObject:@"It-is-a-runtime-property."];
    NSString *s = [sub performSelector:@selector(runtimeProperty)]; //[sub valueForKey:@"runtimeProperty"];
    NSLog(@"%@", s); // Print: It-is-a-runtime-property.
    
    
    // 5: Clear.
    // Destroy instances of cls class before destroy cls class.
    sub = nil;
    // Do not call this function if instances of the cls class or any subclass exist.
    objc_disposeClassPair(cls);
#pragma clang diagnostic pop
}

#pragma mark - 运行时消息分发的代码示例
- (void)aboutMessage{
    
    //编译时获取指定方法名的SEL
    SEL sel = @selector(alloc);
    NSLog(@"%p", sel); // Print: 0x10338b545
    //运行时获取指定方法名的SEL
    SEL aSelector = NSSelectorFromString(@"alloc");
    NSLog(@"%p", aSelector);
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"A1: %@", self); // Print: A1: <ViewController: 0x7fd06422b6a0>
    [super viewWillAppear:animated];
    NSLog(@"A2: %@", self); // Print: A2: <ViewController: 0x7fd06422b6a0>
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
