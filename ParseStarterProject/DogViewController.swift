//
//  DogViewController.swift
//  PawerWalk
//
//  Created by Shiv Kalola on 1/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DogViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var findWalkerButton: UIButton!
    
    @IBOutlet var logOutDogButton: UIBarButtonItem!
    var dogRequestActive = false
    var walkerOnTheWay = false
    
    var locationManager:CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    @IBAction func findWalker(sender: AnyObject) {
        
        if dogRequestActive == false {
        
            let dogRequest = PFObject(className:"dogRequest")
            dogRequest["username"] = PFUser.currentUser()?.username
            dogRequest["location"] = PFGeoPoint(latitude:latitude, longitude:longitude)
            
            dogRequest.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if (success) {
                    
                    self.findWalkerButton.setTitle("Cancel", forState: UIControlState.Normal)
                    
                } else {
                    
                    let alert = UIAlertController(title: "Could not find walker", message: "Please try later", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }
            
                dogRequestActive = true
            
        } else {
                self.findWalkerButton.setTitle("Find a Walker", forState: UIControlState.Normal)
            
                dogRequestActive = false
            
                let query = PFQuery(className:"dogRequest")
                query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // Do something with the found objects
                        if let objects = objects as? [PFObject] {
                            
                            for object in objects {
                                object.deleteInBackground()
                            }
                        }
                    } else {
                        
                        print(error)
                    }
                }
        
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        let query = PFQuery(className:"dogRequest")
        if let username = PFUser.currentUser()?.username! {
            query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    if let objects = objects as? [PFObject] {
                        
                        for object in objects {
                            
                            if let walkerUsername = object["walkerResponded"] {
                                
                                self.findWalkerButton.setTitle("Walker is on the way", forState: UIControlState.Normal)
                                
                                var query = PFQuery(className:"walkerLocation")
                                query.whereKey("username", equalTo:walkerUsername)
                                
                                query.findObjectsInBackgroundWithBlock {
                                    (objects: [AnyObject]?, error: NSError?) -> Void in
                                    
                                    if error == nil {
                                        
                                        if let objects = objects as? [PFObject] {
                                            
                                            for object in objects {
                                                
                                                if let walkerLocation = object["walkerLocation"] as? PFGeoPoint {
                                                    
                                                    let walkerCLLocation = CLLocation(latitude: walkerLocation.latitude, longitude: walkerLocation.longitude)
                                                    let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                                    
                                                    let distanceMeters = userCLLocation.distanceFromLocation(walkerCLLocation)
                                                    let distanceMI = distanceMeters * 0.000621371192
                                                    let roundedTwoDigitDistance = Double(round(distanceMI * 10) / 10)
                                                    
                                                    self.findWalkerButton.setTitle("Walker is \(roundedTwoDigitDistance)mi away!", forState: UIControlState.Normal)
                                                                                                    
                                                    self.walkerOnTheWay = true
                                                    
                                                    let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                                    
                                                    let latDelta = abs(walkerLocation.latitude - location.latitude) * 2 + 0.05
                                                    let lonDelta = abs(walkerLocation.longitude - location.longitude) * 2 + 0.05
                                                    
                                                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                                    
                                                    self.map.setRegion(region, animated: true)
                                                    
                                                    self.map.removeAnnotations(self.map.annotations)
                                                    
                                                    var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                    var objectAnnotation = MKPointAnnotation()
                                                    objectAnnotation.coordinate = pinLocation
                                                    objectAnnotation.title = "Your location"
                                                    self.map.addAnnotation(objectAnnotation)
                                                    
                                                    pinLocation = CLLocationCoordinate2DMake(walkerLocation.latitude, walkerLocation.longitude)
                                                    objectAnnotation = MKPointAnnotation()
                                                    objectAnnotation.coordinate = pinLocation
                                                    objectAnnotation.title = "Walker location"
                                                    self.map.addAnnotation(objectAnnotation)

                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                
                                
                                
                                
                                
                                
                            }
                        }
                    }
                }
            }
        }
        
        if (walkerOnTheWay == false) {
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        self.map.removeAnnotations(map.annotations)
        
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "You are here"
        self.map.addAnnotation(objectAnnotation)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let username = PFUser.currentUser()?.username! {
            if segue.identifier == "logoutDog" {
                locationManager.stopUpdatingLocation()
                PFUser.logOut()
            }
        }
    }

}
