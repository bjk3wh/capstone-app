//
//  SampleData.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 4/11/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import CareKit

class SampleData: NSObject {
    let activities: [Activity] = [
        TakeMedication(),
        GoForAWalk(),
        TestProtocol(),
        Pain(),
        Weight()
    ]
    
    /**
     An array of `OCKContact`s to display on the Connect view.
     */
    let contacts: [OCKContact] = [
        OCKContact(contactType: .careTeam,
                   name: "Seth Yarboro",
                   relation: "Orthopedic Surgeon",
                   contactInfoItems:[.phone("888-555-5512"), .sms("888-555-5512"), .email("syarboro2@mac.com")],
                   tintColor: Colors.blue.color,
                   monogram: "MR",
                   image: nil),
        
        OCKContact(contactType: .careTeam,
                   name: "Jason Kerrigan",
                   relation: "PI",
                   contactInfoItems:[.phone("888-555-5512"), .sms("888-555-5512"), .email("jkerrigan2@mac.com")],
                   tintColor: Colors.green.color,
                   monogram: nil,
                   image: nil),
        
        OCKContact(contactType: .personal,
                   name: "Brian Kegerreis",
                   relation: "Developer",
                   contactInfoItems:[.phone("888-555-5512"), .sms("888-555-5512"), .email("bkegerreis2@mac.com")],
                   tintColor: Colors.yellow.color,
                   monogram: nil,
                   image: nil)
    ]
    
    // MARK: Initialization
    
    required init(carePlanStore: OCKCarePlanStore) {
        super.init()
        
        // Populate the store with the sample activities.
        for sampleActivity in activities {
            let carePlanActivity = sampleActivity.carePlanActivity()
            
            carePlanStore.add(carePlanActivity) { success, error in
                if !success {
                    print(error?.localizedDescription)
                }
            }
        }
        
    }
    
    // MARK: Convenience
    
    /// Returns the `Activity` that matches the supplied `ActivityType`.
    func activityWithType(_ type: ActivityType) -> Activity? {
        for activity in activities where activity.activityType == type {
            return activity
        }
        
        return nil
    }
    
    func generateSampleDocument() -> OCKDocument {
        let subtitle = OCKDocumentElementSubtitle(subtitle: "First subtitle")
        
        let paragraph = OCKDocumentElementParagraph(content: "Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque. Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque. Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque.")
        
        let document = OCKDocument(title: "Sample Document Title", elements: [subtitle, paragraph])
        document.pageHeader = "App Name: OCKSample, User Name: John Appleseed"
        
        return document
    }
}

