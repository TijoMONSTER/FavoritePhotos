//
//  PhotoCell.m
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PhotoCell.h"

@interface PhotoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PhotoCell

- (void)setImage:(UIImage *)image
{
	self.imageView.image = image;
}

- (void)showActivityIndicator
{
	[self.activityIndicator startAnimating];
}

- (void)hideActivityIndicator
{
	[self.activityIndicator stopAnimating];
}

@end
