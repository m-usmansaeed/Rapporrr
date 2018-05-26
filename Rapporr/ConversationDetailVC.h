//
//  ConversationDetailVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCFloatingActionButton.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>
#import "ZLPeoplePickerViewController.h"
#import "RapporrAlertView.h"
#import "TextField.h"
#import "MessageSeenUser.h"
#import "AsyncImageView.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "TranslationManager.h"
#import "FileAttachmentCell.h"
#import "NewUserCell.h"
#import "AddNewMemberVC.h"
#import "CustomExpandedImageAnnouncementCell.h"
#import "EventExpandedCell.h"
#import "LocationExtandedCell.h"
#import "LinkExpandedCell.h"
#import "PictureCell.h"
#import "PictureExpandedCell.h"
#import "FileSharingExpandedCell.h"
#import "FileSharingCell.h"
#import "ContactExpandedCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MASConstraintMaker.h"
#import "DotActivityIndicatorView.h"
#import "NSString+TrimWhiteSpaces.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@protocol ChatDelegate <NSObject>

-(void)didMessageSent:(RPConverstionMessage *)message toConversation:(MessageModel *)conversation;
-(void)didCreatedNewConversation:(MessageModel *)conversation;

@end

@interface ConversationDetailVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate,ZLPeoplePickerViewControllerDelegate,TextViewDelegate,UIViewControllerTransitioningDelegate,MKMapViewDelegate,  CLLocationManagerDelegate>
{

    float heightKeyboardHeight;
    NSMutableArray *headersArray;
    NSMutableArray *messagesDictArray;
    NSMutableArray *uniqueDates;
    UITapGestureRecognizer *tap;
    
    BOOL isAnnouncement;
    BOOL isImageAnnouncement;

    BOOL isDataLoaded;
    
    RPConverstionMessage *messageToForward;
    IBOutlet DotActivityIndicatorView *dotsActivityView;
}

- (IBAction)btnGoToChatDetails:(id)sender;

@property (weak, nonatomic) id<ChatDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIView *announcementContentView;
@property (strong, nonatomic) IBOutlet UITableView *customizeTblView;

@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
@property (strong, nonatomic) UIImage *imgUploading;
@property (strong, nonatomic) UIImage *locationImage;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIView *editMessageContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet TextField *textView;


- (IBAction)btnBack:(id)sender;
- (IBAction)btnSendMessage:(id)sender;
- (IBAction)btnAddFile:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFile;



@property (weak, nonatomic) IBOutlet UIView *actionSheetButtonView;
@property (weak, nonatomic) IBOutlet UIView *actionBgView;

- (IBAction)actionSheetButtons:(id)sender;
- (IBAction)btnHideActionSheet:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *addAcctionsBgView;
- (IBAction)btnAddLocation:(id)sender;
- (IBAction)btnCreateAnnouncement:(id)sender;
- (IBAction)btnAddContact:(id)sender;
- (IBAction)btnAddPhoto:(id)sender;
- (IBAction)btnSelectContact:(id)sender;
- (IBAction)btnCloseActionView:(id)sender;


//=======================================================

@property (weak, nonatomic) IBOutlet UIView *contactsActionSheetButtonView;
@property (weak, nonatomic) IBOutlet UIView *contactsActionBgView;

- (IBAction)contactsActionSheetButtons:(id)sender;

//=======================================================

@property (strong, nonatomic) VCFloatingActionButton *addMenuButton;

@property(strong, nonatomic) ConversationUser *user;
@property(strong) MessageModel *conversation;

@property (nonatomic) BOOL isKeyboardAppear;

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) ZLPeoplePickerViewController *peoplePicker;
@property (nonatomic, strong) APContact *selectedContact;
@property (nonatomic, strong) RapporrAlertView *customAlert;

@property (nonatomic, strong) UIRefreshControl *refresh;
@property (strong, nonatomic) NSMutableArray <RPConverstionMessage*>*convMessages;
@property (strong, nonatomic) RPConverstionMessage *unSentMessage;
@property (strong ,nonatomic) NSMutableDictionary *cellHeighs;

@property (nonatomic) NSIndexPath *expandIndexPath;
@property (nonatomic) NSIndexPath *expandIndexPathOnTranslation;
@property (nonatomic) BOOL isExpandedCell;

@property (strong, nonatomic) NSString *messageType;


@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSString *uploadedImageUri;
@property (strong, nonatomic) NSString *uploadedThumbnailImageUri;
@property (strong, nonatomic) RPConverstionMessage *messageToSend;;

@property (strong, nonatomic) NSMutableArray *operations;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *announcementScrollView;

#pragma mark - AnnouncementScreen

@property float animatedDistance;
@property (strong, nonatomic) IBOutlet UIView *createAnnouncementView;
@property (strong, nonatomic) IBOutlet UIView *addImageView;
@property (strong, nonatomic) IBOutlet UIImageView *addImg;
@property (strong, nonatomic) IBOutlet UIImageView *addLink;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImgView;

@property (strong, nonatomic) IBOutlet UITextField *announcementTitleTxt;
@property (strong, nonatomic) IBOutlet UITextField *announcementDetailsTxt;
@property (strong, nonatomic) IBOutlet AsyncImageView *announcementImgView;
@property (strong, nonatomic) IBOutlet UIView *addLinkSmallView;
@property (strong, nonatomic) IBOutlet UIButton *addImageBtn;
@property (strong, nonatomic) IBOutlet UIImageView *addLinkBtn;

@property (strong, nonatomic) IBOutlet UIView *largeLinkView;
@property (strong, nonatomic) IBOutlet UITextField *linkTitleTxt;
@property (strong, nonatomic) IBOutlet UITextField *linkUrlTxt;



- (IBAction)addImagePressed:(id)sender;
- (IBAction)addLinkPressed:(id)sender;



- (IBAction)announcementCancelPressed:(id)sender;
- (IBAction)announcementDonePressed:(id)sender;

@property (strong, nonatomic) NSDictionary *conversationDictData;
@property (strong, nonatomic) UIImage *selectedAnnouncementImage;;
@property (strong, nonatomic) UIImage *selectedImage;



#pragma mark - Location Screen

@property (strong, nonatomic) IBOutlet MKMapView *locationMap;


@property (strong, nonatomic) IBOutlet UIView *locationScreen;

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)locationBackPressed:(id)sender;
- (IBAction)sendLocationPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UIView *editingBlockingView;

@property (strong, nonatomic) ConversationUser *addedUser;
@property (nonatomic) BOOL isDirectMessage;
@property (nonatomic) BOOL isSegueUserProfile;
-(void)sendMessageWithConversationID:(NSString *)ConversationId;


@property (weak, nonatomic) IBOutlet UIView *leftSeperator;
@property (weak, nonatomic) IBOutlet UIView *rightSeperator;
@property (weak, nonatomic) IBOutlet UILabel *lblMessageType;
@property (weak, nonatomic) IBOutlet UIView *messageTypeTitleContainer;


- (void) updateMessageCounter;


@property (strong, nonatomic) IBOutlet UIView *contactPopUpContainer;
@property (strong, nonatomic) IBOutlet UIView *contactPopUp;
@property (weak, nonatomic) IBOutlet UIView *contactPopUpShadowView;
- (IBAction)btnContactPopUpCancel:(id)sender;
- (IBAction)btnContactPopUpProceed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldContactName;









@end
