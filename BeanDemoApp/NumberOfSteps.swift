//
//  NumberOfSteps.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 4/11/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import ResearchKit
import CareKit

/**
 Struct that conforms to the `Sample` protocol to define a weight assessment.
 */
struct NumberOfSteps: Assessment {
    // MARK: Activity properties
    
    let activityType: ActivityType = .numberOfSteps
    
    // MARK: Activity
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = DateComponents(year: 2017, month: 04, day: 09)
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: startDate as DateComponents, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Number of Steps", comment: "")
        let summary = NSLocalizedString("", comment: "")
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.yellow.color,
            resultResettable: false,
            schedule: schedule,
            userInfo: nil
        )
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        // Get the localized strings to use for the task.
        let answerFormat = ORKNumericAnswerFormat(style: .integer, unit: "steps")
        //let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
        
        // Create a question.
        let title = NSLocalizedString("How many steps did you take today?", comment: "")
        let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: title, answer: answerFormat)
        questionStep.isOptional = false
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStep])
        
        return task
    }
    
}

