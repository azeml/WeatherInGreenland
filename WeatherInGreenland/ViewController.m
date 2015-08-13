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
    self.yqlResults = [self.yql query:GREENLAND_QUERRY];
    NSLog(@"%@", [self.yqlResults valueForKeyPath:@"query"]);
    
    // populate UI
    self.titleLabel.text = [self.yqlResults valueForKeyPath:TITLE_PATH];
    self.conditionLabel.text = [self.yqlResults valueForKeyPath:CONDITION_PATH];
    self.temperatureLabel.text = [[self.yqlResults valueForKeyPath:TEMPERATURE_PATH] stringByAppendingFormat:@"°%@", [self.yqlResults valueForKeyPath:TEMP_UNIT_PATH]];
    
    self.sunriseTimeLabel.text = [self.yqlResults valueForKeyPath:SUNRISE_PATH];
    self.sunsetTimeLabel.text = [self.yqlResults valueForKeyPath:SUNSET_PATH];
    
    NSString *itemDsc = [self.yqlResults valueForKeyPath:FORECAST_PATH];
    [self.forecastWebView loadHTMLString:itemDsc baseURL:nil];
    
    // add sunrise/sunset animations
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

- (void)viewDidAppear:(BOOL)animated {
    // add condition animations
    self.conditionsBG.alpha = .5;
    if ([[self.yqlResults valueForKeyPath:CONDITION_PATH] containsString:@"Cloudy"]) {
        [self addClouds];
    } else {
        [self addHintButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - condition animations

- (void)addClouds {
    // 1st level cloud
    UIImage *cloudImage = [UIImage imageNamed:@"cloud"];
    CGSize origSz = cloudImage.size;
    UIImageView *cloudImageView = [[UIImageView alloc] initWithImage:cloudImage];
    cloudImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * origSz.height / origSz.width);
    CGSize cloudSz = cloudImageView.frame.size;
    CGPoint p = cloudImageView.center;
    p.x += self.conditionsBG.frame.size.width;
    cloudImageView.center = p;
    [UIView animateWithDuration:25 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
        CGPoint p = cloudImageView.center;
        p.x -= self.conditionsBG.frame.size.width * 2;
        cloudImageView.center = p;
    }completion:^(BOOL finished){}];
    // 2nd level cloud
    UIImageView *cloud2ImageView = [[UIImageView alloc] initWithImage:cloudImage];
    cloud2ImageView.alpha = .6;
    cloud2ImageView.frame = CGRectMake(0, cloudSz.height / 4, cloudSz.width / 2, cloudSz.height / 2);
    p = cloud2ImageView.center;
    p.x += self.conditionsBG.frame.size.width;
    cloud2ImageView.center = p;
    [UIView animateWithDuration:35 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
        CGPoint p = cloud2ImageView.center;
        p.x -= (self.conditionsBG.frame.size.width + cloudSz.width / 2);
        cloud2ImageView.center = p;
    }completion:^(BOOL finished){}];
    // 3nd level cloud
    UIImageView *cloud3ImageView = [[UIImageView alloc] initWithImage:cloudImage];
    cloud3ImageView.alpha = .3;
    cloud3ImageView.frame = CGRectMake(0, cloudSz.height / 6, cloudSz.width / 3, cloudSz.height / 3);
    p = cloud3ImageView.center;
    p.x += self.conditionsBG.frame.size.width;
    cloud3ImageView.center = p;
    [UIView animateWithDuration:45 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
        CGPoint p = cloud3ImageView.center;
        p.x -= (self.conditionsBG.frame.size.width + cloudSz.width / 3);
        cloud3ImageView.center = p;
    }completion:^(BOOL finished){}];

    // add subviews from back level to forth level
    [self.conditionsBG addSubview:cloud3ImageView];
    [self.conditionsBG addSubview:cloud2ImageView];
    [self.conditionsBG addSubview:cloudImageView];
}

- (void)addHintButton {
    CGRect frame = CGRectMake(self.view.frame.size.width, 20, 190, 30);
    UIButton *hintButton = [[UIButton alloc] initWithFrame:frame];
    hintButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
    [hintButton.layer setCornerRadius:10];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Press to test Cloud Animation" attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:12] forKey:NSFontAttributeName]];
    [hintButton setAttributedTitle:title forState:UIControlStateNormal];
    [hintButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [hintButton addTarget:self action:@selector(hintTapped:) forControlEvents:UIControlEventTouchUpInside];
    [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGPoint p = hintButton.center;
        p.x -= 200;
        hintButton.center = p;
    }completion:^(BOOL finished){}];
    [self.view addSubview:hintButton];
}

- (void)hintTapped:(id)sender {
    [UIView animateWithDuration:.5 animations:^{
        UIButton *hintButton = (UIButton *)sender;
        hintButton.alpha = 0;
    }completion:^(BOOL finished){
        [sender removeFromSuperview];
        [self addClouds];
    }];
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
