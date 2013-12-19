//
//  BatteryView.m
//  EnergyBreakapp
//
//  Created by Utkarsh Dalal on 12/12/13.
//  Copyright (c) 2013 UC Berkeley. All rights reserved.
//

#import "BatteryView.h"

@implementation BatteryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        hasDistribution = NO;
    }
    return self;
}

-(void) setDistributionForCoal: (double) coalPercentage Oil: (double) oilPercentage Gas: (double) gasPercentage Nuclear: (double) nuclearPercentage Hydro: (double) hydroPercentage Renewable: (double) renewablePercentage OtherFossil: (double) otherFossilPercentage Geothermal: (double) geothermalPercentage Wind: (double) windPercentage Solar: (double) solarPercentage Biomass: (double) biomassPercentage OptOut: (double) optOutPercentage AndTotal: (double) totalPercentage
{
    currentCoalPercentage = coalPercentage/totalPercentage;
    currentOilPercentage = oilPercentage/totalPercentage;
    currentGasPercentage = gasPercentage/totalPercentage;
    currentNuclearPercentage = nuclearPercentage/totalPercentage;
    currentHydroPercentage = hydroPercentage/totalPercentage;
    currentRenewablePercentage = renewablePercentage/totalPercentage;
    currentOtherFossilPercentage = otherFossilPercentage/totalPercentage;
    currentGeothermalPercentage = geothermalPercentage/totalPercentage;
    currentWindPercentage = windPercentage/totalPercentage;
    currentSolarPercentage = solarPercentage/totalPercentage;
    currentBiomassPercentage = biomassPercentage/totalPercentage;
    currentOptOutPercentage = optOutPercentage/totalPercentage;
    currentTotalPercentage = totalPercentage;
    hasDistribution = YES;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    if (hasDistribution) {
        [self fillBattery];
    }
}

- (void)drawBattery
{
    CGFloat top = self.bounds.origin.y;
    CGFloat left = self.bounds.origin.x;
    CGFloat right = left + self.bounds.size.width;
    CGFloat bottom = top + self.bounds.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.5);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGRect batteryRectangle = CGRectMake(left + 1.25, top + 1.25, self.bounds.size.width - 12.5, self.bounds.size.height - 2.5);
    CGRect batteryTopRectangle = CGRectMake(right - 11.25, self.bounds.size.height/2 - 10, 7.5, 20);
    CGContextAddRect(context, batteryRectangle);
    CGContextAddRect(context, batteryTopRectangle);
    CGContextStrokePath(context);
}

/* The following code taken from http://www.raywenderlich.com/32283/core-graphics-tutorial-lines-rectangles-and-gradients */

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

-(void) removeBattery
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect blackRectangle = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddRect(context, blackRectangle);
    CGContextFillRect(context, blackRectangle);
}

-(void) fillBattery
{
    [self drawBattery];
    CGFloat top = self.bounds.origin.y + 5;
    CGFloat currentPosition = self.bounds.origin.x + 5;
    CGFloat width = self.bounds.size.width - 20;
    CGFloat height = self.bounds.size.height - 10;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    //Uncomment the following code to have flat battery
    /*
    CGRect coalRectangle = CGRectMake(currentPosition, top, currentCoalPercentage*width, height);
    currentPosition += currentCoalPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextAddRect(context, coalRectangle);
    CGContextFillRect(context, coalRectangle);
    
    CGRect oilRectangle = CGRectMake(currentPosition, top, currentOilPercentage*width, height);
    currentPosition += currentOilPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextAddRect(context, oilRectangle);
    CGContextFillRect(context, oilRectangle);
    
    CGRect gasRectangle = CGRectMake(currentPosition, top, currentGasPercentage*width, height);
    currentPosition += currentGasPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddRect(context, gasRectangle);
    CGContextFillRect(context, gasRectangle);
    
    CGRect nuclearRectangle = CGRectMake(currentPosition, top, currentNuclearPercentage*width, height);
    currentPosition += currentNuclearPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextAddRect(context, nuclearRectangle);
    CGContextFillRect(context, nuclearRectangle);
    
    CGRect otherFossilRectangle = CGRectMake(currentPosition, top, currentOtherFossilPercentage*width, height);
    currentPosition += currentOtherFossilPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextAddRect(context, otherFossilRectangle);
    CGContextFillRect(context, otherFossilRectangle);
    
    CGRect hydroRectangle = CGRectMake(currentPosition, top, currentHydroPercentage*width, height);
    currentPosition += currentHydroPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextAddRect(context, hydroRectangle);
    CGContextFillRect(context, hydroRectangle);
    
    CGRect geothermalRectangle = CGRectMake(currentPosition, top, currentGeothermalPercentage*width, height);
    currentPosition += currentGeothermalPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor brownColor].CGColor);
    CGContextAddRect(context, geothermalRectangle);
    CGContextFillRect(context, geothermalRectangle);
    
    CGRect windRectangle = CGRectMake(currentPosition, top, currentWindPercentage*width, height);
    currentPosition += currentWindPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor cyanColor].CGColor);
    CGContextAddRect(context, windRectangle);
    CGContextFillRect(context, windRectangle);
    
    CGRect solarRectangle = CGRectMake(currentPosition, top, currentSolarPercentage*width, height);
    currentPosition += currentSolarPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextAddRect(context, solarRectangle);
    CGContextFillRect(context, solarRectangle);
    
    CGRect biomassRectangle = CGRectMake(currentPosition, top, currentBiomassPercentage*width, height);
    currentPosition += currentBiomassPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextAddRect(context, biomassRectangle);
    CGContextFillRect(context, biomassRectangle);
    
    CGRect optOutRectangle = CGRectMake(currentPosition, top, currentOptOutPercentage*width, height);
    currentPosition += currentOptOutPercentage*width;
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, optOutRectangle);
    CGContextFillRect(context, optOutRectangle);*/
    
    //Uncomment the following code to have battery with gradient
    
    CGRect coalRectangle = CGRectMake(currentPosition, top, currentCoalPercentage*width, height);
    currentPosition += currentCoalPercentage*width;
    CGContextAddRect(context, coalRectangle);
    UIColor * darkGreyColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    UIColor * lightGreyColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    drawLinearGradient(context, coalRectangle, lightGreyColor.CGColor, darkGreyColor.CGColor);
    
    CGRect oilRectangle = CGRectMake(currentPosition, top, currentOilPercentage*width, height);
    currentPosition += currentOilPercentage*width;
    CGContextAddRect(context, oilRectangle);
    UIColor * darkOrangeColor = [UIColor colorWithRed:0.5 green:0.2 blue:0.1 alpha:1.0];
    UIColor * lightOrangeColor = [UIColor colorWithRed:0.9 green:0.5 blue:0.0 alpha:1.0];
    drawLinearGradient(context, oilRectangle, lightOrangeColor.CGColor, darkOrangeColor.CGColor);
    
    CGRect gasRectangle = CGRectMake(currentPosition, top, currentGasPercentage*width, height);
    currentPosition += currentGasPercentage*width;
    CGContextAddRect(context, gasRectangle);
    UIColor * darkRedColor = [UIColor colorWithRed:0.3 green:0.1 blue:0.0 alpha:1.0];
    UIColor * lightRedColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.0 alpha:1.0];
    drawLinearGradient(context, gasRectangle, lightRedColor.CGColor, darkRedColor.CGColor);
    
    CGRect nuclearRectangle = CGRectMake(currentPosition, top, currentNuclearPercentage*width, height);
    currentPosition += currentNuclearPercentage*width;
    CGContextAddRect(context, nuclearRectangle);
    UIColor * darkNuclearGreenColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
    UIColor * lightNuclearGreenColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0];
    drawLinearGradient(context, nuclearRectangle, lightNuclearGreenColor.CGColor, darkNuclearGreenColor.CGColor);
    
    CGRect otherFossilRectangle = CGRectMake(currentPosition, top, currentOtherFossilPercentage*width, height);
    currentPosition += currentOtherFossilPercentage*width;
    CGContextAddRect(context, otherFossilRectangle);
    UIColor * darkPurpleColor = [UIColor colorWithRed:0.4 green:0.0 blue:0.4 alpha:1.0];
    UIColor * lightPurpleColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.9 alpha:1.0];
    drawLinearGradient(context, otherFossilRectangle, lightPurpleColor.CGColor, darkPurpleColor.CGColor);
    
    CGRect hydroRectangle = CGRectMake(currentPosition, top, currentHydroPercentage*width, height);
    currentPosition += currentHydroPercentage*width;
    CGContextAddRect(context, hydroRectangle);
    UIColor * darkBlueColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.3 alpha:1.0];
    UIColor * lightBlueColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.7 alpha:1.0];
    drawLinearGradient(context, hydroRectangle, lightBlueColor.CGColor, darkBlueColor.CGColor);
    
    CGRect geothermalRectangle = CGRectMake(currentPosition, top, currentGeothermalPercentage*width, height);
    currentPosition += currentGeothermalPercentage*width;
    CGContextAddRect(context, geothermalRectangle);
    UIColor * darkEarthyColor = [UIColor colorWithRed:0.25 green:0.1 blue:0.05 alpha:1.0];
    UIColor * lightEarthyColor = [UIColor colorWithRed:0.5 green:0.25 blue:0.1 alpha:1.0];
    drawLinearGradient(context, geothermalRectangle, lightEarthyColor.CGColor, darkEarthyColor.CGColor);
    
    CGRect windRectangle = CGRectMake(currentPosition, top, currentWindPercentage*width, height);
    currentPosition += currentWindPercentage*width;
    CGContextAddRect(context, windRectangle);
    UIColor * darkWindyColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.4 alpha:1.0];
    UIColor * lightWindyColor = [UIColor colorWithRed:0.0 green:0.9 blue:0.9 alpha:1.0];
    drawLinearGradient(context, windRectangle, lightWindyColor.CGColor, darkWindyColor.CGColor);
    
    CGRect solarRectangle = CGRectMake(currentPosition, top, currentSolarPercentage*width, height);
    currentPosition += currentSolarPercentage*width;
    CGContextAddRect(context, solarRectangle);
    UIColor * darkYellowColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.0 alpha:1.0];
    UIColor * lightYellowColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    drawLinearGradient(context, solarRectangle, lightYellowColor.CGColor, darkYellowColor.CGColor);
    
    CGRect biomassRectangle = CGRectMake(currentPosition, top, currentBiomassPercentage*width, height);
    currentPosition += currentBiomassPercentage*width;
    CGContextAddRect(context, biomassRectangle);
    UIColor * darkBiomassColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.0 alpha:1.0];
    UIColor * lightBiomassColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
    drawLinearGradient(context, biomassRectangle, lightBiomassColor.CGColor, darkBiomassColor.CGColor);
    
    CGRect optOutRectangle = CGRectMake(currentPosition, top, currentOptOutPercentage*width, height);
    currentPosition += currentOptOutPercentage*width;
    CGContextAddRect(context, optOutRectangle);
    UIColor * darkOptOutColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    UIColor * lightOptOutColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    drawLinearGradient(context, optOutRectangle, lightOptOutColor.CGColor, darkOptOutColor.CGColor);
}


@end
