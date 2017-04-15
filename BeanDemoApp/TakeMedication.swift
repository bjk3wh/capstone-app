//
//  TakeMedication.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 4/11/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import CareKit

struct TakeMedication: Activity {
    let activityType: ActivityType = .takeMedication
    
    func carePlanActivity() -> OCKCarePlanActivity {
        let startDate = DateComponents(year: 2017, month: 04, day: 09)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [2, 2, 2, 2, 2, 2, 2])
        let title = NSLocalizedString("Percocet", comment:"Molly, percocet")
        let summary = NSLocalizedString("5/325", comment: "")
        let instructions = NSLocalizedString("Take with food", comment: "")
        
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
