//
//  EditProfileVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-OR on 16/06/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfilePictureDelegate <NSObject>
-(void)didChangeProfilePic:(NSString *)avatarUrl;
@end

@interface EditProfileVC : UIViewController{
}

@property (weak, nonatomic) id<ProfilePictureDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewUserProfile;
@property (weak, nonatomic) IBOutlet UITextField *roleField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleField;

@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSString *uploadedImageUrl;
@property (strong, nonatomic) NSString *uploadedThumbnailUrl;

@property (nonatomic, strong) RapporrAlertView *customAlert;
@property (nonatomic, strong) ActionSheet *actionSheet;
@end
