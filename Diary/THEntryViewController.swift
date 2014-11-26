//
//  THNewEntryViewController.swift
//  Diary
//
//  Created by Alex Sims on 24/11/2014.
//  Copyright (c) 2014 Alexander Sims. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

enum Control:Int16 {
    case Camera
    case Photos
}

class THEntryViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    // View referecnes
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var averageButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!

    
    // We hide the button view by default (out of draw hierachy, however on tap, we allow the view to be shown with the keyboard
    @IBOutlet private var accessoryView: UIView!
    
    // Accessed by segue
    var entry:DiaryEntry?
    var pickedMood:Mood?
    var pickedImage:UIImage?
    var date:NSDate?
    
    // Location finder
    var locationManager:CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.entry != nil {
            self.textView.text = self.entry?.body
            self.pickedMood = Mood(rawValue: self.entry!.mood)
            date = NSDate(timeIntervalSince1970: self.entry!.date)
        } else {
            self.pickedMood = Mood.THDiaryMoodGood
            date = NSDate()
            self.setLocation()
        }
        
        let df = NSDateFormatter()
        df.dateFormat = "EEEE, MMMM d, yyyy"
        
        self.dateLabel.text = df.stringFromDate(date!)
        
        // Shown the accessory view
        let device = UIScreen.mainScreen().bounds
        self.textView.inputAccessoryView = self.accessoryView
        
        self.imageButton.layer.cornerRadius = CGRectGetWidth(self.imageButton.frame)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.textView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissSelf() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func insertNewDiaryEntry() {
        let dataStack:CoreDataStack = CoreDataStack.sharedInstance
        let entry = NSEntityDescription.insertNewObjectForEntityForName("THDiaryEntry", inManagedObjectContext: dataStack.managedObjectContext!) as DiaryEntry
        
        // Add the data
        entry.body = self.textView.text
        entry.date = NSDate().timeIntervalSince1970
        entry.imageData = UIImagePNGRepresentation(getPickedImage())
        entry.mood = pickedMood!.rawValue
        
        dataStack.saveContext()
    }
    
    func updateDiaryEntry() {
        self.entry?.body = self.textView.text
        self.entry?.imageData = UIImagePNGRepresentation(getPickedImage())
        self.entry?.mood = pickedMood!.rawValue
        let dataStack = CoreDataStack.sharedInstance
        
        dataStack.saveContext()
    }
    
    // 
    func promptForSource() {
        let actionSheet = UIActionSheet(title: "Image Source", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "")
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        // Check if the user hasnt canceled
        if buttonIndex != actionSheet.cancelButtonIndex {
            // User tapped camera
            if buttonIndex != actionSheet.firstOtherButtonIndex {
                self.promptFor(Control.Camera)
            } else {
                self.promptFor(Control.Photos)
            }
        }
    }
    
    // Choose the destination source controller (gallery or camera)
    func promptFor(source: Control) {
        let controller = UIImagePickerController()
        
        switch source {
            case .Camera:
                controller.sourceType = UIImagePickerControllerSourceType.Camera
            case .Photos:
                controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        controller.delegate = self
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Grab the image when the user has selected one
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        // Grab the selected image
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        setPickedImage(image)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func DoneWasPressed(sender: AnyObject) {
        if(self.entry != nil) {
            self.updateDiaryEntry()
        } else {
            self.insertNewDiaryEntry()
        }
        self.dismissSelf()
    }

    @IBAction func CancelWasPressed(sender: AnyObject) {
        self.dismissSelf()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Change the mood operator based on input
    @IBAction func badWasPressed(sender: AnyObject) {
        setPickedMood(Mood.THDiaryMoodBad)
    }

    @IBAction func averageWasPressed(sender: AnyObject) {
        setPickedMood(Mood.THDiaryMoodAverage)
    }
    
    @IBAction func goodWasPressed(sender: AnyObject) {
        setPickedMood(Mood.THDiaryMoodGood)
    }
    
    // Check if we need to ask user to browse photo gallery, or take a photo
    @IBAction func imageButtonWasPressed(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.Camera){
            self.promptForSource()
        } else {
            self.promptFor(Control.Photos)
        }
    }
    
    // Set the mood
    func setPickedMood(_pickedMood:Mood) {
        self.pickedMood = _pickedMood as Mood
        
        self.badButton.alpha = 0.5
        self.goodButton.alpha = 0.5
        self.averageButton.alpha = 0.5
        
        switch _pickedMood {
            case .THDiaryMoodAverage:
                averageButton.alpha = 1.0
            case .THDiaryMoodBad:
                badButton.alpha = 1.0
            case .THDiaryMoodGood:
                goodButton.alpha = 1.0
        }
    }

    // Set the image
    func setPickedImage(_pickedImage:UIImage) {
        self.pickedImage = _pickedImage
        
        if self.pickedImage == nil {
            self.imageButton.setImage(UIImage(named: "icn_noimage"), forState: UIControlState.Normal)
        } else {
            self.imageButton.setImage(_pickedImage, forState: UIControlState.Normal)
        }
    }
    
    func getPickedImage() -> UIImage {
        if self.pickedImage != nil {
            return self.pickedImage!
        } else {
            return UIImage(named: "icn_noimage")!
        }
    }
    
    
    // Sets the entrys location only when it hasn't been set
    func setLocation() {
        
        if entry?.location == nil {
            // Create the manager
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            
            // A range of 1000M (0.6Ml) - uses less battery
            self.locationManager!.desiredAccuracy = 1000
            
            // Update the location
            self.locationManager?.startUpdatingLocation()
        }

    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // Stop location updates to conserve battery
        self.locationManager?.stopUpdatingLocation()
        
        // Set the location and return a geocoded string
        let location:CLLocation = locations.first as CLLocation
        
        let coder = CLGeocoder()
        coder.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                let placemark = placemarks.first as CLPlacemark
                self.entry?.location = placemark.name
        })
    }
}
