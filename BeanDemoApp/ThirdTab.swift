//
//  ThirdTab.swift
//  BeanDemoApp
//
//  Created by Stephanie Brown on 3/16/17.
//  Copyright © 2017 Kerrigan Capstone Team. All rights reserved.
//

import UIKit
import Bean_iOS_OSX_SDK

class ThirdTab: UIViewController, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    
    //Here lies the OG code to toggle the LED
    
    
    /*
    var beanManager: PTDBeanManager?
    var yourBean: PTDBean?
    var lightState: Bool = false
    
    @IBOutlet weak var buttonTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beanManager=PTDBeanManager()
        beanManager!.delegate=self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beanManagerDidUpdateState(_ beanManager: PTDBeanManager!) {
        let scanError: NSError?
        
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
    }
    
    @IBAction func toggleButton(_ sender: Any) {
        
        lightState = !lightState
        updateLedStatusText(lightState: lightState)
        let data = NSData(bytes: &lightState, length: MemoryLayout<Bool>.size)
        sendSerialData(beanState: data)
    }
    
    func sendSerialData(beanState: NSData) {
        yourBean?.sendSerialData(beanState as Data!)
    }
    
    func updateLedStatusText(lightState: Bool) {
        let onOffText = lightState ? "ON" : "OFF"
        buttonTextLabel.text = "Button is \(onOffText)"
    }
    */
    
}

