//
//  HealthKitProvider.swift
//  HealthKitTemplate_Swift
//
//  Created by Xavier Ramos Oliver on 22/06/16.
//  Copyright © 2016 SenseHealth. All rights reserved.
//

import Foundation
import HealthKit


class HealthKitProvider{
    
    let healthStore:HKHealthStore = HKHealthStore()
    
    func requestHealthKitAuthorization(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        if !HKHealthStore.isHealthDataAvailable() {
            return;
        }
        
        let readTypes = NSSet (array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
            HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!])
        
        let writeTypes = NSSet (array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
            HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!])
        
        healthStore.requestAuthorizationToShareTypes(writeTypes as? Set<HKSampleType>, readTypes: readTypes as? Set<HKObjectType>) { (success, error) in
            completion(success: success,error: error);
        }
    }
    
    func readMostRecentWalkingTimeActiveSample(){
        HKWalking().readMostRecentWalkingTimeActiveSample { (timeInterval) in
            print("hem arribat al provider: %@",timeInterval)
        }
    }
    
    func writeWalkingSampleDate(distance:Double, startDate:NSDate, endDate:NSDate)->Void{
        HKWalking().writeWalkingSampleDate(distance, startDate: startDate, endDate:endDate)
    }
    
}




