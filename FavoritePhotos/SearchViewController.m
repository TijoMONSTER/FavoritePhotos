//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "SearchViewController.h"
#import "Photo.h"
#import "PhotoCell.h"
#import "FavoritesViewController.h"

#define urlToGetFlickrPhotos @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=ac464ee6ed976f4f7c0e48e3152a24ad&format=json&nojsoncallback=1&has_geo=1&per_page=10&extras=url_z,geo&tag_mode=all&tags="

@interface SearchViewController () <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property NSMutableArray *searchedPhotos;
//@property NSMutableArray *favoritePhotos;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.searchedPhotos = [NSMutableArray new];

//	if (!self.favoritePhotos) {
//		self.favoritePhotos = [NSMutableArray new];
//	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	[self loadFlickrPhotosWithKeywords:searchBar.text];
}

- (void)loadFlickrPhotosWithKeywords:(NSString *)keywords
{
	[self.activityIndicator startAnimating];

	// take spaces out
	keywords = [keywords stringByReplacingOccurrencesOfString:@" " withString:@","];

	NSString *formedURLString = [NSString stringWithFormat:@"%@%@", urlToGetFlickrPhotos, keywords];
	NSURL *url = [NSURL URLWithString: formedURLString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

		if (!connectionError) {
			NSError *error;
			NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];

			if (!error) {
				// no errors :)
				if (self.searchedPhotos.count > 0) {
					[self.searchedPhotos removeAllObjects];
				}

				for (NSDictionary *photoDictionary in decodedJSON[@"photos"][@"photo"]) {
					Photo *photo = [[Photo alloc] initWithDictionary:photoDictionary];
					[self.searchedPhotos addObject:photo];
				}

				[self.activityIndicator stopAnimating];
				[self.collectionView reloadData];
				NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
				[self.collectionView scrollToItemAtIndexPath:firstItemIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];

			} else {
				// error decoding json
				[self showAlertViewWithTitle:@"Error" message:error.localizedDescription buttonText:@"OK"];
			}
		} else {
			// connection error
			[self showAlertViewWithTitle:@"Connection error" message:connectionError.localizedDescription buttonText:@"OK"];
		}
	}];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.searchedPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Photo *photo = self.searchedPhotos[indexPath.row];
	PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];

	if (!photo.image) {

		[cell showActivityIndicator];
		// download image
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:photo.imageURL];
		[NSURLConnection sendAsynchronousRequest:urlRequest
										   queue:[NSOperationQueue mainQueue]
							   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

								   if (!connectionError) {
									   photo.image = [UIImage imageWithData:data];
									   [cell setImage:photo.image];
									   [cell hideActivityIndicator];
								   }
								   // connection error
								   else {
									   if ([connectionError.localizedDescription isEqualToString: @"bad URL"]) {
										   photo.image = [UIImage imageNamed:@"photo_placeholder"];
										   [cell setImage:photo.image];
										   [cell hideActivityIndicator];
									   }
									   [self showAlertViewWithTitle:@"Connection error" message:connectionError.localizedDescription buttonText:@"OK"];
								   }
							   }];
	} else {
		[cell setImage:photo.image];
	}

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoCell *pCell = (PhotoCell *)cell;
	[pCell setImage:nil];
	[pCell hideActivityIndicator];
}

#pragma mark - Helper methods

- (NSString *)selectedFavoritePhotoURLString
{
	NSIndexPath *indexPath = self.collectionView.indexPathsForSelectedItems[0];
	Photo *photo = self.searchedPhotos[indexPath.row];
	return [photo.imageURL relativeString];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message buttonText:(NSString *)buttonText
{
	UIAlertView *alertView = [UIAlertView new];
	alertView.title = title;
	alertView.message = message;
	[alertView addButtonWithTitle:buttonText];
	[alertView show];
	NSLog(@"%@", message);
}

@end
