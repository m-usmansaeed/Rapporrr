//
//  SelectTranslationLangVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/30/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TranslationLanguage.h"

@interface SelectTranslationLangVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{

}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)btnBack:(id)sender;


@property (strong, nonatomic) NSMutableArray *languages;
@property (nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;

@end
