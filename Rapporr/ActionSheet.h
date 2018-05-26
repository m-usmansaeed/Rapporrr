//
//  ActionSheet.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 16/06/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@end

@interface ActionSheet : UIViewController<UITableViewDataSource,UITableViewDelegate>


typedef void (^DidTapAtIndexPath)(NSIndexPath *indexPath);
@property (copy, nonatomic) DidTapAtIndexPath ItemSelectedAtIndexPath;


@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *images;

-(void)showActionSheet:(UIView *)targetView withTitle:(NSString *)title;
-(void)hide;

@end

