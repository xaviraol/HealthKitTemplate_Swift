//
//  ViewController.swift
//  HealthKitTemplate_Swift
//
//  Created by Xavier Ramos Oliver on 22/06/16.
//  Copyright © 2016 SenseHealth. All rights reserved.
//

import Foundation
import UIKit
import HealthKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        //request for autorization
        self.requestForAuthorization()
        readWalkingData()
        HealthKitProvider().writeWalkingSampleDate(1000, startDate:NSDate(), endDate:NSDate().dateByAddingTimeInterval(60*60*24))
    }
    
    func requestForAuthorization(){
        HealthKitProvider().requestHealthKitAuthorization { (success, error) in
            print("holahostia")
        }
    }
    
    func readWalkingData() {
        HealthKitProvider().readMostRecentWalkingTimeActiveSample()
    }
}


