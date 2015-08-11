//
//  ViewController.m
//  WeatherInGreenland
//
//  Created by Alexander on 31/07/15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "ViewController.h"

#define GREENLAND_QUERRY    @"select * from weather.forecast where woeid in (select woeid from geo.places(1) where text=\"greenland\")"
#define FORECAST_PATH       @"query.results.channel.item.description"
#define TITLE_PATH          @"query.results.channel.location.city"
#define CONDITION_PATH      @"query.results.channel.item.condition.text"
#define TEMPERATURE_PATH    @"query.results.channel.item.condition.temp"
#define TEMP_UNIT_PATH      @"query.results.channel.units.temperature"
#define SUNRISE_PATH        @"query.results.channel.astronomy.sunrise"
#define SUNSET_PATH         @"query.results.channel.astronomy.sunset"

#define MAX_TITLE_TOP_SPACE 50

@interface ViewController () <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) CGPoint prevOffset;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // load data from Yahoo!
    self.yql = [[YQL alloc] init];
    NSDictionary *results = [self.yql query:GREENLAND_QUERRY];
    NSLog(@"%@", [results valueForKeyPath:@"query"]);
    
    // populate UI
    self.titleLabel.text = [results valueForKeyPath:TITLE_PATH];
    self.conditionLabel.text = [results valueForKeyPath:CONDITION_PATH];
    self.temperatureLabel.text = [[results valueForKeyPath:TEMPERATURE_PATH] stringByAppendingFormat:@"°%@", [results valueForKeyPath:TEMP_UNIT_PATH]];
    
    self.sunriseTimeLabel.text = [results valueForKeyPath:SUNRISE_PATH];
    self.sunsetTimeLabel.text = [results valueForKeyPath:SUNSET_PATH];
    
    NSString *itemDsc = [results valueForKeyPath:FORECAST_PATH];
    [self.forecastWebView loadHTMLString:itemDsc baseURL:nil];
    
    // add animations
    CGRect sunriseTimeFrame = self.sunriseTimeLabel.frame;
    CGRect sunriseFrame = self.sunriseLabel.frame;
    CGRect sunsetTimeFrame = self.sunsetTimeLabel.frame;
    CGRect sunsetFrame = self.sunsetLabel.frame;
    CGFloat sty = sunriseTimeFrame.origin.y;
    CGFloat sy = sunriseFrame.origin.y;
    sunriseTimeFrame.origin.y += self.sunriseSunsetView.frame.size.height;
    sunriseFrame.origin.y += self.sunriseSunsetView.frame.size.height;
    sunsetTimeFrame.origin.y -= self.sunriseSunsetView.frame.size.height;
    sunsetFrame.origin.y -= self.sunriseSunsetView.frame.size.height;
    
    self.sunriseTimeLabel.frame = sunriseTimeFrame;
    self.sunriseLabel.frame = sunriseFrame;
    self.sunsetTimeLabel.frame = sunsetTimeFrame;
    self.sunsetLabel.frame = sunsetFrame;
    sunriseTimeFrame.origin.y = sty;
    sunsetTimeFrame.origin.y = sty;
    sunriseFrame.origin.y = sy;
    sunsetFrame.origin.y = sy;
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.sunriseTimeLabel.frame = sunriseTimeFrame;
                         self.sunriseLabel.frame = sunriseFrame;
                         
                         self.sunsetTimeLabel.frame = sunsetTimeFrame;
                         self.sunsetLabel.frame = sunsetFrame;
                     }
                     completion:^(BOOL finished){}];
    
    // hook on scroll events
    self.forecastWebView.scrollView.delegate = self;
    self.prevOffset = self.forecastWebView.scrollView.contentOffset;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        // open links being clicked in Safari
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.frame.size.height <= scrollView.contentSize.height) {
        CGFloat h = self.sunriseSunsetHeightConstraint.constant - scrollView.contentOffset.y / 2;
        self.sunriseSunsetView.alpha = self.titleTopSpaceConstraint.constant * 3 / MAX_TITLE_TOP_SPACE - 2;
        if (h < 0) {
            return;
        }
        else if (h > MAX_TITLE_TOP_SPACE) {
            return;
        }
        self.titleTopSpaceConstraint.constant = h;
        self.sunriseSunsetHeightConstraint.constant = h;
        scrollView.contentOffset = self.prevOffset;
        self.prevOffset = scrollView.contentOffset;
    }
}

@end
