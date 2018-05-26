//
//  EditProfileVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-OR on 16/06/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "EditProfileVC.h"

@interface EditProfileVC (){
    UIGestureRecognizer *tap;
    
}
@property (strong, nonatomic) ConversationUser *user;
@end

@implementation EditProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
    self.roleField.text = self.user.uType;
    self.nameField.text = self.user.name;
    self.jobTitleField.text = self.user.jobTitle;
    [self setUpAlertView];
    if(self.user.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:self.user.avatarUrl];
        UIImage *placeholder = [UIImage imageNamed:@"placeholder_user"];
        if([self hasCachedImage]){
            placeholder = [Utils loadImage];
        }
        [self.imgViewUserProfile setImageWithURL:imageUrl placeholderImage:placeholder options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
        [self.imgViewUserProfile setImageWithString:self.user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
    }
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)popVC:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark CustomAlert Delegates
- (void) setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
}

-(void)RapporrAlertOK:(id)sender{
    [self.customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel{
}

-(void)RapporrAlertCancel:(id)sender{
}

-(BOOL)hasCachedImage{
    UIImage *profileImage = [Utils loadImage];
    CGImageRef cgref = [profileImage CGImage];
    CIImage *cim = [profileImage CIImage];
    if (cim == nil && cgref == NULL)
    {
        NSLog(@"no underlying data");
        return NO;
    }
    else{
        return YES;
    }
}
#pragma mark photoPressed
-(IBAction)changePhotoTapped:(id)sender{
    self.actionSheet = [self.storyboard instantiateViewControllerWithIdentifier:@"ActionSheet"];
    self.actionSheet.items = [@[@"From Camera",@"From Gallery"] mutableCopy];
    self.actionSheet.images = [@[@"photo_camera",@"gallery"] mutableCopy];
    
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.actionSheet showActionSheet:top.view withTitle:@"Select Profile Picture"];
    __weak __typeof(self)weakSelf = self;
    [self.actionSheet setItemSelectedAtIndexPath:^(NSIndexPath *indexPath){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"%@",indexPath);
        if(indexPath.row == 0){
            [strongSelf presentPickerForCamera];
        }
        else if(indexPath.row == 1){
            [strongSelf presentPickerForGallery];
        }
        [strongSelf.actionSheet hide];
        
    }];
}
-(IBAction)saveProfileBtnTapped:(id)sender{
    NSString *jobTitleString = self.jobTitleField.text;
    if([self.user.jobTitle isEqualToString:jobTitleString] && [self.user.name isEqualToString:self.nameField.text]){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        if([self.nameField.text isEqualToString:@""]){
            [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Error",nil) andDescription:NSLocalizedString(@"Please enter name",nil)];
        }
        else{
            [self updateProfileCall];
        }
    }
}

-(void)updateProfileCall{
    
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    NSString *jobTitleString = self.jobTitleField.text;
    NSString *objects = [@{@"jobTitle":jobTitleString} jsonString];
    self.user.name = self.nameField.text;
    self.user.objects = objects;
    [[CoreDataController sharedManager] updateUser:self.user];
    [SVProgressHUD show];
    NSDictionary *params = @{
                             @"user" : userId,
                             @"fullname" : self.nameField.text,
                             @"objects" : objects
                             };
    [NetworkManager makePOSTCall:URI_POST_USER_PROFILE parameters:params success:^(id data, NSString *timestamp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    //    UIImage *orgImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    //    NSData *imageData = UIImageJPEGRepresentation(orgImage, 0.7);
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.photoID = [self generatePhotoId:@""];
    
    self.imgViewUserProfile.image = image;
    //        selectedImage = image;
    [self uploadImageToAmazonServer:image withCompletion:^(BOOL isCompleted) {
        
    }];
    [self serverCall];
    self.user.avatarUrl = self.uploadedThumbnailUrl;
    [[CoreDataController sharedManager] updateUser:self.user];
    [Utils saveImage:image];
    [self.delegate didChangeProfilePic:self.uploadedThumbnailUrl];
}

-(void)serverCall{
    [SVProgressHUD show];
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    NSDictionary *params = @{
                             @"user" : userId,
                             @"avatarUrl" : self.uploadedThumbnailUrl,
                             @"organisationId" : [RapporrManager sharedManager].vcModel.orgId
                             };
    [NetworkManager makePOSTCall:URI_POST_SEND_AVATAR parameters:params success:^(id data, NSString *timestamp) {
        [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Profile Picture",nil) andDescription:NSLocalizedString(@"Your profile picture has been successfully updated. It might take up to 15 mins to update take effect.",nil)];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark ImagePicker

-(void)presentPickerForCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = (id)self;
        imagePickerController.allowsEditing = YES;
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
}

-(void)presentPickerForGallery{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = (id)self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark DismissKeyboard
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

#pragma mark - Upload Image to Amazon Server

- (void) uploadImageToAmazonServer : (UIImage *)imageToUpload withCompletion:(void (^)(BOOL isCompleted))completion {
    
    NSData *imageToUploadThumbnail = UIImageJPEGRepresentation([imageToUpload imageWithFillSize:CGSizeMake(100, 100)], 1.0);
    
    NSLog(@"%f",[UIImage imageWithData:imageToUploadThumbnail].size.height);
    NSLog(@"%f",[UIImage imageWithData:imageToUploadThumbnail].size.width);
    
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imageToUploadThumbnail length]);
    self.uploadedThumbnailUrl = [NSString stringWithFormat:@"https://rapporrapp.s3.amazonaws.com/%@",self.photoID];
    [NetworkManager postImageOnAmazonServer:imageToUploadThumbnail parameters:@"thumbnail" andphotoID:[NSString stringWithFormat:@"%@",self.photoID] success:^(id data, NSString *timestamp) {
        completion(YES);
        
    } failure:^(NSError *error) {}];
    
}

-(NSString*) generatePhotoId : (NSString*) type {
    NSString * timeInMS = [NSString stringWithFormat:@"%lld", [@(floor(([[NSDate date] timeIntervalSince1970] * 1000)/60000)-24000000) longLongValue]];
    
    NSString *photoIDTemp = [NSString stringWithFormat:@"%@%@%@",[RapporrManager sharedManager].vcModel.hostID,[RapporrManager sharedManager].vcModel.userId,timeInMS];
    
    return photoIDTemp;
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
