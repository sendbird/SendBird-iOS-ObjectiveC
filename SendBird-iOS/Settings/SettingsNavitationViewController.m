//
//  SettingsNavitationViewController.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 4/25/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "SettingsNavitationViewController.h"
#import "SettingsViewController.h"

@interface SettingsNavitationViewController ()

@end

@implementation SettingsNavitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationBar.prefersLargeTitles = YES;
    
    SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
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
