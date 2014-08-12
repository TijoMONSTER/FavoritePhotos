//
//  FavoritesViewController.m
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "FavoritesViewController.h"
#import "PhotoCell.h"
#import "SearchViewController.h"

@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property NSMutableArray *favoritePhotos;
@property NSMutableDictionary *cachedImages;

@end

@implementation FavoritesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationBarHidden = NO;
	[self load];

	self.cachedImages = [NSMutableDictionary new];
	if (!self.favoritePhotos) {
		self.favoritePhotos = [NSMutableArray new];

		UIAlertView *alertView = [UIAlertView new];
		alertView.message = @"No favorites, tap the search button to finde some.";
		[alertView addButtonWithTitle:@"OK"];
		[alertView show];
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.favoritePhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];

	NSString *imageURLString = self.favoritePhotos[indexPath.row];

	if (!self.cachedImages[imageURLString]) {
		// download image
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]];
		[NSURLConnection sendAsynchronousRequest:urlRequest
										   queue:[NSOperationQueue mainQueue]
							   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

								   if (!connectionError) {
									   self.cachedImages[imageURLString] = [UIImage imageWithData:data];
									   [cell setImage:self.cachedImages[imageURLString]];
									   [cell hideActivityIndicator];
								   }
								   // connection error
								   else {
									   if ([connectionError.localizedDescription isEqualToString: @"bad URL"]) {
										   self.cachedImages[imageURLString] = [UIImage imageNamed:@"photo_placeholder"];
										   [cell setImage:self.cachedImages[imageURLString]];
										   [cell hideActivityIndicator];
									   }

									   UIAlertView *alertView = [UIAlertView new];
									   alertView.title = @"Connection error";
									   alertView.message = connectionError.localizedDescription;
									   [alertView addButtonWithTitle:@"OK"];
									   [alertView show];
								   }
							   }];
	} else {
		[cell setImage:self.cachedImages[imageURLString]];
	}

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *pCell = (PhotoCell *)cell;
	[pCell setImage:nil];
}

#pragma mark - Segues

- (IBAction)unwindFromSearchViewController:(UIStoryboardSegue *)segue
{
	SearchViewController *searchVC = (SearchViewController *)segue.sourceViewController;

	NSString *selectedFavoritePhotoURLString = [searchVC selectedFavoritePhotoURLString];
	[self.favoritePhotos addObject:selectedFavoritePhotoURLString];
	[self save];
	NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.collectionView scrollToItemAtIndexPath:firstItemIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
	[self.collectionView reloadData];
}

#pragma mark - Persistence

- (NSURL *)documentsDirectory
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *directories = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	return directories.firstObject;
}

- (void)save
{
	NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"favoritephotos.plist"];

	NSLog(@"%d success!",[self.favoritePhotos writeToURL:plist atomically:YES]);
}

- (void)load
{
	NSURL *plist = [[self documentsDirectory] URLByAppendingPathComponent:@"favoritephotos.plist"];
	self.favoritePhotos = [NSMutableArray arrayWithContentsOfURL:plist];
}


@end
