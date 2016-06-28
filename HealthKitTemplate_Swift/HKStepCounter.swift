//
//  HKWalking.swift
//  HealthKitTemplate_Swift
//
//  Created by Xavier Ramos Oliver on 22/06/16.
//  Copyright © 2016 SenseHealth. All rights reserved.
//

import Foundation
import HealthKit

class HKStepCounter {
    
    func readStepCounterSamples (completion: (timeInterval:NSTimeInterval) -> Void) {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(NSDate.distantPast() , endDate: NSDate(), options: HKQueryOptions.None)
        let sortDescriptor = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit:HKObjectQueryNoLimit , sortDescriptors: [sortDescriptor]) {
            (query, results, error) in
            if error != nil {
                print("An error has occured with the following description: \(error!.localizedDescription)")
                completion(timeInterval: 0)
            } else {
                if results?.count >= 1{
                    let sample = results?.first as? HKQuantitySample
                    print("Sample Quantity:",sample!.quantity)
                    print("Sample StartDate:",sample!.startDate)
                    print("timeActive",sample!.endDate.timeIntervalSinceDate(sample!.startDate),"seconds")
                    print("Sample EndDate:",sample!.endDate,"\n")
                    
                    completion(timeInterval: sample!.endDate.timeIntervalSinceDate(sample!.startDate))
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
                self.readStepCounterSamples{ (timeInterval) in
                    dispatch_async(dispatch_get_main_queue()) {
                        //save the new data to DSE.
                    }
                }
            }
            HealthKitProvider().healthStore.executeQuery(self.observerQuery)
        }
    }
    
    func getCumulativeSum(completion: (steps: Int) -> Void) {
        let stepsCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let sumOption = HKStatisticsOptions.CumulativeSum
        let statisticsSumQuery = HKStatisticsQuery(quantityType: stepsCount!, quantitySamplePredicate: nil, options: sumOption){ (query, result, error) in
            if let sumQuantity = result?.sumQuantity() {
                completion(steps: Int(sumQuantity.doubleValueForUnit(HKUnit.countUnit())))
            }
        }
        HealthKitProvider().healthStore.executeQuery(statisticsSumQuery)
    }
    //afegits del projecte gran
    func getBurstValue (completion: (stepsPerMinute: Int, stepsSinceBeginning: Int) -> Void) {
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(NSDate.distantPast() , endDate: NSDate(), options: HKQueryOptions.None)
        let sortDescriptor = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit:HKObjectQueryNoLimit , sortDescriptors: [sortDescriptor]) {
            (query, results, error) in
            if error != nil {
                print("An error has occured with the following description: \(error!.localizedDescription)")
                completion(stepsPerMinute: 0,stepsSinceBeginning: 0)
            } else {
                if results?.count >= 1{
                    for sample in results!{
                        self.getValue(sample, completion: { (stepsPerMinute, stepsSinceBeginning) in
                            // once we have the stepsPerMinute and the stepsSinceBeginning we have to save them
                        })
                    }
                }
            }
        }
        HealthKitProvider().healthStore.executeQuery(query)
    }
    
    func getValue(sample: HKSample, completion: (stepsPerMinute: Int, stepsSinceBeginning: Int) -> Void)  {
        let quantitySample = sample as! HKQuantitySample
        let stepsPerMinute = (quantitySample.quantity.doubleValueForUnit(HKUnit.countUnit())/quantitySample.endDate.timeIntervalSinceDate(quantitySample.startDate))*60
        completion(stepsPerMinute: Int(stepsPerMinute),stepsSinceBeginning: Int(quantitySample.quantity.doubleValueForUnit(HKUnit.countUnit())))
    }
    //-------

    
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

