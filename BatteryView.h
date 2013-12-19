//
//  BatteryView.h
//  EnergyBreakapp
//
//  Created by Utkarsh Dalal on 12/12/13.
//  Copyright (c) 2013 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BatteryView : UIView
{
    double currentCoalPercentage, currentOilPercentage, currentGasPercentage, currentNuclearPercentage, currentHydroPercentage, currentRenewablePercentage, currentOtherFossilPercentage, currentGeothermalPercentage, currentWindPercentage, currentSolarPercentage, currentBiomassPercentage, currentOptOutPercentage, currentTotalPercentage;
    BOOL hasDistribution;
}

-(void) setDistributionForCoal: (double) coalPercentage Oil: (double) oilPercentage Gas: (double) gasPercentage Nuclear: (double) nuclearPercentage Hydro: (double) hydroPercentage Renewable: (double) renewablePercentage OtherFossil: (double) otherFossilPercentage Geothermal: (double) geothermalPercentage Wind: (double) windPercentage Solar: (double) solarPercentage Biomass: (double) biomassPercentage OptOut: (double) optOutPercentage AndTotal: (double) totalPercentage;

-(void) removeBattery;

-(void) fillBattery;

-(void) drawBattery;

@end
