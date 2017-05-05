//
//  CareCardStoreManager.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 4/11/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import CareKit

class CarePlanStoreManager: NSObject {
    
    // MARK: Static Properties
    
    static var sharedCarePlanStoreManager = CarePlanStoreManager()
    
    // MARK: Properties
    
    weak var delegate: CarePlanStoreManagerDelegate?
    
    let store: OCKCarePlanStore
    
    var insights: [OCKInsightItem] {
        return insightsBuilder.insights
    }
    
    fileprivate let insightsBuilder: InsightsBuilder
    
    // MARK: Initialization
    
    fileprivate override init() {
        // Determine the file URL for the store.
        let searchPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let applicationSupportPath = searchPaths[0]
        let persistenceDirectoryURL = URL(fileURLWithPath: applicationSupportPath)
        
        if !FileManager.default.fileExists(atPath: persistenceDirectoryURL.absoluteString, isDirectory: nil) {
            try! FileManager.default.createDirectory(at: persistenceDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create the store.
        store = OCKCarePlanStore(persistenceDirectoryURL: persistenceDirectoryURL)
        
        /*
         Create an `InsightsBuilder` to build insights based on the data in
         the store.
         */
        insightsBuilder = InsightsBuilder(carePlanStore: store)
        
        super.init()
        
        // Register this object as the store's delegate to be notified of changes.
        store.delegate = self
        
        // Start to build the initial array of insights.
        updateInsights()
    }
    
    
    func updateInsights() {
        insightsBuilder.updateInsights { [weak self] completed, newInsights in
            // If new insights have been created, notifiy the delegate.
            guard let storeManager = self, let newInsights = newInsights , completed else { return }
            storeManager.delegate?.carePlanStoreManager(storeManager, didUpdateInsights: newInsights)
        }
    }
}



extension CarePlanStoreManager: OCKCarePlanStoreDelegate {
    func carePlanStoreActivityListDidChange(_ store: OCKCarePlanStore) {
        updateInsights()
    }
    
    func carePlanStore(_ store: OCKCarePlanStore, didReceiveUpdateOf event: OCKCarePlanEvent) {
        updateInsights()
    }
}



protocol CarePlanStoreManagerDelegate: class {
    
    func carePlanStoreManager(_ manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem])
    
}
