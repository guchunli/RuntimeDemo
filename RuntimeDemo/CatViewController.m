//
//  CatViewController.m
//  RuntimeDemo
//
//  Created by cheyifu on 2017/7/25.
//  Copyright © 2017年 cheyifu. All rights reserved.
//

#import "CatViewController.h"
#import <objc/message.h>
#import "Cat.h"
#import "Cat+Extend.h"

@interface CatViewController ()

@end

@implementation CatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.消息机制
    // 通过类名获取类
    Class catClass = objc_getClass("Cat");
    
    //注意Class实际上也是对象，所以同样能够接受消息，向Class发送alloc消息
    Cat *cat = objc_msgSend(catClass, @selector(alloc));
    
    //发送init消息给Cat实例cat
    cat = objc_msgSend(cat, @selector(init));
    
    //发送eat消息给cat，即调用eat方法
    objc_msgSend(cat, @selector(eat));
    
    //汇总消息传递过程
    objc_msgSend(objc_msgSend(objc_msgSend(objc_getClass("Cat"), sel_registerName("alloc")), sel_registerName("init")), sel_registerName("eat"));
    
    //2.方法交换
    [Cat load];
    objc_msgSend(cat, @selector(eat));
    
    [Cat load];
    objc_msgSend(cat, @selector(eat));
    
    //3.动态加载
    //4.消息转发
    [cat performSelector:@selector(run:) withObject:@3];
    
    //5.动态关联属性
    cat.color = @"orange";
    NSLog(@"%@",cat.color);
    
    //6.字典转模型
    NSDictionary *dict = @{@"cid":@"miaomiao",@"age":@"5"};
    Cat *c1 = [Cat modelWithDict:dict];
    NSLog(@"%@--%@",c1.cid,c1.age);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
