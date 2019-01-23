//
//  OpenChannelsNavigationController.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 4/26/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "OpenChannelsNavigationController.h"
#import "OpenChannelsViewController.h"

@interface OpenChannelsNavigationController ()

@end

@implementation OpenChannelsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.prefersLargeTitles = YES;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    OpenChannelsViewController *vc = [[OpenChannelsViewController alloc] initWithNibName:@"OpenChannelsViewController" bundle:nil];
    [self pushViewController:vc animated:NO];
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

@end
