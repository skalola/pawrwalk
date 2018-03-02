//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    func displayAlert (title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    
    }
    
    var signUpState = true

    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var `switch`: UISwitch!
    @IBOutlet var dogLabel: UILabel!
    @IBOutlet var walkerLabel: UILabel!
    @IBAction func signUp(sender: AnyObject) {
        
        if username.text=="" || password.text=="" {
            
            displayAlert("Oops!", message:"Please check username and password and try again.")
        
        } else {
            
            if signUpState == true {
                
                let user = PFUser()
                user.username = username.text
                user.password = password.text
            
                user["isWalker"] = `switch`.on
                
                user.signUpInBackgroundWithBlock {
                    (succeeded, error: NSError?) -> Void in
                    if let error = error {
                        
                        if let errorString = error.userInfo["error"] as? String {
                            self.displayAlert("Sign up failed", message: errorString)
                        }
                        
                    } else {
                        
                        if self.`switch`.on == true {
                            self.performSegueWithIdentifier("loginWalker", sender: self)
                        } else {
                            self.performSegueWithIdentifier("loginDog", sender: self)
                        }
                        
                    }
                
                }
            
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if let user = user {
                        
                        if user["isWalker"]! as! Bool == true {
                            self.performSegueWithIdentifier("loginWalker", sender: self)
                        } else {
                            self.performSegueWithIdentifier("loginDog", sender: self)
                        }
                        
                    } else {
                        // The login failed. Check error to see why.
                        if let errorString = error?.userInfo["error"] as? String {
                            self.displayAlert("Login failed", message: errorString)
                        }
                    }
                }
                
            }
        }
    }
    @IBOutlet var switchLabel: UILabel!
    
    @IBOutlet var signUpButton: UIButton!
    
    @IBAction func toggleLogin(sender: AnyObject) {
        
        if signUpState == true {
            
            signUpButton.setTitle("Login", forState: UIControlState.Normal)
            
            switchLabel.text = "Not a member?"
            
            toggleLoginButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            signUpState = false
            
            dogLabel.alpha = 0
            walkerLabel.alpha = 0
            `switch`.alpha = 0
        } else {

            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            switchLabel.text = "Already a member?"
            
            toggleLoginButton.setTitle("Login", forState: UIControlState.Normal)
            
            signUpState = true
            
            dogLabel.alpha = 1
            walkerLabel.alpha = 1
            `switch`.alpha = 1
        }
        
    }
    
    @IBOutlet var toggleLoginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.username.delegate = self;
        self.password.delegate = self;
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil {
            
            if PFUser.currentUser()?["isWalker"]! as! Bool == true {
                self.performSegueWithIdentifier("loginWalker", sender: self)
            } else {
                self.performSegueWithIdentifier("loginDog", sender: self)
            }
        
        }
        
    }
}

