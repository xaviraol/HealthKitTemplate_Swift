//
//  HKWalking.swift
//  HealthKitTemplate_Swift
//
//  Created by Xavier Ramos Oliver on 22/06/16.
//  Copyright © 2016 SenseHealth. All rights reserved.
//

import Foundation
import HealthKit

class HKWalking {
    
    func readMostRecentWalkingTimeActiveSample (completion: (timeInterval:NSTimeInterval) -> Void) {
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        let predicate = HKQuery.predicateForSamplesWithStartDate(NSDate.distantPast() , endDate: NSDate(), options: HKQueryOptions.None)
        let sortDescriptor = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit:HKObjectQueryNoLimit , sortDescriptors: [sortDescriptor]) {
            
            (query, results, error) in
            if error != nil {
                print("An error has occured with the following description: \(error!.localizedDescription)")
            } else {
                
                let sample = results?.first as? HKQuantitySample
                print("Sample Quantity:",sample!.quantity)
                print("Sample StartDate:",sample!.startDate)
                print("timeActive",sample!.endDate.timeIntervalSinceDate(sample!.startDate),"seconds")
                print("Sample EndDate:",sample!.endDate,"\n")
                if sample?.endDate.compare((sample?.startDate)!) == .OrderedSame
                {
                    let distance = sample?.quantity.doubleValueForUnit(HKUnit.meterUnitWithMetricPrefix(HKMetricPrefix.Kilo));
                    let averageWalkingSpeed = 5.0;
                    let timeActive = (distance!/averageWalkingSpeed) * 3600
                    print("TIMEACTIVE DEL PRIMER:",timeActive)
                    if (error != nil){
                        completion(timeInterval: timeActive)
                    }
                }else{
                    let timeActive = sample!.endDate.timeIntervalSinceDate(sample!.startDate)
                    print("TIMEACTIVE DEL PRIMER:",timeActive)
                    if (error != nil){
                        completion(timeInterval: timeActive)
                    }
                }
            }
        }
        HealthKitProvider().healthStore.executeQuery(query)
    }
    
    var observerQuery: HKObserverQuery!
    
    func startObservingForWalkingSamples() {
        print("startObservingForHeartRateSamples")
        let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        
        if observerQuery != nil {
            HealthKitProvider().healthStore.stopQuery(observerQuery)
        }
        
        observerQuery = HKObserverQuery(sampleType: sampleType!, predicate: nil) {
            (query, completionHandler, error) in
            
            if error != nil {
                print("An error has occured with the following description: \(error!.localizedDescription)")
                abort()
            } else {
                self.readMostRecentWalkingTimeActiveSample{ (timeInterval) in
                    dispatch_async(dispatch_get_main_queue()) {
                        //save the new data to DSE.
                    }
                }
            }
            HealthKitProvider().healthStore.executeQuery(self.observerQuery)
        }
    }
    
    func writeWalkingSampleDate(distance:Double, startDate:NSDate, endDate:NSDate)->Void{
        let walkingQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        let walkingUnit = HKUnit.meterUnit()
        let quantityWalk = HKQuantity(unit: walkingUnit, doubleValue: distance)
        
        let walkingQuantitySample = HKQuantitySample(type: walkingQuantityType!, quantity:quantityWalk, startDate:startDate, endDate:endDate)
        
        HealthKitProvider().healthStore.saveObject(walkingQuantitySample) { (success, error) in
            print("DataPoint saved to HealthKit")
        }
    }
}

