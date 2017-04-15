//
//  Activity.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 4/11/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import CareKit

/**
 Protocol that defines the properties and methods for sample activities.
 */
protocol Activity {
    var activityType: ActivityType { get }
    
    func carePlanActivity() -> OCKCarePlanActivity
}


/**
 Enumeration of strings used as identifiers for the `SampleActivity`s used in
 the app.
 */
enum ActivityType: String {
    // interventions
    case takeMedication
    case goForAWalk
    
    // assessments
    case testProtocol
    case numberOfSteps
    case pain
    case weight
}
