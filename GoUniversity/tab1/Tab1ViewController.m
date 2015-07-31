//
//  Tab1ViewController.m
//  GoUniversity
//
//  Created by edutech on 15/7/30.
//  Copyright (c) 2015年 luojie. All rights reserved.
//

#import "Tab1ViewController.h"

@interface Tab1ViewController ()

@end

@implementation Tab1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWidget];
}

-(void)initWidget
{
    self.navigationItem.title = @"溜达";
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
