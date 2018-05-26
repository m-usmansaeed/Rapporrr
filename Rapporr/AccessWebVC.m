//
//  AccessWebVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-OR on 17/06/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "AccessWebVC.h"

@interface AccessWebVC ()

@end

@implementation AccessWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: self.goRapporrTitle.attributedText];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blackColor]
                 range:NSMakeRange(6, 18)];
    [self.goRapporrTitle setAttributedText: text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.codeLabel.text = [Utils getAccessWebConsole:4];
    [self sendCode];
}

-(void)sendCode{
     NSString *fullId = [NSString stringWithFormat:@"%@-%@",[RapporrManager sharedManager].vcModel.hostID,[RapporrManager sharedManager].vcModel.userId];
    NSDictionary *params = @{
                             @"fullid" : fullId,
                             @"keycode" : self.codeLabel.text,
                             @"dev" : DEV_STRING
                             };
    [NetworkManager makePOSTCall:URI_POST_ACCESS_CODE parameters:params success:^(id data, NSString *timestamp) {
        NSLog(@"");
    } failure:^(NSError *error) {
        
    }];
}

-(IBAction)popVC:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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
