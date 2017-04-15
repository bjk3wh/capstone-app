//
//  GoForAWalk.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 4/11/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import CareKit

struct GoForAWalk: Activity {
    let activityType: ActivityType = .goForAWalk
    
    func carePlanActivity() -> OCKCarePlanActivity {
        let startDate = DateComponents(year: 2017, month: 04, day: 09)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        let title = NSLocalizedString("Go for a walk", comment:"")
        let summary = NSLocalizedString("15 minutes", comment: "")
        let instructions = NSLocalizedString("Take a leisurely walk", comment: "")
        
        let activity = OCKCarePlanActivity.intervention(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.green.color,
            instructions: instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: nil
        )
        
        return activity
    }
}
