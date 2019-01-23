//
//  GroupChannelsNavigationController.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 4/27/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "GroupChannelsNavigationController.h"
#import "GroupChannelsViewController.h"

@interface GroupChannelsNavigationController ()

@end

@implementation GroupChannelsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.prefersLargeTitles = YES;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    GroupChannelsViewController *vc = [[GroupChannelsViewController alloc] initWithNibName:@"GroupChannelsViewController" bundle:nil];
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
