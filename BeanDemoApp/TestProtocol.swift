//
//  TestProtocol.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 4/11/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import CareKit

struct TestProtocol: BeanTest {
    
    // MARK: Activity
    
    let activityType: ActivityType = .testProtocol
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 04, day: 09)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Weight Bearing Test", comment: "")
        let summary = NSLocalizedString("", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.green.color,
            resultResettable: true,
            schedule: schedule,
            userInfo: nil
        )
        
        return activity
    }

    
    // MARK: BeanTest
    
    func beanTestResult() -> Float {
        return 1.69 as Float
    }
}
