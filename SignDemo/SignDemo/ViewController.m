//
//  ViewController.m
//  SignDemo
//
//  Created by 胡贝 on 2017/4/12.
//  Copyright © 2017年 hubei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(50, 50, 100, 50);
    [btn setTitle:@"test" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(50, 150, 100, 50);
    [btn1 setTitle:@"test" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}

-(void)click
{
    NSLog(@"呵呵");
    NSArray *arr=[NSArray arrayWithObjects:@"4",@"5", nil];
    NSLog(@"哈哈 %@",[arr objectAtIndex:3]);
}

-(void)click1
{
      NSLog(@"运行正常");
//    [self performSelectorOnMainThread:@selector(go:) withObject:nil waitUntilDone:YES];
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
