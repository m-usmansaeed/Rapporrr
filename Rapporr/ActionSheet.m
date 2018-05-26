//
//  ActionSheet.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 16/06/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "ActionSheet.h"

@interface ItemCell ()

@end
@implementation ItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end

@interface ActionSheet ()

@end

@implementation ActionSheet

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect viewRect = self.containerView.frame;
    viewRect.origin.y = 1000;
    self.containerView.frame = viewRect;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.cancelsTouchesInView = YES;
    tapGestureRecognizer.delegate = (id)self;
    [self.shadowView addGestureRecognizer:tapGestureRecognizer];
    [self.shadowView setUserInteractionEnabled:YES];
    [self.shadowView setExclusiveTouch:YES];
}

-(void)showActionSheet:(UIView *)targetView withTitle:(NSString *)title;
{
    
    CGFloat statusBarOffset;
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
        if (statusBarSize.width < statusBarSize.height) {
            statusBarOffset = statusBarSize.width;
        }
        else{
            statusBarOffset = statusBarSize.height;
        }
    }
    else{
        statusBarOffset = 0.0;
    }
    
    CGFloat width, height;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        width = targetView.frame.size.height;
        height = targetView.frame.size.width;
    }
    else{
        width = targetView.frame.size.width;
        height = targetView.frame.size.height;
    }
    
    [self.view setFrame:CGRectMake(targetView.frame.origin.x, targetView.frame.origin.y, width, height)];
    
    self.lblTitle.text = title;
    
    [self.tableView reloadData];
    [targetView addSubview:self.view];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    CGRect viewRect = self.containerView.frame;
    viewRect.size.height = ([self.items count] * 51) + 37;
    viewRect.origin.y = self.view.frame.size.height - ([self.items count] * 51)-37;
    self.containerView.frame = viewRect;
    [UIView commitAnimations];
    
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self hide];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.itemLabel.text = [self.items objectAtIndex:[indexPath row]];
    cell.itemImageView.image =  [UIImage imageNamed:[self.images objectAtIndex:[indexPath row]]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.ItemSelectedAtIndexPath) {
        self.ItemSelectedAtIndexPath(indexPath);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)hide{
    
    [UIView animateWithDuration:0.25f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGRect viewRect = self.containerView.frame;
                         viewRect.origin.y = 1000;
                         self.containerView.frame = viewRect;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve
                                          animations:^{ self.shadowView.layer.opacity = 0.0f; } completion:^(BOOL finished) {
                                              [self.view removeFromSuperview]; } ]; }
     ];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view.superview.superview isKindOfClass:NSClassFromString(@"ItemCell")])
    {
        return NO;
    }
    return YES;
}

@end
