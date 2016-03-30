//
//  ViewController.m
//  HWNetworkDemo
//
//  Created by HanWei on 15/12/25.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "ViewController.h"
#import "HWNetworkManager.h"

#define HWNetworkManager [HWNetworkManager sharedManager]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self test1];
}

- (void)test1
{
    [HWNetworkManager sendRequest:@"/v2/music/search"
                    requestMethod:RequestMethodPOST
                       parameters:@{@"q":@"周杰伦"}
                    needLoadCache:YES
                requestSucceedBlk:^(id result) {
                    
                    DEBUGLog(@"result == %@",result);
                    
                } requestFaildBlk:^(NSError *error) {
                    
                    DEBUGLog(@"error == %@", error);
                }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
