//
//  CreateGroupChannelNavigationController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "CreateGroupChannelNavigationController.h"
#import "CreateGroupChannelViewControllerA.h"

@interface CreateGroupChannelNavigationController ()

@end

@implementation CreateGroupChannelNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.prefersLargeTitles = NO;
    
    CreateGroupChannelViewControllerA *vc = [[CreateGroupChannelViewControllerA alloc] initWithNibName:@"CreateGroupChannelViewControllerA" bundle:nil];
    [self pushViewController:vc animated:YES];
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
