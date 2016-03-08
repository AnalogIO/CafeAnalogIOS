//
//  ViewController.swift
//  Café Analog
//
//  Created by Jacob Benjamin Cholewa on 25/02/2016.
//  Copyright © 2016 Jacob Benjamin Cholewa. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class OpenViewController: UIViewController {

    let locationManager = CLLocationManager()
    //let analog = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E3B54450-AB73-4D79-85D6-519EAF0F45D9")!, major: 0, minor: 2011, identifier: "Analog")
    //let pitlab = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E3B54450-AB73-4D79-85D6-519EAF0F45D9")!, major: 5, minor: 1561, identifier: "PitLab")
    let itu = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E3B54450-AB73-4D79-85D6-519EAF0F45D9")!, identifier: "ITU")
    
    
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways){
            locationManager.requestAlwaysAuthorization()
        }
        
        //locationManager.startMonitoringForRegion(analog)
        //locationManager.startMonitoringForRegion(pitlab)
        locationManager.startMonitoringForRegion(itu)
        update()
    }
    

    @IBAction func tapAction(sender: AnyObject) {
        update()
    }

    func update(){
        debugPrint("update")
        Alamofire.request(.GET, "http://cafeanalog.dk/api/open/")
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                let open:Bool = response.objectForKey("open") as! Bool
                self.setOpenLabel(open)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setOpenLabel(state: Bool){
        if state {
            label.text = "Analog is ÅPEN!"
        }
        else {
            label.text = "Analog is CLØSED!"
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

