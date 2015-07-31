//
//  ViewController.h
//  WeatherInGreenland
//
//  Created by Alexander on 31/07/15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQL.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) YQL *yql;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *conditionLabel;
@property (nonatomic, strong) IBOutlet UILabel *temperatureLabel;
@property (nonatomic, strong) IBOutlet UIView *sunriseSunsetView;
@property (nonatomic, strong) IBOutlet UILabel *sunriseTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *sunriseLabel;
@property (nonatomic, strong) IBOutlet UILabel *sunsetTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *sunsetLabel;
@property (nonatomic, strong) IBOutlet UIWebView *forecastWebView;

@end

