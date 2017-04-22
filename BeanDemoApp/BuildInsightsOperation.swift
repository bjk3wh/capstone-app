/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CareKit

class BuildInsightsOperation: Operation {
    
    // MARK: Properties
    
    var medicationEvents: DailyEvents?
    
    var painEvents: DailyEvents?
    
    var testProtocolEvents: DailyEvents?
    
    var weightEvents: DailyEvents?
    
    fileprivate(set) var insights = [OCKInsightItem.emptyInsightsMessage()]
    
    // MARK: NSOperation
    
    override func main() {
        // Do nothing if the operation has been cancelled.
        guard !isCancelled else { return }
        
        // Create an array of insights.
        var newInsights = [OCKInsightItem]()
        
        if let insight = createMedicationAdherenceInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createPainInsight() {
            newInsights.append(insight)
        }
        
        if let insight = createTestProtocolChart() {
            newInsights.append(insight)
        }
        
        if let insight = createTestProtocolMessage() {
            newInsights.append(insight)
        }
        
        // Store any new insights thate were created.
        if !newInsights.isEmpty {
            insights = newInsights
        }
    }
    
    // MARK: Convenience
    
    func createMedicationAdherenceInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let medicationEvents = medicationEvents else { return nil }
        
        // Determine the start date for the previous week.
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.day = -7
        let startDate = calendar.weekDatesForDate(calendar.date(byAdding: components as DateComponents, to: now)!).start
        
        var totalEventCount = 0
        var completedEventCount = 0
        
        for offset in 0..<7 {
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            let eventsForDay = medicationEvents[dayComponents]
            
            totalEventCount += eventsForDay.count
            
            for event in eventsForDay {
                if event.state == .completed {
                    completedEventCount += 1
                }
            }
        }
        
        guard totalEventCount > 0 else { return nil }
        
        // Calculate the percentage of completed events.
        let medicationAdherence = Float(completedEventCount) / Float(totalEventCount)
        
        // Create an `OCKMessageItem` describing medical adherence.
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        let formattedAdherence = percentageFormatter.string(from: NSNumber(value: medicationAdherence))!

        let insight = OCKMessageItem(title: "Medication Adherence", text: "Your medication adherence was \(formattedAdherence) last week.", tintColor: Colors.pink.color, messageType: .tip)
        
        return insight
    }
    
    func createPainInsight() -> OCKInsightItem? {
        // Make sure there are events to parse.
        guard let medicationEvents = medicationEvents, let painEvents = painEvents else { return nil }
        
        // Determine the date to start pain/medication comparisons from.
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = -7
        
        let startDate = calendar.date(byAdding: components as DateComponents, to: Date())!

        // Create formatters for the data.
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "E"
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: shortDateFormatter.locale)

        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent

        /*
            Loop through 7 days, collecting medication adherance and pain scores
            for each.
        */
        var medicationValues = [Float]()
        var medicationLabels = [String]()
        var painValues = [Int]()
        var painLabels = [String]()
        var axisTitles = [String]()
        var axisSubtitles = [String]()
        
        for offset in 0..<7 {
            // Determine the day to components.
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            
            // Store the pain result for the current day.
            if let result = painEvents[dayComponents].first?.result, let score = Int(result.valueString) , score > 0 {
                painValues.append(score)
                painLabels.append(result.valueString)
            }
            else {
                painValues.append(0)
                painLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            // Store the medication adherance value for the current day.
            let medicationEventsForDay = medicationEvents[dayComponents]
            if let adherence = percentageEventsCompleted(medicationEventsForDay) , adherence > 0.0 {
                // Scale the adherance to the same 0-10 scale as pain values.
                let scaledAdeherence = adherence * 10.0
                
                medicationValues.append(scaledAdeherence)
                medicationLabels.append(percentageFormatter.string(from: NSNumber(value: adherence))!)
            }
            else {
                medicationValues.append(0.0)
                medicationLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate))
            axisSubtitles.append(shortDateFormatter.string(from: dayDate))
        }

        // Create a `OCKBarSeries` for each set of data.
        let painBarSeries = OCKBarSeries(title: "Pain", values: painValues as [NSNumber], valueLabels: painLabels, tintColor: Colors.blue.color)
        let medicationBarSeries = OCKBarSeries(title: "Medication Adherence", values: medicationValues as [NSNumber], valueLabels: medicationLabels, tintColor: Colors.lightBlue.color)

        /*
            Add the series to a chart, specifing the scale to use for the chart
            rather than having CareKit scale the bars to fit.
        */
        let chart = OCKBarChart(title: "Leg Pain",
                                text: nil,
                                tintColor: Colors.blue.color,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: [painBarSeries, medicationBarSeries],
                                minimumScaleRangeValue: 0,
                                maximumScaleRangeValue: 10)
        
        return chart
    }
    
    func createTestProtocolChart() -> OCKInsightItem? {
        guard let testProtocolEvents = testProtocolEvents, let weightEvents = weightEvents else {return nil}
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = -7
        
        let startDate = calendar.date(byAdding: components as DateComponents, to: Date())!
        
        // Create formatters for the data.
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "E"
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: shortDateFormatter.locale)
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        
        /*
         Loop through 7 days, collecting medication adherance and pain scores
         for each.
         */
        
        var testValues = [Int]()
        var testLabels = [String]()
        var weightValues = [Int]()
        var weightLabels = [String]()
        var axisTitles = [String]()
        var axisSubtitles = [String]()
        
        for offset in 0..<7 {
            // Determine the day to components.
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            
            // Store the pain result for the current day.
            if let result = testProtocolEvents[dayComponents].first?.result, let score = Int(result.valueString) , score > 0 {
                testValues.append(score)
                testLabels.append(result.valueString)
            }
            else {
                testValues.append(0)
                testLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            if let result = weightEvents[dayComponents].first?.result, let score = Int(result.valueString), score > 0 {
                weightValues.append(score)
                weightLabels.append(result.valueString)
            }
            else {
                weightValues.append(0)
                weightLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate))
            axisSubtitles.append(shortDateFormatter.string(from: dayDate))
        }
        
        // Create a `OCKBarSeries` for each set of data.
        let testBarSeries = OCKBarSeries(title: "Force on Plate", values: testValues as [NSNumber], valueLabels: testLabels, tintColor: Colors.red.color)
        
        let weightBarSeries = OCKBarSeries(title: "Weight", values: weightValues as [NSNumber], valueLabels: weightLabels, tintColor: Colors.blue.color)
        
        var maxRange = testValues.max()
        if (maxRange==0) {
            maxRange = 1000
        }
        
        /*
         Add the series to a chart, specifing the scale to use for the chart
         rather than having CareKit scale the bars to fit.
         */
        let chart = OCKBarChart(title: "Weight Bearing",
                                text: nil,
                                tintColor: Colors.blue.color,
                                axisTitles: axisTitles,
                                axisSubtitles: axisSubtitles,
                                dataSeries: [testBarSeries, weightBarSeries],
                                minimumScaleRangeValue: 0,
                                maximumScaleRangeValue: maxRange as NSNumber?)
        
        return chart
    }
    
    func createTestProtocolMessage() -> OCKInsightItem? {
        guard let testProtocolEvents = testProtocolEvents, let weightEvents = weightEvents else {return nil}
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = -7
        
        let startDate = calendar.date(byAdding: components as DateComponents, to: Date())!
        
        // Create formatters for the data.
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "E"
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: shortDateFormatter.locale)
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        
        /*
         Loop through 7 days, collecting medication adherance and pain scores
         for each.
         */
        
        var testValues = [Int]()
        var testLabels = [String]()
        var weightValues = [Int]()
        var weightLabels = [String]()
        var axisTitles = [String]()
        var axisSubtitles = [String]()
        
        for offset in 0..<7 {
            // Determine the day to components.
            components.day = offset
            let dayDate = calendar.date(byAdding: components as DateComponents, to: startDate)!
            let dayComponents = calendar.dateComponents([.year, .month, .day, .era], from: dayDate)
            
            // Store the pain result for the current day.
            if let result = testProtocolEvents[dayComponents].first?.result, let score = Int(result.valueString) , score > 0 {
                testValues.append(score)
                testLabels.append(result.valueString)
            }
            else {
                testValues.append(0)
                testLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            if let result = weightEvents[dayComponents].first?.result, let score = Int(result.valueString), score > 0 {
                weightValues.append(score)
                weightLabels.append(result.valueString)
            }
            else {
                weightValues.append(0)
                weightLabels.append(NSLocalizedString("N/A", comment: ""))
            }
            
            axisTitles.append(dayOfWeekFormatter.string(from: dayDate))
            axisSubtitles.append(shortDateFormatter.string(from: dayDate))
        }
        
        // average the results from weight bearing tests and weight input, then calculate the ratio.  Would do the ratio day by day, but need to account for missing data
        
        var testSum = 0
        var testCount = 0
        for element in 0..<testValues.count {
            if testValues[element] > 0 {
                testCount += 1
                testSum += testValues[element]
            }
        }
        
        var testAvg: Float = 0
        if (testCount != 0) {
            testAvg = Float(testSum)/Float(testCount)
        }
        
        var weightSum = 0
        var weightCount = 0
        for element in 0..<weightValues.count {
            if weightValues[element] > 0 {
                weightCount += 1
                weightSum += weightValues[element]
            }
        }
        
        var weightAvg: Float = 0
        if (weightCount==0) {
            weightAvg = Float(weightSum)/Float(weightCount)
        }
        
        if (testAvg > 0 && weightAvg > 0) {
            let loadRatio: Float = testAvg/weightAvg
            let insight = OCKMessageItem(title: "Weight Bearing", text: "Your implant is bearing \(loadRatio) times your weight when you walk.", tintColor: Colors.blue.color, messageType: .tip)
            return insight
        } else {
            let insight = OCKMessageItem(title: "Weight Bearing", text: "We can't find any data for this week.  Input your weight and run a weight bearing test to see your results.", tintColor: Colors.blue.color, messageType: .alert)
            return insight
        }
        
    }
    
    /**
        For a given array of `OCKCarePlanEvent`s, returns the percentage that are
        marked as completed.
    */
    fileprivate func percentageEventsCompleted(_ events: [OCKCarePlanEvent]) -> Float? {
        guard !events.isEmpty else { return nil }
        
        let completedCount = events.filter({ event in
            event.state == .completed
        }).count
     
        return Float(completedCount) / Float(events.count)
    }
}

/**
 An extension to `SequenceType` whose elements are `OCKCarePlanEvent`s. The
 extension adds a method to return the first element that matches the day
 specified by the supplied `NSDateComponents`.
 */
extension Sequence where Iterator.Element: OCKCarePlanEvent {
    
    func eventForDay(_ dayComponents: NSDateComponents) -> Iterator.Element? {
        for event in self where
                event.date.year == dayComponents.year &&
                event.date.month == dayComponents.month &&
                event.date.day == dayComponents.day {
            return event
        }
        
        return nil
    }
}
