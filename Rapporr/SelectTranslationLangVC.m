//
//  SelectTranslationLangVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/30/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "SelectTranslationLangVC.h"

@interface SelectTranslationLangVC ()

@end

@implementation SelectTranslationLangVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utils prepareSearchBarUI:self.searchBar];

    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    [self getAvailableLanguages];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (self.isSearching) {
        return [self.searchResults count];
    }
        return [_languages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    TranslationLanguage *lang = nil;

    if (self.isSearching) {
        lang = [self.searchResults objectAtIndex:[indexPath row]];

    }else{
        lang = [self.languages objectAtIndex:[indexPath row]];
    }
    
    cell.textLabel.text = lang.orgName;
    cell.detailTextLabel.text = lang.engName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSearching) {
        TranslationLanguage *lang = [self.searchResults objectAtIndex:[indexPath row]];
        [[NSUserDefaults standardUserDefaults] setValue:lang.langCede forKey:SELECT_LANGUAGE_CODE];
        [[NSUserDefaults standardUserDefaults] setValue:lang.engName forKey:SELECT_LANGUAGE_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        TranslationLanguage *lang = [self.languages objectAtIndex:[indexPath row]];
        [[NSUserDefaults standardUserDefaults] setValue:lang.langCede forKey:SELECT_LANGUAGE_CODE];
        [[NSUserDefaults standardUserDefaults] setValue:lang.engName forKey:SELECT_LANGUAGE_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)getAvailableLanguages
{
    
    self.languages = [[NSMutableArray alloc]init];
    NSMutableArray *languages = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TranslationLang" ofType:@"plist"]];
    
    for (NSDictionary *langDict in languages) {
        TranslationLanguage *lang = [[TranslationLanguage alloc]init];
        lang.langCede = langDict[@"code"];
        lang.orgName = langDict[@"orgName"];
        lang.engName = langDict[@"engName"];
        [ self.languages addObject:lang];
    }
}

#pragma mark - UISearchBar Delegates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    if([searchText isEqualToString:@""] || searchText==nil) {
        self.isSearching = NO;
        [self.tableView reloadData];
        
        
    }else{
        self.isSearching = YES;
        [self.searchResults removeAllObjects];
        
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"SELF.orgName contains[c] %@ OR SELF.engName contains[c] %@",
                                  searchText,searchText];
        
        NSArray *result = [self.languages filteredArrayUsingPredicate:predicate];
        self.searchResults = [result mutableCopy];
        [self.tableView reloadData];
    }
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.isSearching = NO;
    [searchBar resignFirstResponder];
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
