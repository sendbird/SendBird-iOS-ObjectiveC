//
//  CreateOpenChannelNavigationController.m
//  SendBird-iOS
//
//  Created by SendBird on 1/9/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "CreateOpenChannelNavigationController.h"
#import "CreateOpenChannelViewControllerA.h"

@interface CreateOpenChannelNavigationController ()

@end

@implementation CreateOpenChannelNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.prefersLargeTitles = NO;
    
    CreateOpenChannelViewControllerA *vc = [[CreateOpenChannelViewControllerA alloc] initWithNibName:@"CreateOpenChannelViewControllerA" bundle:nil];
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
