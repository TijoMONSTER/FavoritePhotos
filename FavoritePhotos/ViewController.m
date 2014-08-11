//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Iván Mervich on 8/11/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ViewController.h"

#define urlToGetFlickrPhotos @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=ac464ee6ed976f4f7c0e48e3152a24ad&format=json&nojsoncallback=1&has_geo=1&per_page=10&extras=url_c,geo&tag_mode=all&tags="

@interface ViewController () <UISearchBarDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];

//	if (searchBar.text.length > 0) {
		[self loadFlickrPhotosWithKeywords:searchBar.text];
//	}
}

- (void)loadFlickrPhotosWithKeywords:(NSString *)keywords
{
	// take spaces out
	keywords = [keywords stringByReplacingOccurrencesOfString:@" " withString:@","];

	NSString *formedURLString = [NSString stringWithFormat:@"%@%@", urlToGetFlickrPhotos, keywords];
	NSURL *url = [NSURL URLWithString: formedURLString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

		if (!connectionError) {
			NSError *error;
			NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
			NSLog(@"%@", decodedJSON);
		} else {
			[self showAlertViewWithTitle:@"Connection error" message:connectionError.localizedDescription buttonText:@"OK"];
		}
	}];
}

#pragma mark - Helper methods

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
