//
//  RequestViewController.swift
//  PawerWalk
//
//  Created by Shiv Kalola on 1/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RequestViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var map: MKMapView!    
    @IBAction func walkDog(sender: AnyObject) {
        
        var query = PFQuery(className:"dogRequest")
        query.whereKey("username", equalTo:requestUsername)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let objects = objects as? [PFObject] {
                    
                    for object in objects {
                        
                        
                        var query = PFQuery(className:"dogRequest")
                        query.getObjectInBackgroundWithId(object.objectId!) {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil {
                                print(error)
                            } else if let object = object {
                                object["walkerResponded"] = PFUser.currentUser()!.username!
                                
                                object.saveInBackground()

                                
                                let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                                
                                CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) -> Void in
                                    
                                    if error != nil {
                                        print(error!)
                                    } else {
                                    
                                        if placemarks!.count > 0 {
                                            let pm = placemarks![0] as! CLPlacemark
                                            
                                            let mkPm = MKPlacemark(placemark: pm)
                                            
                                            var mapItem = MKMapItem(placemark: mkPm)
                                            
                                            mapItem.name = self.requestUsername
                                            
                                            var launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                            
                                            mapItem.openInMapsWithLaunchOptions(launchOptions)
                                            
                                            
                                        } else {
                                            print("this")
                                        }
                                    }
                                })
                               
                            }
                        }
                    }
                }
            } else {
                
                print(error)
            }
        }

        
    }
    
    var requestLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var requestUsername:String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(requestUsername)
        print(requestLocation)
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        self.map.removeAnnotations(map.annotations)
        
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = requestLocation
        objectAnnotation.title = requestUsername
        self.map.addAnnotation(objectAnnotation)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = "\(requestUsername)'s Location"
        navigationController!.navigationBar.barTintColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
