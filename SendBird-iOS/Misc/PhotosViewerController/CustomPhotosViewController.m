//
//  CustomPhotosViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "CustomPhotosViewController.h"

@interface CustomPhotosViewController ()

@property (strong) UIColor *previousNavigationBackgroundColor;

@end

@implementation CustomPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rightBarButtonItems = nil;
    self.rightBarButtonItem = nil;
    
    UIImage *closeButtonImage = [[UIImage imageNamed:@"img_btn_close_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithImage:closeButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(closeViewer:)];
    self.leftBarButtonItem = closeButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)closeViewer:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
