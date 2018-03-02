//
//  WalkerViewController.swift
//  PawerWalk
//
//  Created by Shiv Kalola on 1/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class WalkerViewController: UITableViewController, CLLocationManagerDelegate {
    
    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var locationManager:CLLocationManager!
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var distances = [CLLocationDistance]()
    
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
        
//        print("locations = \(location.latitude) \(location.longitude)")

        var query = PFQuery(className:"walkerLocation")
        if let username = PFUser.currentUser()?.objectId! {
            query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    if let objects = objects as? [PFObject] {
                        
                        if objects.count > 0 {
                        
                            for object in objects {
                                
                                let query = PFQuery(className:"walkerLocation")
                                query.getObjectInBackgroundWithId(object.objectId!) {
                                    (object: PFObject?, error: NSError?) -> Void in
                                    if error != nil {
                                        print(error)
                                    } else if let object = object {
                                        
                                        object["walkerLocation"] = PFGeoPoint(latitude:location.latitude, longitude:location.longitude)
                                        
                                        object.saveInBackground()
                                    }
                                }
                            }
                        } else {
                            let walkerLocation = PFObject(className:"walkerLocation")
                            walkerLocation["username"] = PFUser.currentUser()?.username
                            walkerLocation["walkerLocation"] = PFGeoPoint(latitude:location.latitude, longitude:location.longitude)
                            
                            walkerLocation.saveInBackground()
                        }
                        
                    }
                    
                } else {
                    
                    print(error)
                }
            }

        
        
        
        
        query = PFQuery(className:"dogRequest")
        query.whereKey("location", nearGeoPoint:PFGeoPoint(latitude:location.latitude, longitude:location.longitude))
        query.limit = 10
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let objects = objects as? [PFObject] {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    
                    for object in objects {
                        
                        if object["walkerResponded"] == nil {
                        
                            if let username = object["username"] as? String {
                                
                                self.usernames.append(username)
                                
                                
                            }
                            
                            if let returnedLocation = object["location"] as? PFGeoPoint {
                                
                                let requestLocation = CLLocationCoordinate2DMake(returnedLocation.latitude, returnedLocation.longitude)
                                
                                self.locations.append(requestLocation)
                                
                                let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                                
                                let walkerCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                
                                let distance = walkerCLLocation.distanceFromLocation(requestCLLocation)
                                
                                self.distances.append(distance * 0.000621371192)
                            }
                            
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            } else {
                
                print(error)
            }
        }

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = "Notifications"
        navigationController!.navigationBar.barTintColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let distanceDouble = Double(distances[indexPath.row])
        let roundedDistance = Double(round(distanceDouble * 10) / 10)
        
        
        cell.textLabel?.text = usernames[indexPath.row] + " - " + String(roundedDistance) + "mi away"
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let username = PFUser.currentUser()?.username! {
            
            if segue.identifier == "logoutWalker" {

                navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: false)

                PFUser.logOut()

                locationManager.stopUpdatingLocation()
            
            }   else if segue.identifier == "showViewRequests" {
                    if let destination = segue.destinationViewController as? RequestViewController {

                        destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                        destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
                
                    }
                }
        
            }
        
        }

    }
