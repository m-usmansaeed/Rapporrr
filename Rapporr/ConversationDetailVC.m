//
//  ConversationDetailVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "ConversationDetailVC.h"

#import "NSString+email.h"
#import "Utils.h"
#import "ChatMessageDetailVC.h"
#import "ChatDetailVC.h"
#import "BaseChatCell.h"
#import "CustomChatTextCell.h"
#import "CustomExpendedText.h"
#import "GPSLocationModel.h"
#import "CustomChatAnnouncementCell.h"
#import "CustomeChatCellLinkAnnouncement.h"
#import "CustomChatLocationCell.h"
#import "CustomChatNewUserCell.h"
#import "CustomChatEventCell.h"
#import "ContactModel.h"
#import "CustomChatContactCell.h"


#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@interface ConversationDetailVC ()

@end

@implementation ConversationDetailVC{
    
    NSOperationQueue *_backgroundOperationQueue;
    
}

- (void) refreshViewforNotification{
    
    [self getMessagesFromDb];
}

-(void)conversationUpdated{

//    ALog(@"%lu",(unsigned long)self.conversation.messages.count);
    
}

-(void)reloadData{
    
    ALog(@"reloadData");

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUpGestures];
    [self addFloatingButton];
    [self layoutOptionsTitleView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewforNotification) name:@"refreshViewForNotification" object:nil];
    
    /*
//    1
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomExpendedText" bundle:nil] forCellReuseIdentifier:@"CustomExpendedText"];
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomChatTextCell" bundle:nil] forCellReuseIdentifier:@"CustomChatTextCell"];

//    2
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"LinkExpandedCell" bundle:nil] forCellReuseIdentifier:@"LinkExpandedCell"];
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomeChatCellLinkAnnouncement" bundle:nil] forCellReuseIdentifier:@"CustomeChatCellLinkAnnouncement"];
    
//    3
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"LinkExpandedCell" bundle:nil] forCellReuseIdentifier:@"LinkExpandedCell"];
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomeChatCellLinkAnnouncement" bundle:nil] forCellReuseIdentifier:@"CustomeChatCellLinkAnnouncement"];
    
//    4
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomExpandedImageAnnouncementCell" bundle:nil] forCellReuseIdentifier:@"CustomExpandedImageAnnouncementCell"];
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomChatAnnouncementCell" bundle:nil] forCellReuseIdentifier:@"CustomChatAnnouncementCell"];

    
    //    5
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"LocationExtandedCell" bundle:nil] forCellReuseIdentifier:@"LocationExtandedCell"];
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomChatLocationCell" bundle:nil] forCellReuseIdentifier:@"CustomChatLocationCell"];

    
    //    6
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"PictureExpandedCell" bundle:nil] forCellReuseIdentifier:@"PictureExpandedCell"];
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"PictureCell" bundle:nil] forCellReuseIdentifier:@"PictureCell"];

   
   
    //    7
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"ContactExpandedCell" bundle:nil] forCellReuseIdentifier:@"ContactExpandedCell"];
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomChatContactCell" bundle:nil] forCellReuseIdentifier:@"CustomChatContactCell"];

    
    //    8
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"FileSharingExpandedCell" bundle:nil] forCellReuseIdentifier:@"FileSharingExpandedCell"];
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"FileSharingCell" bundle:nil] forCellReuseIdentifier:@"FileSharingCell"];
    
    
    //    9
    [self.customizeTblView registerNib:[UINib nibWithNibName:@"CustomChatNewUserCell" bundle:nil] forCellReuseIdentifier:@"CustomChatNewUserCell"];
*/
    
    
    [self.conversation rz_addTarget:self
                        action:@selector(conversationUpdated)
              forKeyPathChange:@"messages"];


    [self.customizeTblView rz_addTarget:self
                             action:@selector(reloadData)
                   forKeyPathChange:@"reloadData"];

    

//--------
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    self.customizeTblView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;


    if (!_backgroundOperationQueue) {
        _backgroundOperationQueue = [[NSOperationQueue alloc] init];
    }
    
    if (self.conversation.messages) {
        if (self.conversationDictData == nil){
            
            [self fetchConversationMessages];
        }
    }
    
    _cellHeighs = [[NSMutableDictionary alloc]init];
    headersArray = [Utils getConversationTableViewSectionByDates];
    
    if(_conversation) {
        _lblTitle.text = [NSString stringWithFormat:@"%@",[self.conversation.about capitalizedString]];
        [self getMessagesFromDb];
        
        if ([self.conversation.messages count]>2) {
            NSInteger lastSectionIndex = MAX(0, [self.customizeTblView numberOfSections] - 1);
            NSInteger lastRowIndex = MAX(0, [self.customizeTblView numberOfRowsInSection:lastSectionIndex] - 1);
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex
                                                            inSection:lastSectionIndex];
            [self.customizeTblView scrollToRowAtIndexPath:lastIndexPath
                                         atScrollPosition:UITableViewScrollPositionBottom
                                                 animated:NO];
        }
    }else{
        _lblTitle.text = [NSString stringWithFormat:@""];
        _conversation = [[MessageModel alloc] init];
    }

    [self performSeenAction];
    [self updateMessageCounter];
}

- (DotActivityIndicatorParms *)loadDotActivityIndicatorParms
{
    DotActivityIndicatorParms *dotParms = [DotActivityIndicatorParms new];
    dotParms.activityViewWidth = dotsActivityView.frame.size.width;
    dotParms.activityViewHeight = dotsActivityView.frame.size.height;
    dotParms.numberOfCircles = 6;
    dotParms.internalSpacing = 5;
    dotParms.animationDelay = 0.2;
    dotParms.animationDuration = 0.6;
    dotParms.animationFromValue = 0.3;
    dotParms.defaultColor = App_OrangeColor;
    dotParms.isDataValidationEnabled = YES;
    return dotParms;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [RKDropdownAlert dismissAllAlert];
    [_customAlert removeCustomAlertFromViewInstantly];
    
    self.navigationController.swipeBackEnabled = NO;
    
    self.navigationController.tabBarController.tabBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self initializeScreen];
}


- (void) updateMessageCounter {
    self.conversation.unReadMsgsCount = @"0";
    [[CoreDataController sharedManager] UpdateMessageModel:self.conversation];
}

-(void) setUpGestures {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.headerView addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(pan:)];
    [self.editMessageContainer addGestureRecognizer: panGesture];
}

-(void) setUpLocationManager {
    
    self.locationMap.delegate = self;
    self.locationMap.showsUserLocation = YES;
    [self.locationMap setMapType:MKMapTypeStandard];
    [self.locationMap setZoomEnabled:YES];
    [self.locationMap setScrollEnabled:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    
    
    //Checking authorization status
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        if (![CLLocationManager locationServicesEnabled])
        {
            
            NSLog(@"%d",[CLLocationManager authorizationStatus]);
            
            //            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
            //            }else{
            [self showLocationAlertWithTag:100];
            //            }
        }
        
        else
        {
            //            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
            //            }else{
            [self showLocationAlertWithTag:200];
            //            }
        }
        
        return;
    }
    else
    {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager requestAlwaysAuthorization];
        }else{
            [self.locationManager startUpdatingLocation];
            
        }
        [self.addAcctionsBgView setHidden:YES];
        self.addMenuButton.hidden = YES;
        _actionBgView.hidden = true;
        _locationScreen.hidden = false;
        
    }
}

-(void)showLocationAlertWithTag:(NSInteger)tag{
    
    if (tag == 100)
    {
        [self setUpAlertView];
        _customAlert.isButtonSwitch = YES;
        _customAlert.alertTag = tag;
        _customAlert.alertType = kAlertTypeMessage;
        [_customAlert showCustomAlertInView:self.view withMessage:@"Location Services Disabled!" andDescription:@"Please enable Location Based Services for better results! We promise to keep your location private" setOkTitle:@"Cancel" setCancelTitle:@"Settings"];
    }
    else if (tag == 200)
    {
        [self setUpAlertView];
        _customAlert.isButtonSwitch = YES;
        _customAlert.alertTag = tag;
        _customAlert.alertType = kAlertTypeMessage;
        
        [_customAlert showCustomAlertInView:self.view withMessage:@"Location Services Disabled!" andDescription:@"Please enable Location Based Services for better results! We promise to keep your location private" setOkTitle:@"Cancel" setCancelTitle:@"Settings"];
    }
}

//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
//{
//    //Checking authorization status
//    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
//    {
//        if (![CLLocationManager locationServicesEnabled])
//        {
//            [self showLocationAlertWithTag:100];
//        }
//        else
//        {
//            [self showLocationAlertWithTag:200];
//        }
//
//        [self.addAcctionsBgView setHidden:NO];
//        self.addMenuButton.hidden = NO;
//        _actionBgView.hidden = NO;
//        _locationScreen.hidden = YES;
//
//        return;
//    }
//    else
//    {
//        [self.locationManager startUpdatingLocation];
//    }
//}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [self.locationMap setRegion:region animated:YES];
    
}

- (void) sortMessagesDictionary {
    
    messagesDictArray = [[NSMutableArray alloc] init];
    NSArray *array = nil;
    for(NSDate *tempDate in uniqueDates) {
        
        NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
                                                                ascending:YES
                                                                 selector:@selector(caseInsensitiveCompare:)];
        
        array = [self.conversation.messages sortedArrayUsingDescriptors:@[sort]];
        
        NSMutableArray *messagesArrayForSpan = [self getMesagesForSpan:tempDate andArray:[array mutableCopy]];
        if(messagesArrayForSpan.count>0){
            NSMutableDictionary *dictForDate = [[NSMutableDictionary alloc] init];
            [dictForDate setObject:messagesArrayForSpan forKey:@"array"];
            [dictForDate setObject:tempDate forKey:@"day"];
            [messagesDictArray addObject:dictForDate];
        }
    }
}


-(void) initializeScreen {
    
    _textView.contentInset = UIEdgeInsetsMake(5, 5, 5, 2);
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.font = [UIFont systemFontOfSize:15.0f];
    _textView.delegate = (id)self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    
    
    [self.view addSubview:self.addMenuButton];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupRefreshControl];
    
    
    if (self.conversationDictData != nil) {
        _lblTitle.text = [NSString stringWithFormat:@"%@",self.conversationDictData[@"about"]];
    }
    isDataLoaded = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (void)addFloatingButton {
    
    CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60 - 20, [UIScreen mainScreen].bounds.size.height - 60 - 80, 60, 60);
    
    self.addMenuButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"add_plus_new"] andPressedImage:[UIImage imageNamed:@"add_plus_new_press"] withScrollview:self.customizeTblView];
    
    self.addMenuButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.addMenuButton.layer.shadowOffset = CGSizeMake(1, 1);
    self.addMenuButton.layer.shadowOpacity = 0.3;
    self.addMenuButton.layer.shadowRadius = 2.0;
    self.addMenuButton.hideWhileScrolling = NO;
    self.addMenuButton.delegate = (id)self;
    [self.view addSubview:self.addMenuButton];
    
}


-(void) didMenuButtonTapped:(id)button;
{
    [self.addAcctionsBgView setHidden:NO];
    self.addMenuButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return messagesDictArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
    NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:section];
    return [tempDict objectForKey:@"day"];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, tableView.frame.size.width, 19)];
    if (IS_IPHONE_4) {
        [label setFont:ROBOTO_REGULAR(13)];
    }
    [label setFont:ROBOTO_LIGHT(15)];
    NSString *string = @"";
    NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:section];
    NSDate *tempDate = [tempDict objectForKey:@"day"];
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd MMM yyyy"]; // Date formater
    string = [dateformate stringFromDate:tempDate];
    
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:section];
    NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
    return arrayOfSection.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:indexPath.section];
    NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
    RPConverstionMessage *message = (RPConverstionMessage*)[arrayOfSection objectAtIndex:indexPath.row];
    NSDate *tempDate = [tempDict objectForKey:@"day"];
    
    
    NSDateFormatter *dateformate = [NSDateFormatter defaultDateManager];
    [dateformate setDateFormat:@"dd MMM yyyy"]; // Date formater
    NSString *string = [dateformate stringFromDate:tempDate];
    
    NSString *expectedString = [Utils getTableViewHeaderForDate:tempDate];
    
    if(expectedString) {
        string = expectedString;
    }
    
    CustomChatTextCell * cell = (CustomChatTextCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomChatTextCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomChatTextCell" owner:self options:nil];
        cell=[nib objectAtIndex:0];
    }

    message.seenByUsers = [[message.seenByUsers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]]] mutableCopy];

    if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPE_TEXT]) {
        if(message.isExpanded) {
            CustomExpendedText * cell = (CustomExpendedText *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomExpendedText"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomExpendedText" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.delegate = (id)self;
            cell.indexPath = indexPath;
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            return cell;
        }
        else {
            CustomChatTextCell * cell = (CustomChatTextCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomChatTextCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomChatTextCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.indexPath = indexPath;
            cell.delegate = (id)self;
            
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            return cell;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
        if([message.announcement.attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_URL])
        {
            if (message.isExpanded) {
                LinkExpandedCell * cell = (LinkExpandedCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"LinkExpandedCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"LinkExpandedCell" owner:self options:nil];
                    cell=[nib objectAtIndex:0];
                }
                cell.message = message;
                cell.conversation = self.conversation;
                cell.delegate = (id)self;
                cell.indexPath = indexPath;
                
                [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
                return cell;
            }
            else{
                CustomeChatCellLinkAnnouncement * cell = (CustomeChatCellLinkAnnouncement *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomeChatCellLinkAnnouncement"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomeChatCellLinkAnnouncement" owner:self options:nil];
                    cell=[nib objectAtIndex:0];
                }
                cell.message = message;
                cell.conversation = self.conversation;
                cell.indexPath = indexPath;
                cell.delegate = (id)self;
                
                [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
                return cell;
            }
        }
        else if([message.announcement.attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_Photo])
        {
            if (message.isExpanded)
            {
                CustomExpandedImageAnnouncementCell * cell = (CustomExpandedImageAnnouncementCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomExpandedImageAnnouncementCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomExpandedImageAnnouncementCell" owner:self options:nil];
                    cell=[nib objectAtIndex:0];
                }
                cell.message = message;
                cell.conversation = self.conversation;
                cell.delegate = (id)self;
                cell.context = self;
                cell.indexPath = indexPath;
                
                [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
                return cell;
            }
            else{
                
                CustomChatAnnouncementCell * cell = (CustomChatAnnouncementCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomChatAnnouncementCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomChatAnnouncementCell" owner:self options:nil];
                    cell = [nib objectAtIndex:0];
                }
                cell.message = message;
                cell.context = self;
                cell.delegate = (id)self;
                
                cell.conversation = self.conversation;
                cell.indexPath = indexPath;
                
                [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
                return cell;
            }
        }else
        {
            if (message.isExpanded) {
                LinkExpandedCell * cell = (LinkExpandedCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"LinkExpandedCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"LinkExpandedCell" owner:self options:nil];
                    cell=[nib objectAtIndex:0];
                }
                cell.message = message;
                cell.conversation = self.conversation;
                cell.delegate = (id)self;
                cell.indexPath = indexPath;
                
                [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
                return cell;
            }
            else{
                CustomeChatCellLinkAnnouncement * cell = (CustomeChatCellLinkAnnouncement *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomeChatCellLinkAnnouncement"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomeChatCellLinkAnnouncement" owner:self options:nil];
                    cell=[nib objectAtIndex:0];
                }
                cell.message = message;
                cell.conversation = self.conversation;
                cell.indexPath = indexPath;
                cell.delegate = (id)self;
                
                [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
                return cell;
            }
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPELOCATION]) {
        
        
        //        NSError *error;
        //        NSString *dictString=[NSString stringWithFormat:@"%@", message.objects];
        //        NSData *jsonData = [dictString dataUsingEncoding:NSUTF8StringEncoding];
        //        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
        //                                                             options:NSJSONReadingMutableContainers
        //                                                               error:&error];
        //        GPSLocationModel *gpModel = [[GPSLocationModel alloc] initWithDictionary:json];
        //        message.locationModel = gpModel;
        
        
        if (message.isExpanded) {
            LocationExtandedCell * cell = (LocationExtandedCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"LocationExtandedCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"LocationExtandedCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.delegate = (id)self;
            cell.indexPath = indexPath;
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            
            return cell;
        }
        else{
            CustomChatLocationCell * cell = (CustomChatLocationCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomChatLocationCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomChatLocationCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.indexPath = indexPath;
            cell.delegate = (id)self;
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            
            return cell;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEUserAdded]) {
        CustomChatNewUserCell * cell = (CustomChatNewUserCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomChatNewUserCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomChatNewUserCell" owner:self options:nil];
            cell=[nib objectAtIndex:0];
        }
        cell.titleLbl.text = message.message;
        
        return cell;
    }
    else if ([message.contentType isEqualToString:@"event"]) {
        if (message.isExpanded) {
            EventExpandedCell * cell = (EventExpandedCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"EventExpandedCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"EventExpandedCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.delegate = (id)self;
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            cell.indexPath = indexPath;
            
            return cell;
        }
        else{
            CustomChatEventCell * cell = (CustomChatEventCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomChatEventCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomChatEventCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            cell.indexPath = indexPath;
            cell.delegate = (id)self;
            
            return cell;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto]){
        
        if (message.isExpanded) {
            PictureExpandedCell * cell = (PictureExpandedCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"PictureExpandedCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"PictureExpandedCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.context = self;
            cell.indexPath = indexPath;
            cell.dateLbl.text = [NSDate dateTimeForRapporr:message.timeStamp];
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            cell.delegate = (id)self;
            
            return cell;
        }
        
        else{
            
            PictureCell * cell = (PictureCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"PictureCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"PictureCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.context = self;
            
            cell.indexPath = indexPath;
            cell.delegate = (id)self;
            
            cell.dateLbl.text = [NSDate dateTimeForRapporr:message.timeStamp];
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            
            return cell;
        }
    }
    else if ([message.contentType isEqualToString:@"link"]) {
        
        //        NSError *error;
        //        NSString *dictString=[NSString stringWithFormat:@"%@", message.objects];
        //        NSData *jsonData = [dictString dataUsingEncoding:NSUTF8StringEncoding];
        //        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
        //                                                             options:NSJSONReadingMutableContainers
        //                                                               error:&error];
        if (message.isExpanded) {

            ContactExpandedCell * cell = (ContactExpandedCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"ContactExpandedCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"ContactExpandedCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.indexPath = indexPath;
            cell.delegate = (id)self;
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];

            return cell;
        }
        else{
            
            CustomChatContactCell * cell = (CustomChatContactCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"CustomChatContactCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomChatContactCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            cell.indexPath = indexPath;
            cell.delegate = (id)self;
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            
            return cell;
            
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEFileAdded]){
        
        if(message.isExpanded) {
            FileSharingExpandedCell * cell = (FileSharingExpandedCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"FileSharingExpandedCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"FileSharingExpandedCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            
            
            cell.dateLbl.text = [NSDate dateTimeForRapporr:message.timeStamp];
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            cell.indexPath = indexPath;
            cell.delegate = (id)self;
            
            return cell;
            
        }
        else {
            FileSharingCell * cell = (FileSharingCell *)[_customizeTblView dequeueReusableCellWithIdentifier:@"FileSharingCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"FileSharingCell" owner:self options:nil];
                cell=[nib objectAtIndex:0];
            }
            cell.message = message;
            cell.conversation = self.conversation;
            
            cell.dateLbl.text = [NSDate dateTimeForRapporr:message.timeStamp];
            [cell customizeCell:message andIndexPath:indexPath andTimeStr:string];
            cell.indexPath = indexPath;
            cell.delegate = (id)self;
            
            return cell;
            
        }
    }
    return cell;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:indexPath.section];
    NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
    RPConverstionMessage *message = (RPConverstionMessage*)[arrayOfSection objectAtIndex:indexPath.row];
    
    if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPE_TEXT]) {
        
        NSString * messageStr = message.message;
        CGSize textSize = [messageStr sizeWithFont:ROBOTO_LIGHT(15) constrainedToSize:CGSizeMake(210, 20000) lineBreakMode: UILineBreakModeClip]; //Assuming your width is 240
    
        
        float heightToAdd = MAX(textSize.height, 67.0f);
        
        if (message.translation) {
            
            NSString * translation = message.translation;
            CGSize translationSize = [translation sizeWithFont:ROBOTO_LIGHT(14) constrainedToSize:CGSizeMake(208, 20000) lineBreakMode: UILineBreakModeWordWrap]; //Assuming your width is 240
            float translationSizeheightToAdd = MAX(translationSize.height, 67.0f);
            heightToAdd = heightToAdd+translationSizeheightToAdd;
        }
        
        
        //Some fix height is returned if height is small or change it to MAX(textSize.height, 150.0f); // whatever best fits for you
        //osama - chat size
        if(message.isExpanded) {
            
            if(heightToAdd>67){
                heightToAdd = heightToAdd-67;
                return 190+heightToAdd;
            }
            return 190;
        }
        else {
            
            if(heightToAdd>67){
                heightToAdd = heightToAdd-67;
                return 134+heightToAdd;
            }
            return 134;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto]){
        if (message.isExpanded) {
            //osama- chat Size
            return 317;
        }else{
            return 260;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
        if([message.announcement.attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_URL]) {
            if (message.isExpanded) {
                return 200;
            }else{
                return 150;
            }
        }
        else if([message.announcement.attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_Photo]){

            //osama - chat size
            if (message.isExpanded) {
                return 367;
            }else{
                return 305;
            }
        }else{
            if (message.isExpanded) {
                return 200;
            }else{
                return 150;
            }
        }
    }
    else if([message.contentType isEqualToString:MESSAGE_CONTENT_TYPELOCATION]) {
        //osama - chat size
        if(message.isExpanded) {
            return 355;
        }
        else {
            return 300;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEUserAdded]) {
        return 44;
    }
    else if ([message.contentType isEqualToString:@"event"]) {
        //osama - chat size
        if(message.isExpanded) {
            return 236;
        }
        else {
            return 180;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEShareContact]) {
        if(message.isExpanded) {
            return 211;
        }else{
            return 150;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEFileAdded]) {
        if(message.isExpanded) {
            return 206;
        }else{
            return 145;
        }
    }
    else {
        return 100;
    }
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:indexPath.section];
    NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
    RPConverstionMessage *message = (RPConverstionMessage*)[arrayOfSection objectAtIndex:indexPath.row];
    
    if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPE_TEXT]) {
        
        NSString * messageStr = message.message;
        CGSize textSize = [messageStr sizeWithFont:ROBOTO_LIGHT(15) constrainedToSize:CGSizeMake(210, 20000) lineBreakMode: UILineBreakModeClip]; //Assuming your width is 240
        
        
        float heightToAdd = MAX(textSize.height, 67.0f);
        
        if (message.translation) {
            
            NSString * translation = message.translation;
            CGSize translationSize = [translation sizeWithFont:ROBOTO_LIGHT(14) constrainedToSize:CGSizeMake(208, 20000) lineBreakMode: UILineBreakModeWordWrap]; //Assuming your width is 240
            float translationSizeheightToAdd = MAX(translationSize.height, 67.0f);
            heightToAdd = heightToAdd+translationSizeheightToAdd;
        }
        
        
        //Some fix height is returned if height is small or change it to MAX(textSize.height, 150.0f); // whatever best fits for you
        //osama - chat size
        if(message.isExpanded) {
            
            if(heightToAdd>67){
                heightToAdd = heightToAdd-67;
                return 174+heightToAdd;
            }
            return 174;
        }
        else {
            
            if(heightToAdd>67){
                heightToAdd = heightToAdd-67;
                return 134+heightToAdd;
            }
            return 134;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto]){
        if (message.isExpanded) {
            //osama- chat Size
            return 307;
        }else{
            return 260;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
        if([message.announcement.attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_URL]) {
            if (message.isExpanded) {
                return 200;
            }else{
                return 154;
            }
        }
        if([message.announcement.attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_Photo]) {
            //osama - chat size
            if (message.isExpanded) {
                return 351;
            }else{
                return 305;
            }
        }else{
            if (message.isExpanded) {
                return 200;
            }else{
                return 150;
            }
        }
    }
    else if([message.contentType isEqualToString:MESSAGE_CONTENT_TYPELOCATION]) {
        //osama - chat size
        if(message.isExpanded) {
            return 345;
        }
        else {
            return 300;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEUserAdded]) {
        return 44;
    }
    else if ([message.contentType isEqualToString:@"event"]) {
        //osama - chat size
        if(message.isExpanded) {
            return 226;
        }
        else {
            return 180;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEShareContact]) {
        if(message.isExpanded) {
            return 195;
        }else{
            return 150;
        }
    }
    else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEFileAdded]) {
        if(message.isExpanded) {
            return 195;
        }else{
            return 145;
        }
    }
    else {
        return 100;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{

    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
{

    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:indexPath.section];
    NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
    
    RPConverstionMessage *message = (RPConverstionMessage*)[arrayOfSection objectAtIndex:indexPath.row];
    
    if(message.isExpanded) {
        message.isExpanded = false;
    }
    else {
        for (RPConverstionMessage *amessage in arrayOfSection) {
            amessage.isExpanded = false;
        }
        
        [UIView performWithoutAnimation:^{
            [self.customizeTblView reloadData];
        }];
        
        message.isExpanded = true;
    }
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
    
    if (indexPath == pathToLastRow) {
        
        [UIView performWithoutAnimation:^{
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }];
        
    }else{
        
        NSMutableArray *modifiedRows = [NSMutableArray array];
        [modifiedRows addObject:indexPath];
        [UIView performWithoutAnimation:^{
            [tableView reloadRowsAtIndexPaths:modifiedRows withRowAnimation:UITableViewRowAnimationNone];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma Custom Cell Delegate


-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath; {
    
    NSString *selectedLangCode = [NSString validStringForObject:[[NSUserDefaults standardUserDefaults] valueForKey:SELECT_LANGUAGE_CODE]];
    __weak __typeof(self)weakSelf = self;
    
    if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPE_TEXT]) {
        
        if (![selectedLangCode  isEqualToString: BASE_LANGUAGE_CODE] && ![selectedLangCode isEqualToString:@""]) {
            
            if (message.message != nil || ![message.message isEqualToString:@""]) {
                
                [SVProgressHUD show];
                [[TranslationManager translator] translateText:message.message withSource:BASE_LANGUAGE_CODE target:selectedLangCode completion:^(NSError *error, NSString *translated, NSString *sourceLanguage) {
                    
                    if (error)
                    {
                        [self showErrorWithError:error];
                        [SVProgressHUD dismiss];
                    }
                    else
                    {
                        weakSelf.expandIndexPath = nil;
                        
                        if (![translated isEqualToString:message.message]) {
                            
                            message.translation = [NSString validStringForObject:translated];
                            NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:indexPath.section];
                            NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
                            for (RPConverstionMessage *message in arrayOfSection) {
                                message.isExpanded = NO;
                            }
                            NSInteger lastSectionIndex = [self.customizeTblView numberOfSections] - 1;
                            NSInteger lastRowIndex = [self.customizeTblView numberOfRowsInSection:lastSectionIndex] - 1;
                            NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
                            self.customizeTblView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                            
                            NSMutableArray *modifiedRows = [NSMutableArray array];
                            
                            if ([indexPath isEqual:self.expandIndexPathOnTranslation]) {
                                [modifiedRows addObject:self.expandIndexPathOnTranslation];
                                self.expandIndexPathOnTranslation = nil;
                            } else {
                                if (self.expandIndexPathOnTranslation){
                                    [modifiedRows addObject:self.expandIndexPathOnTranslation];
                                }
                                self.expandIndexPathOnTranslation = indexPath;
                                [modifiedRows addObject:indexPath];
                            }
                            
                            if (modifiedRows != nil) {
                                
                                [UIView performWithoutAnimation:^{
                                    [self.customizeTblView reloadRowsAtIndexPaths:modifiedRows withRowAnimation:UITableViewRowAnimationAutomatic];
                                }];
                                if (indexPath == pathToLastRow) {
                                    [self.customizeTblView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
                                }else{
                                    [self.customizeTblView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                                }
                            }
                        }else{
                            [self setUpAlertView];
                            _customAlert.alertTag = 10000;
                            _customAlert.alertType = kAlertTypeDetail;
                            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                            [self.customAlert showPopUpInView:top.view withMessage:NSLocalizedString(@"Error", nil) andDescription:NSLocalizedString(@"Translation not available", nil)];
                        }
                        [SVProgressHUD dismiss];
                    }
                }];
            }
        }
        else if ([selectedLangCode  isEqualToString: BASE_LANGUAGE_CODE]){
            
            [self setUpAlertView];
            _customAlert.alertTag = 10002;
            _customAlert.alertType = kAlertTypePopup;
            NSString *message = [NSString stringWithFormat:@"Please go to settings to select a foreign language to translate from english"];
            [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Language not selected",nil) andDescription:NSLocalizedString(message,nil)];
            
        }
        else if ([selectedLangCode isEqualToString:@""]){
            
            [self setUpAlertView];
            _customAlert.alertTag = 10002;
            _customAlert.alertType = kAlertTypePopup;
            NSString *message = [NSString stringWithFormat:@"Please go to settings to select a foreign language to translate from english"];
            [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Language not selected",nil) andDescription:NSLocalizedString(message,nil)];
        }
    }
}

- (void)showErrorWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message{
    messageToForward = message;
    
    [self performSegueWithIdentifier:@"chatMessageSegue" sender:self];
    
}

-(void)didCallDownloadFile:(RPConverstionMessage *)message; {
    if ([[NSString validStringForObject:message.attachment.localUrl] isEqualToString:@""]) {
        [NetworkManager downloadFileWithUrl:message.attachment.url completionBlock:^(NSString *filePath, BOOL isFinished) {
            message.attachment.localUrl = filePath;
            message.attachmentLocalUrl = filePath;
            [[CoreDataController sharedManager] updateAttachmentForConversation:message];
        }];
    }else{
        
    }
    
}

-(void)didMakeCallPressed:(RPConverstionMessage *)message {
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:message.user.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}


#pragma mark -  IBAction

- (IBAction)btnBack:(id)sender {
    
    if (self.conversationDictData != nil) {
        
        [self setUpAlertView];
        _customAlert.isButtonSwitch = YES;
        _customAlert.alertTag = 1000;
        _customAlert.alertType = kAlertTypeMessage;
        
        [_customAlert showCustomAlertInView:self.view withMessage:@"Warning" andDescription:@"Please type in a message to start the conversation otherwise it will be deleted" setOkTitle:@"CANCEL" setCancelTitle:@"DISCARD"];
        
        
    }else{
        
        NSString *message = [self.textView.text stringByTrimingWhitespace];
        
        if (![message isEqualToString:@""]) {
            
            RPConverstionMessage *message = nil;
            BOOL isNewMessage = NO;
            if (self.unSentMessage) {
                message = self.unSentMessage;
                message.isSentMessage = NO;
                isNewMessage = NO;
            }else{
                message = [[RPConverstionMessage alloc] init];
                message.isSentMessage = NO;
                isNewMessage = YES;
                message.tempMsgId = [NSString stringWithFormat:@"Temp-%d",[Utils getRandomNumber]];
                message.convCallBackId = self.conversation.callBackId;
                message.conversationId = self.conversation.conversationId;
                message.userId = [RapporrManager sharedManager].vcModel.userId;
                message.isSeenByAll = NO;
            }
            
            message.message = self.textView.text;
            message.isTextFieldMessage = YES;
            
            if (isNewMessage) {
                [[CoreDataController sharedManager]saveConversationMessage:message];
            }else{
                [[CoreDataController sharedManager] updateMessageStatus:message withStatus:NO];
            }
        }

        if(self.isSegueUserProfile){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self popToConversation];
        }
    }
}

-(void)popToConversation {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ConversationDetailVC class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
            });
            break;
        }
    }
}


- (IBAction)btnSendMessage:(id)sender {

    ALog(@"%lu",(unsigned long)self.conversation.messages.count);
    [self sendMessageWithConversationID:self.conversation.conversationId];
}

-(MessageSeenUser *)addSelfAsSeenUser:(NSString *)withTimestamp withUserId:(NSString *)userId
{
    
    RPConverstionMessage *lastMessage = [self.conversation.messages lastObject];
    NSString *lastMessageId = lastMessage.msgId;

    MessageSeenUser *seenUser = [[MessageSeenUser alloc] init];
    seenUser.userId = [NSString stringWithFormat:@"%@",userId];
    seenUser.conversationId = [NSString stringWithFormat:@"%@",self.conversation.conversationId];
    seenUser.hostId = [NSString stringWithFormat:@"%@",[RapporrManager sharedManager].vcModel.hostID];
    seenUser.lastMessageId = [NSString stringWithFormat:@"%@",lastMessageId];
    seenUser.orgId = [NSString stringWithFormat:@"%@",[RapporrManager sharedManager].vcModel.orgId];
    seenUser.rType = @"MESSAGE";
    seenUser.timeStamp = [NSString stringWithFormat:@"%@",withTimestamp];
    
    return seenUser;
}

-(void)sendMessageWithConversationID:(NSString *)ConversationId
{
    
    BOOL isNewMessage = NO;
    BOOL sendMessage = NO;
    
    ALog(@"%lu",(unsigned long)self.conversation.messages.count);
    
    if (![self.textView.text isEqualToString:@""]) {
        if (self.unSentMessage) {
            self.messageToSend = self.unSentMessage;
            isNewMessage = NO;
            self.messageToSend.message = self.textView.text;
            self.messageToSend.contentType = MESSAGE_CONTENT_TYPE_TEXT;
            self.messageToSend.user = [[CoreDataController sharedManager] getUserWithID:self.messageToSend.userId];
        }else{
            self.messageToSend = [[RPConverstionMessage alloc] init];
            self.messageToSend.message = self.textView.text;
            self.messageToSend.contentType = MESSAGE_CONTENT_TYPE_TEXT;
            isNewMessage = YES;
            self.messageToSend.convCallBackId = self.conversation.callBackId;
            self.messageToSend.conversationId = self.conversation.conversationId;
            self.messageToSend.user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
            self.messageToSend.userId = [RapporrManager sharedManager].vcModel.userId;
        }
        sendMessage = YES;
    }
    else if ([self.messageToSend.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto] && ![self.messageToSend.message isEqualToString:@""]){
        
        sendMessage = YES;

        self.messageToSend.user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
        self.messageToSend.userId = [RapporrManager sharedManager].vcModel.userId;
        
        self.messageToSend.imageUrl = self.uploadedImageUri;
        self.messageToSend.thumbImage = self.uploadedThumbnailImageUri;
        self.messageToSend.contentType = MESSAGE_CONTENT_TYPESharePhoto;
        self.messageToSend.photoId = self.photoID;
        sendMessage = YES;
    }
    else if ([self.messageToSend.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
        sendMessage = YES;
        self.messageToSend.user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
        self.messageToSend.userId = [RapporrManager sharedManager].vcModel.userId;
    }
    else if ([self.messageToSend.contentType isEqualToString:MESSAGE_CONTENT_TYPEShareContact]) {
        
        sendMessage = YES;
        self.messageToSend.user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
        self.messageToSend.userId = [RapporrManager sharedManager].vcModel.userId;
        self.messageToSend.conversationId = self.conversation.conversationId;
    }
    else if ([self.messageType isEqualToString:MESSAGE_CONTENT_TYPEUserAdded]) {
        self.messageToSend = [[RPConverstionMessage alloc] init];
        self.messageToSend.contentType = MESSAGE_CONTENT_TYPEUserAdded;
        self.messageToSend.message = [NSString stringWithFormat:@"%@ added %@ to this conversation",[RapporrManager sharedManager].vcModel.userName,self.addedUser.name];
        
        [self.conversation.members addObject:self.addedUser];
        sendMessage = YES;
    }
    else if ([self.messageType isEqualToString:MESSAGE_CONTENT_TYPELOCATION]) {
        sendMessage = YES;
        
        self.messageToSend.user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
        self.messageToSend.userId = [RapporrManager sharedManager].vcModel.userId;
        
        self.messageToSend.imageUrl = self.uploadedImageUri;
        self.messageToSend.thumbImage = self.uploadedThumbnailImageUri;
        self.messageToSend.contentType = MESSAGE_CONTENT_TYPELOCATION;
        self.messageToSend.photoId = self.photoID;
    }
    
    
    self.messageToSend.senderName = [RapporrManager sharedManager].vcModel.userName;
    NSDateFormatter *dateFormatter = [NSDateFormatter defaultDateManager];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ";
    NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [dateFormatter setTimeZone:gmtZone];
    
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    
    self.messageToSend.timeStamp = timeStamp;
    
    if (sendMessage) {
        if (ConversationId == nil) {
            if (self.conversationDictData != nil) {
                self.btnSendMessage.userInteractionEnabled = NO;
                [NetworkManager makePOSTCall:URI_POST_START_NEW_CONVERSATION parameters:self.conversationDictData success:^(id data, NSString *timestamp) {
                    self.btnSendMessage.userInteractionEnabled = YES;
                    NSDictionary *dict = (NSDictionary *)data;
                    self.conversation.users = self.conversationDictData[@"userList"];
                    self.conversation.conversationId = dict[@"conversationId"];
                    self.conversation.about = self.conversationDictData[@"about"];
                    self.conversation.startingUser = [RapporrManager sharedManager].vcModel.userId;
                    
                    NSDateFormatter *dateFormatter = [NSDateFormatter defaultDateManager];
                    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ";
                    NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
                    [dateFormatter setTimeZone:gmtZone];
                    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                    self.conversation.timeStamp = timeStamp;
                    
                    for (NSString *userId in self.conversation.users) {
                        [self.conversation.members addObject:[[CoreDataController sharedManager] getUserWithID:userId]];
                    }
                    
                    [[CoreDataController sharedManager] saveMessageModel:self.conversation];
                    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
                    //            NSDictionary* userInfo = @{@"conversation": self.conversation};
                    [nc postNotificationName:@"NewConversation" object:self];
                    
                    if (self.conversationDictData != nil) {
                        self.conversationDictData = nil;
                    }
                    
                    [self sendMessageWithConversationID:self.conversation.conversationId];
                    
                } failure:^(NSError *error) {
                    
                }];
            }
        }
        else{
            
//            ALog(@"%lu",(unsigned long)self.conversation.messages.count);

            self.messageToSend.isTextFieldMessage = NO;

            NSBlockOperation *messageSendingQueue = [[NSBlockOperation alloc] init];
            __weak __typeof(self)weakSelf = self;
            __weak NSBlockOperation *weakOp = messageSendingQueue;
            
            [messageSendingQueue addExecutionBlock:^(void){
                if (!weakOp.isCancelled) {
                    [self sendMessage:self.messageToSend];
                }
            }];
            
            if (messageSendingQueue) {
                [_backgroundOperationQueue addOperation:messageSendingQueue];
            }
            
//            ---------------------------------------
            self.messageToSend.tempMsgId = [NSString stringWithFormat:@"Temp-%d",[Utils getRandomNumber]];
            self.messageToSend.user.seen = [self addSelfAsSeenUser:timeStamp withUserId:[RapporrManager sharedManager].vcModel.userId];

            if ([self.conversation.messages count]>1) {
//                self.convMessages = self.conversation.messages;
            }else{
//                self.conversation.messages = self.convMessages;
            }
            
            [self.conversation.messages addObject:self.messageToSend];
            
//            ALog(@"%lu",(unsigned long)self.conversation.messages.count);
            
            [[CoreDataController sharedManager] saveConversationMessage:self.messageToSend];
            
            if (self.conversation.messages == nil) {
                
                self.conversation.messages = [[NSMutableArray alloc]init];
                [self getMessagesFromDb];
            }
            
//---------------------------------------------------
            
            self.unSentMessage = nil;
            [self.view setNeedsLayout];
            self.textView.text = @"";
            [UIView performWithoutAnimation:^{
            
//                ALog(@"%lu",(unsigned long)self.conversation.messages.count);
            
                [self getUniqueDates];
                [self sortMessagesDictionary];
                [self.customizeTblView reloadData];
                
                if (self.customizeTblView.contentSize.height > self.customizeTblView.frame.size.height)
                {
                    CGPoint offset = CGPointMake(0, self.customizeTblView.contentSize.height - self.customizeTblView.frame.size.height);
                    [self.customizeTblView setContentOffset:offset animated:NO];
                }
            }];
        }
    }
}

-(void)sendMessage:(RPConverstionMessage *)message {
    
    __weak typeof(self) weakSelf = self;
    
//    NSValue *nonretainedMessage = [NSValue valueWithNonretainedObject:message];

//    ALog(@"%lu",(unsigned long)self.conversation.messages.count);
    
//    -------------------------------------------------------------------------------------
    
    
    NSString *userId     = [RapporrManager sharedManager].vcModel.userId;
    NSString *senderName = [RapporrManager sharedManager].vcModel.userName;
    NSString *hostId     = [RapporrManager sharedManager].vcModel.hostID;
    NSString *callbackId = [NSString stringWithFormat:@"%@-%@%@",hostId,userId,[NSDate getTimestampForCallBackId]];
    NSString *messageAttachments = @"";
    
    ALog(@"%lu",(unsigned long)self.conversation.messages.count);
    
    
    if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto]){
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPESharePhoto,
                                 @"photoID" :  message.photoId
                                 };
        
        messageAttachments =  [object jsonString];
        message.contentType = MESSAGE_CONTENT_TYPESharePhoto;
        message.imageUrl = message.tempImageUrl;
        message.thumbImage = message.tempThumbImageUrl;
        
    }
    else  if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]){
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPEAnnouncement,
                                 @"photoID" :  [NSString validStringForObject:message.announcement.photoId],
                                 @"announcement": [NSString validStringForObject:message.announcement.title],
                                 @"title": [NSString validStringForObject:message.announcement.title],
                                 @"source" : @{
                                         @"rapporrverison" : @"300",
                                         @"platform" : @"ios",
                                         },
                                 
                                 @"attachments" : @{
                                         @"contentType" : [NSString validStringForObject:message.announcement.attachment.contentType],
                                         @"category" : [NSString validStringForObject:message.announcement.attachment.category],
                                         @"title" : [NSString validStringForObject:message.announcement.attachment.title],
                                         @"url" : [NSString validStringForObject:message.announcement.attachment.url],
                                         }
                                 };
        
        messageAttachments =  [object jsonString];
    } else  if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPELOCATION]){
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPELOCATION,
                                 @"photoID" :  [NSString validStringForObject:message.photoId],
                                 @"type": @"map",
                                 @"shared": @"false",
                                 @"title": [NSString validStringForObject:message.locationModel.titleStr],
                                 @"source" : @{
                                         @"rapporrverison" : @"300",
                                         @"platform" : @"ios",
                                         },
                                 @"gps" : @{
                                         @"timestamp" : message.timeStamp,
                                         @"longitude" : message.locationModel.longitude,
                                         @"latitude" : message.locationModel.latitude,
                                         @"speed" : @"0",
                                         @"accuracy" : @"13.781000137329102",
                                         @"heading" : @"0",
                                         @"altitude" : @"0",
                                         }
                                 };
        
        messageAttachments =  [object jsonString];
    }
    else  if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEShareContact]){
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPEShareContact,
                                 @"category" :  @"phoneLink",
                                 @"title": [NSString validStringForObject:message.contactModel.title],
                                 @"phone": [NSString validStringForObject:message.contactModel.phone],
                                 @"source" : @{
                                         @"rapporrverison" : @"300",
                                         @"platform" : @"ios",
                                         }
                                 };
        
        messageAttachments =  [object jsonString];
    }
    else if ([self.messageType isEqualToString:MESSAGE_CONTENT_TYPEUserAdded]) {
        self.messageToSend.contentType = MESSAGE_CONTENT_TYPEUserAdded;
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPEUserAdded,
                                 @"user": [NSString validStringForObject:self.addedUser.fullId],
                                 @"userName": [NSString validStringForObject:self.addedUser.name]
                                 };
        
        messageAttachments =  [object jsonString];
    }
    
    NSDictionary *params = @{
                             @"conversation" : [NSString stringWithFormat:@"%@",self.conversation.conversationId],
                             @"user" : userId,
                             @"text" : [NSString stringWithFormat:@"%@",message.message],
                             @"notification" : [NSString stringWithFormat:@"%@: %@",senderName,message.message],
                             @"notificationType": @"text",
                             @"callbackid" : callbackId,
                             @"objects" : [NSString stringWithFormat:@"%@",messageAttachments],
                             @"dev" : @"",
                             @"source" : @{
                                     @"rapporrverison" : @"300",
                                     @"platform" : @"ios",
                                     },
                             @"source" : @{
                                     @"rapporrverison" : @"300",
                                     @"platform" : @"ios",
                                     }
                             };
    
    
    [NetworkManager sendMessage:params success:^(id data, NSString *timestamp) {
        
        NSDictionary *dict = (NSDictionary *)data;
        
        NSString *PreviousMessageId = dict[@"PreviousMessageId"];
        NSString *messageId = dict[@"MessageId"];

        
        ALog(@"%lu",(unsigned long)self.conversation.messages.count);
        
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
            message.msgId = messageId;
            if ([PreviousMessageId isEqualToString:@""] || PreviousMessageId == nil) {
                PreviousMessageId = @"0";
            }
        
            self.conversation.lastMsgId = PreviousMessageId;
            message.previousMessageId = PreviousMessageId;
            
            if (self.conversationDictData != nil) {
                self.conversationDictData = nil;
            }
            
            if([[CoreDataController sharedManager] searchTempSavedMessage:message]){
                [[CoreDataController sharedManager] updateMessageStatus:message withStatus:YES];
                message.user = [[CoreDataController sharedManager] getUserWithID:message.userId];
            }
            
            
            message.isSentMessage = YES;
            
            NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"NewMessage" object:self];
            
            [[CoreDataController sharedManager] removeAllUnSentMessages:message];
            
            self.messageToSend = nil;
            self.selectedAnnouncementImage = nil;
            self.selectedImage = nil;
            self.linkUrlTxt.text = @"";
            self.linkTitleTxt.text = @"";
            self.announcementTitleTxt.text = @"";
            self.announcementDetailsTxt.text = @"";
            self.selectedImgView.image = nil;
            self.conversationDictData = nil;
            
            self.messageType = @"";
            if (self.conversationDictData != nil) {
                self.addedUser = nil;

            }

            
            [self animateRows];
            
//        }else{
//            [strongSelf animateRows];
//            message.isField = YES;
//            [[CoreDataController sharedManager] updateAttachmentForConversation:msg];
//            //            [self performSeenAction];
//        }

        
        
        
//        completion(YES,dict[@"MessageId"],dict[@"PreviousMessageId"]);
    } failure:^(NSError *error) {
        //        self.customizeTblView.userInteractionEnabled = YES;
        //        self.view.userInteractionEnabled = YES;
//        completion(NO,@"",@"");
        
        
            [self animateRows];
            message.isField = YES;
            [[CoreDataController sharedManager] updateAttachmentForConversation:message];

        
    }];

    
    
    
    
    /*
    
    [self sendMessageAPI:msg withCompletion:^(BOOL success , NSString *messageId, NSString *PreviousMessageId) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
//        ALog(@"%lu",(unsigned long)self.conversation.messages.count);
//        RPConverstionMessage *msg = (RPConverstionMessage*)[nonretainedMessage nonretainedObjectValue];

        
        NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(msg)));

        
        if (success) {
            
            msg.msgId = messageId;
            if ([PreviousMessageId isEqualToString:@""] || PreviousMessageId == nil) {
                PreviousMessageId = @"0";
            }
            strongSelf.conversation.lastMsgId = PreviousMessageId;
            msg.previousMessageId = PreviousMessageId;
            
            
            if (strongSelf.conversationDictData != nil) {
                strongSelf.conversationDictData = nil;
            }
            
            if([[CoreDataController sharedManager] searchTempSavedMessage:msg]){
                [[CoreDataController sharedManager] updateMessageStatus:msg withStatus:YES];
                msg.user = [[CoreDataController sharedManager] getUserWithID:msg.userId];
            }
            
            
            msg.isSentMessage = YES;
            
            NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"NewMessage" object:self];
            
            [[CoreDataController sharedManager] removeAllUnSentMessages:msg];
            
            strongSelf.messageToSend = nil;
            strongSelf.selectedAnnouncementImage = nil;
            selectedImage = nil;
            strongSelf.linkUrlTxt.text = @"";
            strongSelf.linkTitleTxt.text = @"";
            strongSelf.announcementTitleTxt.text = @"";
            strongSelf.announcementDetailsTxt.text = @"";
            strongSelf.selectedImgView.image = nil;
            strongSelf.conversationDictData = nil;
            
            strongSelf.messageType = @"";
            if (strongSelf.conversationDictData != nil) {
                strongSelf.addedUser = nil;
                //                [self fetchConversationMessagesWithoutAnimation];
            }
            //            [self performSeenAction];
            
            
            [strongSelf animateRows];
            
        }else{
            [strongSelf animateRows];
            msg.isField = YES;
            [[CoreDataController sharedManager] updateAttachmentForConversation:msg];
            //            [self performSeenAction];
        }
    }];
     */
}

-(void) animateRows {
    
    if ([self.conversation.messages count]>1) {
        
        NSInteger lastSectionIndex = MAX(0, [self.customizeTblView numberOfSections] - 1);
        NSInteger lastRowIndex = MAX(0, [self.customizeTblView numberOfRowsInSection:lastSectionIndex] - 1);
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
        [self.customizeTblView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


- (void)sendMessageAPI:(RPConverstionMessage *)message
        withCompletion:(void (^)(BOOL  success,
                                 NSString *messageID,
                                 NSString *PreviousMessageId))completion; {
    
    NSString *userId     = [RapporrManager sharedManager].vcModel.userId;
    NSString *senderName = [RapporrManager sharedManager].vcModel.userName;
    NSString *hostId     = [RapporrManager sharedManager].vcModel.hostID;
    NSString *callbackId = [NSString stringWithFormat:@"%@-%@%@",hostId,userId,[NSDate getTimestampForCallBackId]];
    NSString *messageAttachments = @"";
    
    ALog(@"%lu",(unsigned long)self.conversation.messages.count);

    
    if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto]){
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPESharePhoto,
                                 @"photoID" :  message.photoId
                                 };
        
        messageAttachments =  [object jsonString];
        message.contentType = MESSAGE_CONTENT_TYPESharePhoto;
        message.imageUrl = message.tempImageUrl;
        message.thumbImage = message.tempThumbImageUrl;
        
    }else  if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]){
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPEAnnouncement,
                                 @"photoID" :  [NSString validStringForObject:message.announcement.photoId],
                                 @"announcement": [NSString validStringForObject:message.announcement.title],
                                 @"title": [NSString validStringForObject:message.announcement.title],
                                 @"source" : @{
                                         @"rapporrverison" : @"300",
                                         @"platform" : @"ios",
                                         },
                                 
                                 @"attachments" : @{
                                         @"contentType" : [NSString validStringForObject:message.announcement.attachment.contentType],
                                         @"category" : [NSString validStringForObject:message.announcement.attachment.category],
                                         @"title" : [NSString validStringForObject:message.announcement.attachment.title],
                                         @"url" : [NSString validStringForObject:message.announcement.attachment.url],
                                         }
                                 };
        
        messageAttachments =  [object jsonString];
    } else  if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPELOCATION]){
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPELOCATION,
                                 @"photoID" :  [NSString validStringForObject:message.photoId],
                                 @"type": @"map",
                                 @"shared": @"false",
                                 @"title": [NSString validStringForObject:message.locationModel.titleStr],
                                 @"source" : @{
                                         @"rapporrverison" : @"300",
                                         @"platform" : @"ios",
                                         },
                                 @"gps" : @{
                                         @"timestamp" : message.timeStamp,
                                         @"longitude" : message.locationModel.longitude,
                                         @"latitude" : message.locationModel.latitude,
                                         @"speed" : @"0",
                                         @"accuracy" : @"13.781000137329102",
                                         @"heading" : @"0",
                                         @"altitude" : @"0",
                                         }
                                 };
        
        messageAttachments =  [object jsonString];
    }
    else  if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEShareContact]){
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPEShareContact,
                                 @"category" :  @"phoneLink",
                                 @"title": [NSString validStringForObject:message.contactModel.title],
                                 @"phone": [NSString validStringForObject:message.contactModel.phone],
                                 @"source" : @{
                                         @"rapporrverison" : @"300",
                                         @"platform" : @"ios",
                                         }
                                 };
        
        messageAttachments =  [object jsonString];
    }
    else if ([self.messageType isEqualToString:MESSAGE_CONTENT_TYPEUserAdded]) {
        self.messageToSend.contentType = MESSAGE_CONTENT_TYPEUserAdded;
        
        NSDictionary *object = @{
                                 @"contentType" : MESSAGE_CONTENT_TYPEUserAdded,
                                 @"user": [NSString validStringForObject:self.addedUser.fullId],
                                 @"userName": [NSString validStringForObject:self.addedUser.name]
                                 };
        
        messageAttachments =  [object jsonString];
    }
    
    NSDictionary *params = @{
                             @"conversation" : [NSString stringWithFormat:@"%@",self.conversation.conversationId],
                             @"user" : userId,
                             @"text" : [NSString stringWithFormat:@"%@",message.message],
                             @"notification" : [NSString stringWithFormat:@"%@: %@",senderName,message.message],
                             @"notificationType": @"text",
                             @"callbackid" : callbackId,
                             @"objects" : [NSString stringWithFormat:@"%@",messageAttachments],
                             @"dev" : @"",
                             @"source" : @{
                                     @"rapporrverison" : @"300",
                                     @"platform" : @"ios",
                                     },
                             @"source" : @{
                                     @"rapporrverison" : @"300",
                                     @"platform" : @"ios",
                                     }
                             };
    
    
    [NetworkManager sendMessage:params success:^(id data, NSString *timestamp) {
        NSDictionary *dict = (NSDictionary *)data;
        //        self.customizeTblView.userInteractionEnabled = YES;
        //        self.view.userInteractionEnabled = YES;
        
        ALog(@"%lu",(unsigned long)self.conversation.messages.count);
        
        
        completion(YES,dict[@"MessageId"],dict[@"PreviousMessageId"]);
    } failure:^(NSError *error) {
        //        self.customizeTblView.userInteractionEnabled = YES;
        //        self.view.userInteractionEnabled = YES;
        completion(NO,@"",@"");
        
    }];
}

- (IBAction)btnAddFile:(id)sender {
    
    if (self.isKeyboardAppear) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.addAcctionsBgView setHidden:NO];
            self.addMenuButton.hidden = YES;
            [self.view endEditing:YES];
        });
    }else{
        
        [self.actionBgView setHidden:NO];
        [self.view bringSubviewToFront:self.actionBgView];
        
        //        [[UIApplication sharedApplication].windows.lastObject addSubview:self.actionBgView];
        
        self.addMenuButton.hidden = YES;
        
        [Utils moveViewPosition:self.view.bounds.size.height - self.actionSheetButtonView.bounds.size.height onView:self.actionSheetButtonView completion:^(BOOL finished) {
        }];
    }
}



#pragma mark - PictureActionSheetButtons

- (IBAction)actionSheetButtons:(UIButton *)sender {
    
    [Utils moveViewPosition:1000 onView:self.actionSheetButtonView completion:^(BOOL finished) {
        [self.actionBgView setHidden:YES];
        if (!isAnnouncement) {
            self.addMenuButton.hidden = NO;
        }
    }];
    
    if (sender.tag == 350) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = (id)self;
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self presentViewController:imagePickerController animated:YES completion:nil];
                }];
            }
            else{
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Camera Unavailable"
                                                           message:@"Unable to find a camera on your device."
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
        }
        
    }else if (sender.tag == 351){
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = (id)self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}


- (IBAction)btnHideActionSheet:(id)sender {
    
    [Utils moveViewPosition:1000 onView:self.actionSheetButtonView completion:^(BOOL finished) {
        [self.actionBgView setHidden:YES];
        if (!isAnnouncement) {
            self.addMenuButton.hidden = NO;
        }
        [self.addAcctionsBgView setHidden:YES];
    }];
    
    [Utils moveViewPosition:1000 onView:self.contactsActionSheetButtonView completion:^(BOOL finished) {
        [self.actionBgView setHidden:YES];
        if (!isAnnouncement) {
            self.addMenuButton.hidden = NO;
        }
        [self.contactsActionBgView setHidden:YES];
    }];
    
}

#pragma mark - ContactsActionSheetButtons

- (IBAction)contactsActionSheetButtons:(UIButton *)sender;
{
    [Utils moveViewPosition:1000 onView:self.contactsActionSheetButtonView completion:^(BOOL finished) {
        [self.contactsActionBgView setHidden:YES];
        if (!isAnnouncement) {
            self.addMenuButton.hidden = NO;
        }
    }];
    
    if (sender.tag == 350) {
        
        [self initializeContactPicker];
        
        
        //        self.peoplePicker.fieldMask = ZLContactFieldAll;
        //        self.peoplePicker.numberOfSelectedPeople = ZLNumSelectionNone;
        //        self.peoplePicker = [ZLPeoplePickerViewController presentPeoplePickerViewControllerForParentViewController:self];
        //        self.peoplePicker.numberOfSelectedPeople = 1;
        //        self.peoplePicker.delegate = self;
        
    }else if (sender.tag == 351){
        
        [self.addAcctionsBgView setHidden:YES];
        self.addMenuButton.hidden = NO;
        [self.view bringSubviewToFront:self.contactPopUpContainer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        tapGestureRecognizer.delegate = (id)self;
        
        [self.contactPopUpShadowView addGestureRecognizer:tapGestureRecognizer];
        
        self.contactPopUpContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
       
        
        
        [self.contactPopUpContainer setFrame:self.view.bounds];
        
        self.contactPopUpShadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        [self.view addSubview:self.contactPopUpContainer];
        [self.txtFieldContactName becomeFirstResponder];
    
    }
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self.contactPopUpContainer removeFromSuperview];
}



#pragma mark -

- (IBAction)btnAddLocation:(id)sender {
    [self setUpLocationManager];
    
    [self.view endEditing:YES];
}

- (IBAction)btnCreateAnnouncement:(id)sender {
    
    [self.view endEditing:YES];
    [self.addAcctionsBgView setHidden:YES];
    self.addMenuButton.hidden = YES;
    
    isAnnouncement = YES;
    ConversationUser *cUserObj;
    for (int i=0; i<_conversation.members.count; i++) {
        
        cUserObj = [_conversation.members objectAtIndex:i];
        
        if([[RapporrManager sharedManager].vcModel.userId isEqualToString:cUserObj.fullId]) {
            
            if (cUserObj.avatarImage) {
                [_announcementImgView setImage:cUserObj.avatarImage];
            }
            else if (cUserObj.avatarUrl.length > 1) {
                NSURL *imageUrl = [NSURL URLWithString:cUserObj.avatarUrl];
                
                [_announcementImgView setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
            }
            else{
                [_announcementImgView setImageWithString:cUserObj.name color:[UIColor colorFromHexCode:@"#FD9527"] circular:NO];
            }
            break;
        }
        else {
            [_announcementImgView setImageWithString:[RapporrManager sharedManager].vcModel.userName color:[UIColor colorFromHexCode:@"#FD9527"] circular:NO];
        }
    }
    
    self.announcementTitleTxt.text = @"";
    self.announcementDetailsTxt.text = @"";
    
    _addLink.image = [UIImage imageNamed:@"addLink"];
    _addLinkBtn.userInteractionEnabled = true;
    _addImg.image = [UIImage imageNamed:@"addImage-1"];
    _addImageBtn.userInteractionEnabled = true;
    isAnnouncement = YES;
    _addLinkSmallView.hidden = false;
    _largeLinkView.hidden = true;
    
    
    self.addImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.addImageView.layer.borderWidth = 1.0;
    
    self.addLinkSmallView.layer.borderColor = [UIColor blackColor].CGColor;
    self.addLinkSmallView.layer.borderWidth = 1.0;
    
    self.largeLinkView.layer.borderColor = [UIColor blackColor].CGColor;
    self.largeLinkView.layer.borderWidth = 1.0;
    
    UIColor *color = [UIColor darkGrayColor];
    _announcementTitleTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Add Title" attributes:@{NSForegroundColorAttributeName: color}];
    
    _createAnnouncementView.hidden = false;
}

- (IBAction)btnAddContact:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [self.addAcctionsBgView setHidden:YES];
    [self.contactsActionBgView setHidden:NO];
    self.addMenuButton.hidden = YES;
    
    [Utils moveViewPosition:self.view.bounds.size.height - self.contactsActionSheetButtonView.bounds.size.height onView:self.contactsActionSheetButtonView completion:^(BOOL finished) {
    }];
}

- (IBAction)btnAddPhoto:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [self.addAcctionsBgView setHidden:YES];
    [self.contactsActionBgView setHidden:YES];
    self.addMenuButton.hidden = YES;
    [self.view bringSubviewToFront:self.actionBgView];
    [self.actionBgView setHidden:NO];
    
    [Utils moveViewPosition:self.view.bounds.size.height - self.actionSheetButtonView.bounds.size.height onView:self.actionSheetButtonView completion:^(BOOL finished) {
    }];
    
    
    [Utils moveViewPosition:self.view.bounds.size.height - self.actionSheetButtonView.bounds.size.height onView:self.actionSheetButtonView completion:^(BOOL finished) {
    }];
    
    
    if (sender.tag == 350) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = (id)self;
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self presentViewController:imagePickerController animated:YES completion:nil];
                }];
            }
            else{
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Camera Unavailable"
                                                           message:@"Unable to find a camera on your device."
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
        }
        
    }else if (sender.tag == 351){
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = (id)self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (IBAction)btnSelectContact:(id)sender {
    
    [self btnHideActionSheet:nil];
    
    AddNewMemberVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewMemberVC"];
    
    if (self.conversationDictData != nil) {
        NSArray *array = self.conversationDictData[@"userList"];
        for (NSString *userID in array) {
            ConversationUser *user = [[CoreDataController sharedManager] getUserWithID:userID];
            [self.conversation.members addObject:user];
        }
    }
    
    vc.conversation = self.conversation;
    vc.delegate = (id)self;
    
    [self presentViewController:vc animated:NO completion:^{
        
    }];
}

-(void)didNewMembersSelected:(NSMutableArray *)users;
{
    
    if (self.conversationDictData != nil) {
        
        [NetworkManager makePOSTCall:URI_POST_START_NEW_CONVERSATION parameters:self.conversationDictData success:^(id data, NSString *timestamp) {
            NSDictionary *dict = (NSDictionary *)data;
            
            self.conversation = [[MessageModel alloc]init];
            self.conversation.conversationId = dict[@"conversationId"];
            
            [[CoreDataController sharedManager] saveMessageModel:self.conversation];
            
            
            for (ConversationUser *user in users) {
                self.addedUser = user;
                
                self.messageType = MESSAGE_CONTENT_TYPEUserAdded;
                [self.conversation.members addObject:user];
                [self sendMessageWithConversationID:self.conversation.conversationId];
            }
            
        } failure:^(NSError *error) {
            
        }];
        
    }else{
        for (ConversationUser *user in users) {
            self.addedUser = user;
            self.messageType = MESSAGE_CONTENT_TYPEUserAdded;
            
            [self sendMessageWithConversationID:self.conversation.conversationId];
        }
    }
}

- (IBAction)btnCloseActionView:(id)sender {
    
    [self.addAcctionsBgView setHidden:YES];
    self.addMenuButton.hidden = NO;
}

#pragma mark - Select Contact

-(void)initializeContactPicker{
    
    _addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    APAddressBookAccessRoutine *addressBookAccessRoutine = [[APAddressBookAccessRoutine alloc] init];
    [addressBookAccessRoutine requestAccessWithCompletion:^(BOOL granted, NSError *error) {
        if (granted) {
            [self showContacts];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showContactsAlert];
            });
        }
    }];
}

-(void)showContactsAlert {
    
    [self setUpAlertView];
    _customAlert.alertTag = 10099;
    _customAlert.alertType = kAlertTypePopup;
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.customAlert showPopUpInView:top.view withMessage:NSLocalizedString(@"Alert!", nil) andDescription:NSLocalizedString(@"This app requires contacts access to function properly.", nil)];
}

-(void)showContacts
{
    [ZLPeoplePickerViewController initializeAddressBook];
    [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setBarTintColor:[UIColor blackColor]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTintColor:[UIColor blackColor]];
    
    self.peoplePicker.fieldMask = ZLContactFieldAll;
    self.peoplePicker.numberOfSelectedPeople = ZLNumSelectionNone;
    self.peoplePicker = [ZLPeoplePickerViewController presentPeoplePickerViewControllerForParentViewController:self];
    self.peoplePicker.numberOfSelectedPeople = 1;
    self.peoplePicker.delegate = self;
    
}

- (void)peoplePickerViewController:(ZLPeoplePickerViewController *)peoplePicker
                   didSelectPerson:(NSNumber *)recordId {
    
    [self getPersonContactInfo:recordId];
    
}


- (void)peoplePickerViewController:(ZLPeoplePickerViewController *)peoplePicker didReturnWithSelectedPeople:(NSSet *)people {
    if (!people || people.count == 0) {
        return;
    }else{
        
    }
}

- (void)newPersonViewControllerDidCompleteWithNewPerson:(nullable ABRecordRef)person {
    
}

#pragma mark Display and edit a person
- (void)showPersonViewController:(ABRecordID)recordId onNavigationController: (UINavigationController *)navigationController {
    
    ABRecordRef person = (ABRecordRef)(ABAddressBookGetPersonWithRecordID(self.addressBookRef, recordId));
    
    if (person != NULL) {
        
        ABPersonViewController *picker = [[ABPersonViewController alloc] init];
        picker.personViewDelegate = self;
        picker.displayedPerson = person;
        picker.allowsEditing = NO;
        picker.allowsActions = NO;
        picker.shouldShowLinkedPeople = YES;
        [navigationController pushViewController:picker animated:YES];
    } else {
        // Show an alert if "Appleseed" is not in Contacts
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Error"
                                   message:@"Could not find the person in " @"the Contacts application"
                                  delegate:nil
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark ABPersonViewControllerDelegate methods
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier: (ABMultiValueIdentifier)identifierForValue {
    return NO;
}

- (id)getPersonContactInfo:(NSNumber *)recordId {
    
    APAddressBook *abook = [[APAddressBook alloc]init];
    
    [abook loadContactByRecordID:recordId completion:^(APContact * _Nullable contact) {
        
        APName *name = contact.name;
        
        NSArray <APPhone*> *phones = contact.phones;
        APPhone* phone = nil;
        if([phones count]){
            phone = [phones objectAtIndex:0];
        }
        __weak __typeof(self)weakSelf = self;
        
        weakSelf.selectedContact = contact;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self setUpAlertView];
            _customAlert.alertTag = 10023;
            _customAlert.alertType = kAlertTypeDetail;
            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
            
            [weakSelf.customAlert showCustomAlertInView2:top.view withMessage:NSLocalizedString(@"Choose Contact", nil) andDescription:NSLocalizedString(@"Please check the details before proceeding", nil) detailHead:NSLocalizedString(@"Details -", nil) andName:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Name : ", nil),name.firstName] andPhone:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Phone : ", nil),phone.number]];
            
        }];
    }];
    
    return nil;
}

#pragma Rapporr AlertView

- (void) setUpAlertView {
    
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
    
}

-(void)RapporrAlertOK:(id)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_customAlert removeCustomAlertFromViewInstantly];
    });
    if (_customAlert.alertTag == 1000 && _customAlert.alertType == kAlertTypeMessage) {
        if (_isDirectMessage) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self popToConversation];
        }
    }else if (_customAlert.alertTag == 1001 && _customAlert.alertType == kAlertTypeMessage) {
        _actionBgView.hidden = true;
        _locationScreen.hidden = true;
        self.addMenuButton.hidden = NO;
        
        NSString *latitudeStr = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
        NSString *longitudeStr = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
        
        [SVProgressHUD show];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:self.locationManager.location
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           if (placemarks.count > 0) {
                               CLPlacemark *place = [placemarks objectAtIndex:0];
                               [self snapshotImage:^(UIImage *image) {
                                   self.messageToSend = [[RPConverstionMessage alloc] init];
                                   self.messageToSend.placeHolderImage = image;
                                   self.photoID = [self generatePhotoId:@""];
                                   self.messageType = MESSAGE_CONTENT_TYPELOCATION;
                                   self.messageToSend.locationModel.titleStr = [NSString stringWithFormat:@"%@ %@ %@",place.name,place.locality,place.country];
                                   self.messageToSend.photoId = [self generatePhotoId:@""];
                                   self.messageToSend.locationModel.latitude = latitudeStr;
                                   self.messageToSend.locationModel.longitude = longitudeStr;
                                   self.messageToSend.message = @"shared a location with you.";
                                   self.messageToSend.contentType = MESSAGE_CONTENT_TYPELOCATION;
                                   
                                   
                                   NSData *imageToUploadOriginal = UIImageJPEGRepresentation([image imageWithFillSize:CGSizeMake(400, 400)], 1.0);
                                   NSData *imageToUploadThumbnail = UIImageJPEGRepresentation([image imageWithFillSize:CGSizeMake(60, 60)], 1.0);
                                   
                                   self.uploadedThumbnailImageUri = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@",[NSString stringWithFormat:@"%@/thumbnail",self.photoID]];
                                   self.uploadedImageUri          = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@",[NSString stringWithFormat:@"%@/original",self.photoID]];
                                   
                                   [NetworkManager postImageOnAmazonServer:imageToUploadThumbnail parameters:@"thumbnail" andphotoID:[NSString stringWithFormat:@"%@/thumbnail",self.photoID] success:^(id data, NSString *timestamp) {
                                   } failure:^(NSError *error) {
                                       [SVProgressHUD dismiss];
                                       [self sendMessageWithConversationID:self.conversation.conversationId];

                                   }];
                                   
                                   [NetworkManager postImageOnAmazonServer:imageToUploadOriginal parameters:@"original" andphotoID:[NSString stringWithFormat:@"%@/original",self.photoID] success:^(id data, NSString *timestamp) {
                                       
                                   } failure:^(NSError *error) {}];
                               }];
                           }else{
                               [SVProgressHUD dismiss];
                           }
                       }];
        
    }else if (_customAlert.alertTag == 10099 && _customAlert.alertType == kAlertTypePopup) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else if (_customAlert.alertTag == 100 && _customAlert.alertType == kAlertTypeMessage) {
        
        _actionBgView.hidden = YES;
        self.addMenuButton.hidden = NO;
        [self.addAcctionsBgView setHidden:YES];
        _actionBgView.hidden = true;
        
        [_customAlert removeCustomAlertFromViewInstantly];
        
        if ([UIApplication instancesRespondToSelector:NSSelectorFromString(@"openURL:options:completionHandler:")]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=Privacy&path=LOCATION"] options:@{} completionHandler:nil];
        }
        else {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
            }
        }
        
    }else if (_customAlert.alertTag == 200 && _customAlert.alertType == kAlertTypeMessage) {
        
        _actionBgView.hidden = YES;
        self.addMenuButton.hidden = NO;
        [self.addAcctionsBgView setHidden:YES];
        _actionBgView.hidden = true;
        
        [_customAlert removeCustomAlertFromViewInstantly];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    
    else if (_customAlert.alertTag == 10023 && _customAlert.alertType == kAlertTypeDetail) {
        
        APName *name = self.selectedContact.name;
        NSArray <APPhone*> *phones = self.selectedContact.phones;
        APPhone* phone = nil;
        if([phones count]){
            phone = [phones objectAtIndex:0];
        }
        
        [self.view bringSubviewToFront:self.contactPopUpContainer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        tapGestureRecognizer.delegate = (id)self;
        
        [self.contactPopUpShadowView addGestureRecognizer:tapGestureRecognizer];
        [self.view addSubview:self.contactPopUpContainer];
        self.contactPopUpContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contactPopUpShadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contactPopUpContainer setFrame:self.view.bounds];

        [self.txtFieldContactName setText:[NSString stringWithFormat:@"%@",name.compositeName]];
        [self.txtFieldPhone setText:[NSString stringWithFormat:@"%@",phone.number]];
        [self.txtFieldContactName becomeFirstResponder];
//        [Utils moveViewPosition:20 onView:self.contactPopUp completion:^(BOOL finished) {
//            
//        }];
    }
}

-(void)RapporrAlertCancel;{
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel:(id)sender;{
    [_customAlert removeCustomAlertFromViewInstantly];
}


#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.photoID = [self generatePhotoId:@""];
    
    if(isAnnouncement) {
        _selectedImgView.image = image;
        self.selectedAnnouncementImage = image;
    }
    else {
        
        self.selectedImage = image;
        self.messageToSend = [[RPConverstionMessage alloc] init];
        self.messageToSend.message = @"shared a photo with you.";
        self.messageToSend.placeHolderImage = image;
        self.messageToSend.contentType = MESSAGE_CONTENT_TYPESharePhoto;
        
        [self uploadImageToAmazonServer:image];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self btnSendMessage:nil];
        });
    }
}

#pragma mark - Upload Image to Amazon Server

- (void) uploadImageToAmazonServer : (UIImage *)imageToUpload{
    
    NSData *imageToUploadOriginal = UIImageJPEGRepresentation([imageToUpload imageWithFillSize:CGSizeMake(400, 400)], 1.0);
    NSData *imageToUploadThumbnail = UIImageJPEGRepresentation([imageToUpload imageWithFillSize:CGSizeMake(60, 60)], 1.0);
    
    self.uploadedThumbnailImageUri = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@",[NSString stringWithFormat:@"%@/thumbnail",self.photoID]];
    self.uploadedImageUri          = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@",[NSString stringWithFormat:@"%@/original",self.photoID]];
    
    [NetworkManager postImageOnAmazonServer:imageToUploadThumbnail parameters:@"thumbnail" andphotoID:[NSString stringWithFormat:@"%@/thumbnail",self.photoID] success:^(id data, NSString *timestamp) {
    } failure:^(NSError *error) {}];
    
    [NetworkManager postImageOnAmazonServer:imageToUploadOriginal parameters:@"original" andphotoID:[NSString stringWithFormat:@"%@/original",self.photoID] success:^(id data, NSString *timestamp) {
        
    } failure:^(NSError *error) {}];
}

-(NSString*) generatePhotoId : (NSString*) type {
    NSString * timeInMS = [NSString stringWithFormat:@"%lld", [@(floor(([[NSDate date] timeIntervalSince1970] * 1000)/60000)-24000000) longLongValue]];
    
    NSString *photoIDTemp = [NSString stringWithFormat:@"%@%@%@",_conversation.conversationId,timeInMS,[RapporrManager sharedManager].vcModel.userId];
    
    return photoIDTemp;
}

#pragma mark - UIKeyboard

-(void)keyboardWillShow:(NSNotification *)note {
    
    CGSize keyboardSize = [[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    float height = MIN(keyboardSize.height,keyboardSize.width);
    heightKeyboardHeight = height;
    
    CGRect containerFrame = self.editMessageContainer.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.editMessageContainer.frame = containerFrame;
    
    [self.btnAddFile setImage:SET_IMAGE(@"new_option_chat") forState:UIControlStateNormal];
    CGRect tableViewRect = self.customizeTblView.frame;
    tableViewRect.size.height = containerFrame.origin.y - 71;
    self.customizeTblView.frame = tableViewRect;
    
    [Utils moveViewPosition:self.view.frame.size.height - height - self.contactPopUp.frame.size.height - 16  onView:self.contactPopUp completion:^(BOOL finished) {
        
    }];
    
    [UIView commitAnimations];
    
    _isKeyboardAppear = YES;
    _editingBlockingView.hidden = false;
    [self addTouchGestureForKeyboardOnEditing];
    
}

-(void)keyboardWillHide:(NSNotification *)note {
    
    CGSize keyboardSize = [[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect containerFrame = _editMessageContainer.frame;
    containerFrame.origin.y = self.view.frame.size.height - containerFrame.size.height;
    
    _editMessageContainer.frame = containerFrame;
    
    
    float height = MIN(keyboardSize.height,keyboardSize.width);
    heightKeyboardHeight = height;
    [self.btnAddFile setImage:SET_IMAGE(@"addimageWhite") forState:UIControlStateNormal];
    CGRect tableViewRect = self.customizeTblView.frame;
    tableViewRect.size.height = containerFrame.origin.y - 71;
    self.customizeTblView.frame = tableViewRect;
    [UIView commitAnimations];
    _isKeyboardAppear = NO;
    
    [self.editingBlockingView removeGestureRecognizer:tap];
    _editingBlockingView.hidden = true;
    
    
}

- (void)addTouchGestureForKeyboardOnEditing {
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [_editingBlockingView addGestureRecognizer:tap];
}


#pragma mark - Growable TextField

- (void)growableTextView:(TextField *)textView willChangeHeight:(float)height
{
    float diff = (textView.frame.size.height - height);
    CGRect r = _editMessageContainer.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    _editMessageContainer.frame = r;
    
    CGRect buttonFrame = self.addMenuButton.frame;
    buttonFrame.origin.y += diff + 10;
    self.addMenuButton.frame = buttonFrame;
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect tableViewRect = self.customizeTblView.frame;
    tableViewRect.size.height = r.origin.y - 71;
    self.customizeTblView.frame = tableViewRect;
    
    [UIView commitAnimations];
    
}


- (BOOL)growableTextViewShouldBeginEditing:(TextField *)textView;{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    return YES;
}

- (BOOL)growableTextViewShouldEndEditing:(TextField *)textView;{
    
    return YES;
}

- (void)growableTextViewDidBeginEditing:(TextField *)textView;{
    
}

- (void)growableTextViewDidEndEditing:(TextField *)textView;{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    CGRect buttonFrame = self.addMenuButton.frame;
    buttonFrame.origin.y = self.editMessageContainer.frame.origin.y - 80;
    self.addMenuButton.frame = buttonFrame;
}

- (BOOL)growableTextView:(TextField *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;{
    return YES;
}

- (void)growableTextViewDidChange:(TextField *)textView;{
    
    if ([textView.text length] > 0) {
        self.btnSendMessage.tintColor = [UIColor colorFromHexCode:@"#FF5721"];
    }else{
        self.btnSendMessage.tintColor = [UIColor whiteColor];
    }
}

- (void)growableTextView:(TextField *)textView didChangeHeight:(float)height;{
    
}

- (void)growableTextViewDidChangeSelection:(TextField *)textView;{
    
}

- (BOOL)growableTextViewShouldReturn:(TextField *)textView;{
    
    [textView resignFirstResponder];
    return YES;
}


-(void)setupRefreshControl{
    
    _refresh = [[UIRefreshControl alloc] init];
    _refresh.backgroundColor = [UIColor clearColor];
    [_refresh setTintColor:[UIColor clearColor]];
    [_refresh addTarget:self action:@selector(fetchConversationMessages) forControlEvents:UIControlEventValueChanged];
    [self.customizeTblView addSubview:self.refresh];
}

- (void)stopRefresh
{
    [self.refresh endRefreshing];
}

- (void) fetchConversationMessages {
    
    NSString *timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithConversationMessagesTimestamp];
    if (timestamp == nil) {
        timestamp = @"all";
    }
    if(self.conversation.messages.count == 0) {
        [SVProgressHUD show];
        
        dotsActivityView.hidden = false;
        dotsActivityView.dotParms = [self loadDotActivityIndicatorParms];
        [dotsActivityView startAnimating];
    }
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
    
    NSString *orgId  = [RapporrManager sharedManager].vcModel.orgId;
    
    NSString *uri = [NSString stringWithFormat:URI_GET_CONVERSATION_MESSAGES,orgId,self.conversation.conversationId];
    [NetworkManager fetchAllMessages:uri parameters:nil success:^(id data ,NSString *timestamp) {
        
        if ([data isKindOfClass:[NSArray class]]) {
            NSMutableArray *messages = [RPConverstionMessage parseConversationMessages:(NSArray *)data];
            for (RPConverstionMessage *convMsg in messages) {
                [self.conversation.messages addObject:convMsg];
            }
            
            if ([self.conversation.messages count]) {
                RPConverstionMessage *message = [self.conversation.messages lastObject];
                message.isRead = YES;
                [[CoreDataController sharedManager] updateConversationMessage:message];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kfetchWithConversationMessagesTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self getMessagesFromDb];
        [self getUniqueDates];
        [self sortMessagesDictionary];
        
        [SVProgressHUD dismiss];
        [dotsActivityView stopAnimating];
        dotsActivityView.hidden = true;
        
        [self.customizeTblView reloadData];
        
        if (self.customizeTblView.contentSize.height > self.customizeTblView.frame.size.height)
        {
            CGPoint offset = CGPointMake(0, self.customizeTblView.contentSize.height - self.customizeTblView.frame.size.height);
            [self.customizeTblView setContentOffset:offset animated:NO];
        }
        
    }failure:^(NSError *error) {
        NSLog(@"Error");
        [SVProgressHUD dismiss];
    }];
}

//- (void) fetchConversationMessagesWithoutAnimation {
//    
//    NSString *timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithConversationMessagesTimestamp];
//    if (timestamp == nil) {
//        timestamp = @"all";
//    }
//    
//    NSString *orgId  = [RapporrManager sharedManager].vcModel.orgId;
//    NSString *uri = [NSString stringWithFormat:URI_GET_CONVERSATION_MESSAGES,orgId,self.conversation.conversationId];
//    [NetworkManager fetchAllMessages:uri parameters:nil success:^(id data ,NSString *timestamp) {
//        
//        if ([data isKindOfClass:[NSArray class]]) {
//            NSMutableArray *messages = [RPConverstionMessage parseConversationMessages:(NSArray *)data];
//            for (RPConverstionMessage *convMsg in messages) {
//                [self.conversation.messages addObject:convMsg];
//            }
//            [self getMessagesFromDbForMsgSent];
//        }
//        
//        [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kfetchWithConversationMessagesTimestamp];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//    }failure:^(NSError *error) {
//        NSLog(@"Error");
//        [SVProgressHUD dismiss];
//    }];
//}

//-(void)getMessagesFromDbForMsgSent
//{
//    
//    if (self.conversation && self.conversation.conversationId) {
//        
//        self.conversation.messages = [[CoreDataController sharedManager] fetchConversationMessagesFromDBForConversation:self.conversation WithCompletion:^(RPConverstionMessage * _Nullable unSentMessage) {
//            if (unSentMessage) {
//                
//                self.unSentMessage = unSentMessage;
//                [self.textView setText:self.unSentMessage.message];
//                //[self.textView becomeFirstResponder];
//            }
//        }];
//        
//        [self getUniqueDates];
//        [self sortMessagesDictionary];
//        
//        [SVProgressHUD dismiss];
//        [self.customizeTblView reloadData];
//        
//        if (self.customizeTblView.contentSize.height > self.customizeTblView.frame.size.height)
//        {
//            CGPoint offset = CGPointMake(0, self.customizeTblView.contentSize.height - self.customizeTblView.frame.size.height);
//            [self.customizeTblView setContentOffset:offset animated:NO];
//        }
//        
//    }
//}

-(void)getMessagesFromDb
{
    if (self.conversation && self.conversation.conversationId) {
        self.conversation.messages = [[CoreDataController sharedManager] fetchConversationMessagesFromDBForConversation:self.conversation WithCompletion:^(RPConverstionMessage * _Nullable unSentMessage) {
            if (unSentMessage) {
                self.unSentMessage = unSentMessage;
                [self.textView setText:self.unSentMessage.message];
            }
        }];
    }
    
    [self findSeenUsers];
    
    [self getUniqueDates];
    [self sortMessagesDictionary];
    
    [SVProgressHUD dismiss];
    [self.customizeTblView reloadData];
    
    if (self.customizeTblView.contentSize.height > self.customizeTblView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.customizeTblView.contentSize.height - self.customizeTblView.frame.size.height);
        [self.customizeTblView setContentOffset:offset animated:NO];
    }
}


-(void)findSeenUsers
{
    
    for (RPConverstionMessage *message in self.conversation.messages) {
        
        [message.seenByUsers removeAllObjects];
        
        message.seenByUsers = [[CoreDataController sharedManager] getMessageSeenByUsersWithMessageId:message.msgId andConversationId:message.conversationId];
        
        BOOL isSelfSeen = NO;
        BOOL isSenderSeen = NO;
        
        for (ConversationUser *user in message.seenByUsers) {
            if ([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]) {
                isSelfSeen = YES;
            }
        }
        
        if (!isSelfSeen) {
            ConversationUser *user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
            user.seen = [self addSelfAsSeenUser:message.timeStamp withUserId:[RapporrManager sharedManager].vcModel.userId];
            [message.seenByUsers addObject:user];
        }

        for (ConversationUser *user in message.seenByUsers) {
            if ([user.fullId isEqualToString:message.user.fullId]) {
                isSenderSeen = YES;
            }
        }
        
        if (!isSenderSeen) {
            ConversationUser *user = [[CoreDataController sharedManager] getUserWithID:message.user.fullId];
            if (user) {
                user.seen = [self addSelfAsSeenUser:message.timeStamp withUserId:message.user.fullId];
                [message.seenByUsers addObject:user];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            message.seenByCount = [NSString stringWithFormat:@"%d",(int)[message.seenByUsers count]];
        });
    }
}




-(void)performSeenAction
{
    if(_conversation.conversationId) {
        
        NSString *orgId  = [RapporrManager sharedManager].vcModel.orgId;
        NSString *userId = [RapporrManager sharedManager].vcModel.userId;
        NSString *hostId = [RapporrManager sharedManager].vcModel.hostID;
        
        NSDictionary *params = @{
                                 @"conversation" : self.conversation.conversationId,
                                 @"orgid"  : orgId,
                                 @"userid" : userId,
                                 @"hostid" : hostId,
                                 @"type"   : @"MESSAGE",
                                 @"lastmessage" : [NSString stringWithFormat:@"%@",self.conversation.lastMsgId]
                                 };
        
        
        [NetworkManager makePOSTCall:URI_POST_SEEN_BY parameters:params success:^(id data, NSString *timestamp) {
            
            [self getSeenMessage];
            
        } failure:^(NSError *error) {
            
        }];
    }
}

-(void)getSeenMessage
{
    
    NSString *timeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@",self.conversation.conversationId]];
    if(timeStamp == nil){
        timeStamp = @"all";
    }
    
    NSString *uri = [NSString stringWithFormat:URI_GET_SEEN_BY,self.conversation.conversationId,@"all"];
    [NetworkManager makeGETCall:uri parameters:nil success:^(id data,NSString *time) {
        if([data isKindOfClass:[NSArray class]]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *array = [MessageSeenUser parseSeenMessages:(NSArray *)data forMessages:self.conversation.messages];
                for (MessageSeenUser *seenUser in array) {
                    if (![[CoreDataController sharedManager] searchForSeenBy:seenUser]) {
                        [[CoreDataController sharedManager] saveSeenUser:seenUser];
                    }
                }
            
                [[NSUserDefaults standardUserDefaults] setObject:time forKey:[NSString stringWithFormat:@"%@",self.conversation.conversationId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self findSeenUsers];
                });
            });
        }
    }failure:^(NSError *error) {
        NSLog(@"Error");
    }];
}


//- (void) viewDidLayoutSubviews {
//
//    [super viewDidLayoutSubviews];
//
//    if ([self.conversation.messages count]>2) {
//
//        NSInteger lastSectionIndex = MAX(0, [self.customizeTblView numberOfSections] - 1);
//        NSInteger lastRowIndex = MAX(0, [self.customizeTblView numberOfRowsInSection:lastSectionIndex] - 1);
//        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
//        [self.customizeTblView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
//}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGPoint targetPoint = *targetContentOffset;
    CGPoint currentPoint = scrollView.contentOffset;
    
    if (!scrollView.isZoomBouncing) {
        
        if (targetPoint.y > currentPoint.y) {
        }
        else {
        }
    }
}

#pragma mark - utility methods

- (NSMutableArray*) getMesagesForSpan : (NSDate*)tempDate andArray :(NSMutableArray*)scopeArray {
    
    NSDateFormatter *formatter = [NSDateFormatter defaultDateManager];
    NSLocale *enUSPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    
    
    for(RPConverstionMessage *mModel in scopeArray){
        NSString *dateString = mModel.timeStamp;
        [formatter setLocale:enUSPosixLocale];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
        NSDate *dateForMessage = [formatter dateFromString:dateString];

        if([Utils isDateofSameDay:tempDate andDate2:dateForMessage]) {
            [messagesArray addObject:mModel];
        }
    }
    
    return messagesArray;
}

- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    return [date compare:firstDate] == NSOrderedDescending &&
    [date compare:lastDate]  == NSOrderedAscending;
}

- (void) getUniqueDates {
    
    
    ALog(@"%lu",(unsigned long)self.conversation.messages.count);
    NSDateFormatter *formatter = [NSDateFormatter defaultDateManager];
    NSLocale *enUSPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    
    NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
                                                            ascending:YES
                                                             selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *array = [self.conversation.messages sortedArrayUsingDescriptors:@[sort]];
    
    uniqueDates = [[NSMutableArray alloc] init];
    for(RPConverstionMessage *mModel in array) {
        NSString *dateString = mModel.timeStamp;
        [formatter setLocale:enUSPosixLocale];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
        NSDate *dateForMessage = [formatter dateFromString:dateString];
        if(dateForMessage) {
            if(![self isDayAlreadyInUniqueDate:dateForMessage]) {
                [uniqueDates addObject:dateForMessage];
            }
        }
    }
}

- (BOOL) isDayAlreadyInUniqueDate :(NSDate*)dateToCheck {
    for(NSDate *tempDate in uniqueDates) {
        if([Utils isDateofSameDay:tempDate andDate2:dateToCheck]) {
            return true;
        }
    }
    return false;
}


#pragma mark - AnnouncementScreen

- (IBAction)addImagePressed:(id)sender {
    
    self.messageToSend.contentType = MESSAGE_CONTENT_TYPEAnnouncement;
    
    
    _addImg.image = [UIImage imageNamed:@"addImage-1"];
    _addLink.image = [UIImage imageNamed:@"addLinkgrey"];
    self.addLinkSmallView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.addLinkSmallView.layer.borderWidth = 1.0;
    
    isAnnouncement = true;
    [self btnAddPhoto:nil];
    _largeLinkView.hidden = YES;
    _addLinkSmallView.hidden = NO;
    
    self.linkUrlTxt.text = @"";
    self.linkTitleTxt.text = @"";
    
}


- (IBAction)addLinkPressed:(id)sender {
    
    self.messageToSend.contentType = MESSAGE_CONTENT_TYPEAnnouncement;
    
    _addImg.image = [UIImage imageNamed:@"addImagegrey"];
    _addLink.image = [UIImage imageNamed:@"addLink"];
    
    self.addImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.addImageView.layer.borderWidth = 1.0;
    _addLinkSmallView.hidden = YES;
    _largeLinkView.hidden = NO;
    self.selectedAnnouncementImage = nil;
    self.selectedImage = nil;
    _selectedImgView.image = nil;
    
}

- (IBAction)announcementCancelPressed:(id)sender {
    
    self.addMenuButton.hidden = NO;
    _createAnnouncementView.hidden = true;
    self.linkUrlTxt.text = @"";
    self.linkTitleTxt.text = @"";
    self.announcementTitleTxt.text = @"";
    self.announcementDetailsTxt.text = @"";
    self.selectedAnnouncementImage = nil;
    _selectedImgView.image = nil;
    isAnnouncement = NO;
    
    if (!isAnnouncement) {
        self.addMenuButton.hidden = NO;
    }
    
    self.messageToSend.contentType = MESSAGE_CONTENT_TYPE_TEXT;
}

- (IBAction)announcementDonePressed:(id)sender {
    
    BOOL sendMessage = NO;
    self.addMenuButton.hidden = NO;
    
    if(![_announcementTitleTxt.text isEqualToString:@""]){
        
        sendMessage = YES;
        if (![_linkUrlTxt.text isEqualToString:@""]) {
            if([_linkUrlTxt.text isValidURL]) {
                
                sendMessage = YES;
            }else{
                sendMessage = NO;
                [self setUpAlertView];
                _customAlert.alertTag = 10000;
                _customAlert.alertType = kAlertTypeDetail;
                UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                [self.customAlert showPopUpInView:top.view withMessage:NSLocalizedString(@"Create Announcement", nil) andDescription:NSLocalizedString(@"Please enter valid URL", nil)];
            }
        }else if (self.selectedAnnouncementImage) {
            sendMessage = YES;
            [self uploadImageToAmazonServer:self.selectedAnnouncementImage];
        }else{
            
        }
    }
    else
    {
        [self setUpAlertView];
        _customAlert.alertTag = 10000;
        _customAlert.alertType = kAlertTypeDetail;
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self.customAlert showPopUpInView:top.view withMessage:NSLocalizedString(@"Create Announcement", nil) andDescription:NSLocalizedString(@"Please enter announcement title", nil)];
        sendMessage = NO;
    }
    
    if (sendMessage) {
        
        self.messageToSend = [[RPConverstionMessage alloc] init];
        self.messageToSend.announcement = [[AnnouncementModel alloc] init];
        self.messageToSend.announcement.attachment = [[AttachmentModel alloc] init];
        self.messageToSend.announcement.title = [NSString validStringForObject:_announcementTitleTxt.text];
        self.messageToSend.announcement.contentType = MESSAGE_CONTENT_TYPEAnnouncement;
        self.messageToSend.announcement.attachment.contentType = ATTACHMENT_CONTENT_TYPE_URL;
        self.messageToSend.announcement.attachment.category = @"webLink";
        self.messageToSend.announcement.attachment.title = _linkTitleTxt.text;
        self.messageToSend.announcement.attachment.url = _linkUrlTxt.text;
        self.messageToSend.contentType = MESSAGE_CONTENT_TYPEAnnouncement;
        self.messageToSend.message = @"made a new announcement.";
        
        if (self.selectedAnnouncementImage) {
            self.messageToSend.announcement.photoId = self.photoID;
            self.messageToSend.announcement.attachment.placeHolderImage = self.selectedAnnouncementImage;
            self.messageToSend.placeHolderImage = self.selectedAnnouncementImage;
            self.messageToSend.announcement.attachment.contentType = ATTACHMENT_CONTENT_TYPE_Photo;
            self.messageToSend.announcement.attachment.image = self.uploadedImageUri;
            self.messageToSend.announcement.attachment.thumbnail = self.uploadedThumbnailImageUri;
        }
        
        _createAnnouncementView.hidden = true;
        [self sendMessageWithConversationID:self.conversation.conversationId];
        
    }else{
        
        
    }
    
    
    isAnnouncement = NO;
    
}


#pragma mark -
#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField canResignFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // add your method here
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view removeGestureRecognizer:tap];
    if(textField.tag > 9) {
        [self didEndEditing];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField  {
    [self addTouchGestureForKeyboard];
    if(textField.tag > 9) {
        [self didBeginEditingIn:textField];
    }
}
- (void)addTouchGestureForKeyboard {
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.view endEditing:true];
}

- (void)didBeginEditingIn:(UIView *)view
{
    
    //    [Utils moveViewPosition:-160 onView:self.announcementContentView completion:^(BOOL finished) {
    //    }];
    
    //    [UIView commitAnimations];
}

- (void)didEndEditing
{
    //    [Utils moveViewPosition:90 onView:self.announcementContentView completion:^(BOOL finished) {
    //
    //    }];
}

#pragma mark - Location Screen

- (void)snapshotImage:(void(^)(UIImage *image))completion
{
    UIImage *locImage = [UIImage imageWithView:self.locationMap];
    completion(locImage);
}

- (IBAction)locationBackPressed:(id)sender {
    _locationScreen.hidden = true;
    self.addMenuButton.hidden = NO;
}

- (IBAction)sendLocationPressed:(id)sender {
    
    [self setUpAlertView];
    _customAlert.isButtonSwitch = YES;
    _customAlert.alertTag = 1001;
    _customAlert.alertType = kAlertTypeMessage;
    
    [_customAlert showCustomAlertInView:self.view withMessage:@"Send Current Location" andDescription:@"Send your current location to everyone in this conversation?" setOkTitle:@"CANCEL" setCancelTitle:@"OK"];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    [self.locationMap setCenterCoordinate:mapView.userLocation.coordinate zoomLevel:14 animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *viewId = @"MKAnnotationView";
    MKAnnotationView *annotationView = (MKAnnotationView*)
    [_locationMap dequeueReusableAnnotationViewWithIdentifier:viewId];
    
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc]
                          initWithAnnotation:annotation reuseIdentifier:viewId];
    }
    
    annotationView.canShowCallout=YES;
    annotationView.image = [UIImage imageNamed:@"mapPin"];//set your image here
    return annotationView;
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"chatMessageSegue"]) {
        
        ChatMessageDetailVC *destSegue = [segue destinationViewController];
        destSegue.message = messageToForward;
        destSegue.conversation = self.conversation;
        
    }
    else if ([[segue identifier] isEqualToString:@"chatDetailSegue"]) {
        
        ChatDetailVC *destSegue = [segue destinationViewController];
        destSegue.delegate = (id)self;
        destSegue.conversation = _conversation;
    }
}


- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // handling code
        
        if ([self.conversation.messages count]) {
            [self performSegueWithIdentifier:@"chatDetailSegue" sender:self];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    
    BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
    
    if (isVerticalGesture) {
        if (velocity.y > 0) {
            [self.textView resignFirstResponder];
        } else {
            
        }
    }
}


-(void)layoutOptionsTitleView{
    
    [self.lblMessageType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.messageTypeTitleContainer);
    }];
    
    [self.leftSeperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.centerY.equalTo(self.lblMessageType.mas_centerY).with.offset(1.0);
        make.right.equalTo(self.lblMessageType.mas_left).with.offset(-10.0);
        make.left.equalTo(self.messageTypeTitleContainer.mas_left).with.offset(0);
    }];
    
    [self.rightSeperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.centerY.equalTo(self.lblMessageType.mas_centerY).with.offset(1.0);
        make.left.equalTo(self.lblMessageType.mas_right).with.offset(10.0);
        make.right.equalTo(self.messageTypeTitleContainer.mas_right).with.offset(10);
    }];
}


#pragma mark - Network Status
-(void)didNetworkConnected:(AFNetworkReachabilityStatus)status;{
    self.seachabilityStatus = status;
    
    [RKDropdownAlert dismissAllAlert];
    
    for (RPConverstionMessage *message in self.conversation.messages) {
        NSBlockOperation *messageSendingQueue = [[NSBlockOperation alloc] init];
        NSBlockOperation *operation = messageSendingQueue;
        [messageSendingQueue addExecutionBlock:^(void){
            if (!operation.isCancelled) {
                if (!message.isSentMessage) {
                    [self sendMessage:message];
                }
            }
        }];
        if (messageSendingQueue) {
            [_backgroundOperationQueue addOperation:messageSendingQueue];
        }
    }
}

-(void)didNetworkDisconnected:(AFNetworkReachabilityStatus)status;{
    self.seachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];
    [appDelegate showAlertView];
}


- (IBAction)btnGoToChatDetails:(id)sender {
    
    if ([self.conversation.messages count]) {
        [self performSegueWithIdentifier:@"chatDetailSegue" sender:self];
    }
}


- (IBAction)btnContactPopUpCancel:(id)sender {
    
    self.txtFieldContactName.text = @"";
    self.txtFieldPhone.text  = @"";
    [self handleTapFrom:nil];
}

- (IBAction)btnContactPopUpProceed:(id)sender;
{
    
    if (![self.txtFieldContactName.text isEqualToString:@""] && ![self.txtFieldPhone.text isEqualToString:@""]) {
        self.messageToSend = [[RPConverstionMessage alloc] init];
        self.messageToSend.message = @"shared a link.";
        self.messageToSend.contentType = MESSAGE_CONTENT_TYPEShareContact;
        self.messageToSend.contactModel = [[ContactModel alloc] init];
        self.messageToSend.contactModel.title = self.txtFieldContactName.text;
        self.messageToSend.contactModel.phone = self.txtFieldPhone.text;
        self.messageToSend.contactModel.contentType = MESSAGE_CONTENT_TYPEShareContact;
        [self sendMessageWithConversationID:self.conversation.conversationId];
        self.txtFieldContactName.text = @"";
        self.txtFieldPhone.text  = @"";
        [self handleTapFrom:nil];
        
    }
    
}



@end
