//
//  JoinCompanyVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 18/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "VerifyRapporrVC.h"
#import "NetworkManager.h"
#import "JoinCompanyVC.h"
#import "CompanyCell.h"
#import "NewCompanyCell.h"
#import "Constants.h"
#import "SwipeBack.h"

@interface JoinCompanyVC ()

@end

@implementation JoinCompanyVC
@synthesize userPhoneNumber;

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];


    self.navigationController.swipeBackEnabled = YES;
    
    self.tabBarController.tabBar.hidden = YES;
    
    if(self.userPhoneNumber == nil || [self.userPhoneNumber isEqualToString:@""]){
       self.userPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPhoneNumber"];
    }

    
    [self fetchCompaniesAssociatedWithNumber];
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

#pragma mark -
#pragma mark Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _companyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NewCompanyCell * cell = (NewCompanyCell *)[_companiesTblView dequeueReusableCellWithIdentifier:@"NewCompanyCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"NewCompanyCell" owner:self options:nil];
        cell=[nib objectAtIndex:0];
    }
    
    if ([_companyArray count]) {
        CompanyModel *cModel = [_companyArray objectAtIndex: indexPath.row];
        cell.titleLbl.text = cModel.companyName;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    }
    
       return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([_companyArray count]) {
        CompanyModel *cModel = [_companyArray objectAtIndex: indexPath.row];

        [self genetrateVerificationCodeForRapporr:cModel];
    }
}


#pragma mark -
#pragma mark Server Calls

- (void) fetchCompaniesAssociatedWithNumber {
    
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:userPhoneNumber,@"phone",@"OS_IOS",@"platform", nil];
    
           if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
    
    [NetworkManager getCompaniesForMobileNumber:URI_AUTHENTICATE_NUMBER parameters:paramsToBeSent success:^(id data, NSString *timestamp) {
        
        NSError* error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        if(!jsonArray) {
            
            _tableViewContainer.hidden = true;
        }
        else if (jsonArray.count == 0) {
            _tableViewContainer.hidden = true;
        }
        else {
            _tableViewContainer.hidden = false;
            self.companyArray = [[NSMutableArray alloc] init];
            for(int i=0; i<jsonArray.count; i++) {
                CompanyModel *cModel = [[CompanyModel alloc] initWithDictionary:[jsonArray objectAtIndex:i]];
                [self.companyArray addObject:cModel];
            }
            
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"companyName" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSArray *sortedArray;
            sortedArray = [self.companyArray sortedArrayUsingDescriptors:sortDescriptors];
            
            self.companyArray = [[NSMutableArray alloc] initWithArray:sortedArray];
            
            if ([self.companyArray count]) {
                [_companiesTblView reloadData];
            }
        }
        
    }failure:^(NSError *error) {
        _tableViewContainer.hidden = true;
        NSLog(@"Error");
    }];
           }else{
               [appDelegate showUnavailablityAlert];

           }
}

- (void) genetrateVerificationCodeForRapporr : (CompanyModel*) cModel {
   
    selectedCompanyModel = cModel;
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:userPhoneNumber,@"phone",@"OS_IOS",@"platform",cModel.hostID,@"hostId", nil];
    
    if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {

    [NetworkManager generateVerificationCode:URI_AUTHENTICATE_NUMBER parameters:paramsToBeSent success:^(id data, NSString *timestamp) {
        
        NSError* error;
        
        [self performSegueWithIdentifier:@"verifyRapporr" sender:self];
        
    }failure:^(NSError *error) {
        NSLog(@"Error");
    }];}else{
        [appDelegate showUnavailablityAlert];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"verifyRapporr"]) {
        
        VerifyRapporrVC *destSegue = [segue destinationViewController];
        destSegue.cModel = selectedCompanyModel;
    }
}



- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Network Status
-(void)didNetworkConnected:(AFNetworkReachabilityStatus)status;{
    self.seachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];
}

-(void)didNetworkDisconnected:(AFNetworkReachabilityStatus)status;{
    self.seachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];
    [appDelegate showAlertView];
}


@end
