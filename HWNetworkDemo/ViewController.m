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

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)getOrPost:(id)sender {
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

- (IBAction)upload:(id)sender {
    
    UIImage *image = [UIImage imageNamed:@"4da313154aa2c2c21bc5e5ff1db0faf1.jpg"];
    NSData *data = UIImagePNGRepresentation(image);//UIImageJPEGRepresentation(image, 0.5);
    
    __weak typeof(self) weakSelf = self;
    [HWNetworkManager uploadPicRequest:@"http://www.oschina.net/action/api/portrait_update"
                              fileData:data
                            parameters:@{@"uid":@"2544566"}
                           progressBlk:^(NSProgress *uploadPro) {
                               //NSLog(@"uploadPro.fractionCompleted == %f",uploadPro.fractionCompleted);
                               //NSLog(@"isMainThread==%d",[NSThread isMainThread]);
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   weakSelf.progressView.progress = uploadPro.fractionCompleted;
                               });
                               
                           }
                     requestSucceedBlk:^(id result) {
                         //NSLog(@"isMainThread==%d",[NSThread isMainThread]);
                               DEBUGLog(@"result == %@",result);
                           }
                       requestFaildBlk:^(NSError *error) {
                           //NSLog(@"isMainThread==%d",[NSThread isMainThread]);
                               DEBUGLog(@"error == %@", error);
                           }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
