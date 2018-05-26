//
//  JoinCompanyVC.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 18/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyModel.h"

@interface JoinCompanyVC : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    CompanyModel *selectedCompanyModel;
        
    }
    

@property (strong, nonatomic) NSMutableArray       *companyArray;
@property (strong, nonatomic) NSString             *userPhoneNumber;
@property (strong, nonatomic) IBOutlet UITableView *companiesTblView;
@property (strong, nonatomic) IBOutlet UIView      *tableViewContainer;
@property (nonatomic) BOOL isPushedFromHome;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

- (IBAction)btnBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *createCompanyContainer;

@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;



@end
