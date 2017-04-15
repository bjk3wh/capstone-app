//
//  FirstTab.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 3/16/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import UIKit
import Bean_iOS_OSX_SDK
import CareKit

class FirstTab: UIViewController, PTDBeanManagerDelegate, PTDBeanDelegate/*, OCKSymptomTrackerViewController*/ {
    
    public var event: OCKCarePlanEvent!
    public var store: OCKCarePlanStore!
    
    var beanManager: PTDBeanManager?
    var yourBean: PTDBean?
    var testStatus: UInt8 = 0
    var timeElapsed: UInt8 = 0
    var max1: Int16 = 0
    var max2: Int16 = 0
    var max3: Int16 = 0
    var max1didUpdate: Bool = false
    var max2didUpdate: Bool = false
    var max3didUpdate: Bool = false
    var testReady: Bool = false
    var testRunning: Bool = false
    var requester: Bool = true
    var statusBuffer = Array(repeating:0 as UInt8,count:20)
    var timeBuffer = Array(repeating:0 as UInt8,count:20)
    var dataBuffer1 = Array(repeating:0 as UInt8,count:20)
    var dataBuffer2 = Array(repeating:0 as UInt8,count:20)
    var dataBuffer3 = Array(repeating:0 as UInt8,count:20)
    var done: Int32 = 0x7FFFFFFF
    var scratchTimer = Timer()
    var testTimer = Timer()
    var stopTest: Bool = false
    
    @IBOutlet weak var buttonTextLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var maxLabel1: UILabel!
    @IBOutlet weak var maxLabel2: UILabel!
    @IBOutlet weak var maxLabel3: UILabel!
    @IBOutlet weak var finishButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beanManager=PTDBeanManager()
        beanManager!.delegate=self
        updateStatusText(status: testStatus)
        // continuously update status until it is ready, that way the first button press once it's ready should fire everything off
        scratchTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(isTestReady), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beanManagerDidUpdateState(_ beanManager: PTDBeanManager!) {
        //let scanError: NSError?

        if beanManager!.state == BeanManagerState.poweredOn {
            startScanning()
            //if let e = scanError {
            //  print(e)
            //} else {
            //  print("Please turn on your Bluetooth")
            //}
        }
    }
    
    func startScanning() {
        var error: NSError?
        beanManager!.startScanning(forBeans_error: &error)
        if let e = error {
            print(e)
        }
    }
    
    func beanManager(_ beanManager: PTDBeanManager!, didDiscover bean: PTDBean!, error: Error!) {
        if let e = error {
            print(e)
        }
        
        print("Found a Bean: \(bean.name)")
        if bean.name == "BJKBean1" {
            yourBean = bean
            connectToDevice(yourBean!)
        }
    }
    
    func connectToDevice(_ device: PTDBean) {
        var error: NSError?
        beanManager?.connect(to: device, withOptions:nil, error: &error)
        device.delegate = self
        device.releaseSerialGate() // eliminate 10 second delay in serial data
    }
    
    // commenting this function out in case it is interfering with the other bean() function for scratch data (but I don't think that will be a problem at the moment)
    
    //func bean(_ bean: PTDBean!, serialDataReceived data: Data!) {
    //    if data != nil {
    //        let receivedMessage = NSString(data:data, encoding:String.Encoding.utf8.rawValue)
    //        incomingString = receivedMessage! as String
    //    }
    //}
    
    func bean(_ bean: PTDBean!, didUpdateScratchBank bank: Int, data: Data!) {
        if data != nil {
            switch (bank) {
            case 1:
                data!.copyBytes(to: &statusBuffer, count: data.count)
            case 2: //ignore xcode warnings for 2-4 since we don't need copyBytes() return value
                data!.copyBytes(to: &dataBuffer1, count: data.count)
                max1didUpdate = true
                //data!.copyBytes(to: UnsafeMutableBufferPointer(start: &dataBuffer1, count: 5))
            case 3:
                data!.copyBytes(to: &dataBuffer2, count: data.count)
                max2didUpdate = true
                //data!.copyBytes(to: UnsafeMutableBufferPointer(start: &dataBuffer2, count: 5))
            case 4:
                data!.copyBytes(to: &dataBuffer3, count: data.count)
                max3didUpdate = true
                //data!.copyBytes(to: UnsafeMutableBufferPointer(start: &dataBuffer3, count: 5))
            case 5:
                data!.copyBytes(to: &timeBuffer, count: data.count)
            default:
                break
            }
        }
    }
    
    func isTestReady() -> Bool { // expanded functionality to handle being called by scratchTimer during startup to check Bean readiness
        yourBean?.readScratchBank(1)
        testStatus = statusBuffer[3]
        if (testStatus==1) {
            testReady = true
            scratchTimer.invalidate()
        }
        else {testReady = false}
        updateStatusText(status: testStatus)
        return testReady
    }
    
    /*
    func isTestRunning() -> Bool { // not currently being used
        yourBean?.readScratchBank(5)
        testStatus = statusBuffer[3]
        if (testStatus > 1) {
            testRunning = true
        }
        else {testRunning = false}
        
        return testRunning
    }
    */
    
    func sendSerialData(beanState: NSData) {
        yourBean?.sendSerialData(beanState as Data!)
    }
    
    func updateStatusText(status: UInt8) {
        switch (testStatus) {
        case 0:
            buttonTextLabel.text = "Not Ready"
        case 1:
            buttonTextLabel.text = "Ready"
        case 2:
            buttonTextLabel.text = "Starting..."
        case 3:
            buttonTextLabel.text = "Stand"
        case 4:
            buttonTextLabel.text = "Walk"
        case 5:
            buttonTextLabel.text = "Finalizing..."
        case 6:
            buttonTextLabel.text = "Complete!"
        default:
            break
        }
    }
    
    func updateTimerText() {
        timerLabel.text = "Time Elapsed: \(timeElapsed)"
    }
    
    func updateMaxText() {
        maxLabel1.text = "Max 1: \(max1)"
        maxLabel2.text = "Max 2: \(max2)"
        maxLabel3.text = "Max 3: \(max3)"
    }
    
    func testarino() { //called every
        let testRequest = NSData(bytes: &requester, length: MemoryLayout<Bool>.size)
        let doneData = NSData(bytes: &done, length:MemoryLayout<Int32>.size)
        yourBean?.readScratchBank(1)
        testStatus = statusBuffer[3]
        if stopTest {
            testStatus = 6
        }
        updateStatusText(status: testStatus)
        switch (testStatus){
        case 1: //ready to test
            sendSerialData(beanState: testRequest)
            print("request sent: \(testRequest)\n")
        case 2: //starting test
            break
        case 3: //standing
            yourBean?.readScratchBank(5)
            timeElapsed = timeBuffer[0]
            updateTimerText()
        case 4: //walking
            yourBean?.readScratchBank(5)
            timeElapsed = timeBuffer[0]
            updateTimerText()
        case 5: // finalizing
            //read max values from dataBuffers 1-3
            // it sends the second byte in dataBufferx[0] and the first byte in dataBufferx[1]
            // so 0x7fff comes through as 0xff7f
            //  fixed by data1, data2, data3 manipulation
            
            /*
             notes to self
             check .byteSwapped to make sure it isn't doing anything dumb
             add breakpoint once test is done to check data buffers, data1,2,3, and max1,2,3
             can revive max1a, max1b idea and pass those as the bytes for data1,2,3
            */
            
            // next problem to deal with is that the Bean takes a while to update scratch 3 and 4, so the max value aren't updated in time.  Need to add some sort of loop to case 5 to make sure all three maxes have received new values before updating text labels
            // fix: add 3 Bools to didUpdateScratchBank to keep it from stopping the test
            
            yourBean?.readScratchBank(2)
            let data1 = Data(bytes: &dataBuffer1, count: 2)
            max1 = Int16(littleEndian: data1.withUnsafeBytes { $0.pointee })
            //max1 = max1.byteSwapped could call it as bigEndian and byteswap it, and it should have the same effect as just calling it littleEndian
            yourBean?.readScratchBank(3)
            let data2 = Data(bytes: &dataBuffer2, count: 2)
            max2 = Int16(littleEndian: data2.withUnsafeBytes { $0.pointee })
            //max2 = max2.byteSwapped
            yourBean?.readScratchBank(4)
            let data3 = Data(bytes: &dataBuffer3, count: 2)
            max3 = Int16(littleEndian: data3.withUnsafeBytes { $0.pointee })
            //max3 = max3.byteSwapped
            updateMaxText()
            if (max1didUpdate && max2didUpdate && max3didUpdate) {
                yourBean?.setScratchBank(1,data: doneData as Data!) //tell the Bean it's done
                stopTest = true
            }
        case 6: //complete
            testTimer.invalidate()
            let results = OCKCarePlanEventResult.init(valueString: "\(max1)", unitString: "/32767", userInfo: nil)
            store.update(event, with: results, state: .completed, completion: {(success,event,error) -> Void in
                guard success else {
                fatalError("could not update the care plan store")
                }
                })
            finishButtonLabel.setTitle("Return",for: .normal)
        default:
            break
        }
    }
    
    @IBAction func toggleButton(_ sender: Any) { //should probably compress this into a function that starts a test if ready, and then write a new function that does the test.  Whatever.
        
        /* OK.  So nest Bean functions in a while loop won't work.  Can I swing a continuous function with a timer or something?  Or some sort of ISR?  Goto isn't in Swift.  This really sucks.
        */
        if (isTestReady()) {
            testTimer.invalidate() // in case it was already running
            testTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(FirstTab.testarino), userInfo: nil, repeats: true)
        }
        updateStatusText(status: testStatus)
        
    }
    
    @IBAction func finishButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
    
}

