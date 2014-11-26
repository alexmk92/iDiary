//
//  THEntryCell.swift
//  Diary
//
//  Created by Alex Sims on 25/11/2014.
//  Copyright (c) 2014 Alexander Sims. All rights reserved.
//

import UIKit

class THEntryCell: UITableViewCell {

    // Declare these as private to avoid other classes accessing them
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var bodyLabel: UILabel!
    @IBOutlet weak private var locationLabel: UILabel!
    @IBOutlet weak private var mainImageView: UIImageView!
    @IBOutlet weak private var moodImageView: UIImageView!
    
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // Custom dynamic cell heights
    func getHeightForEntry(entry:DiaryEntry) -> CGFloat {
        
        // Margins at top and bottom of table view cell
        let topMargin:CGFloat    = 35.0
        let bottomMargin:CGFloat = 80.0
        let minHeight:CGFloat    = 85.0
        
        // Get system font size, which is used to render the cell to the screen
        let font = UIFont.systemFontOfSize(UIFont.systemFontSize()) as UIFont
        
        // Calculate the bounding box by providing a maximum width and height in the form of CGSize, also provide attributes to providie such as font to draw the box with
        let boundingBox = entry.body.boundingRectWithSize(CGSizeMake(202.0, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil) as CGRect

        // Return either the MAX of minimum height, or the CGRECT with the top and bottom margings
        return max(minHeight, (CGRectGetHeight(boundingBox) + topMargin + bottomMargin))
    }
    
    
    func configureCellForEntry(entry:DiaryEntry) {
        
        // Day of the week, month, year format
        let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM dd yyyy"
        
        // Create the new date object
        let date = NSDate(timeIntervalSince1970: entry.date)
        
        self.bodyLabel.text = entry.body
        self.locationLabel.text = entry.location
        self.dateLabel.text = formatter.stringFromDate(date)

        
        // Check we have image data
        if entry.imageData.length > 0 {
            self.mainImageView!.image = UIImage(data: entry.imageData)
        } else {
            self.mainImageView!.image = UIImage(named: "icn_noimage")
        }
        
        // Set the mood image, to avoid a type mismatch in the switch statement, we must cast entry.mood to a Mood type, using the rawValue expression.
        switch Mood(rawValue: entry.mood) {
            case let THDiaryMoodGood:
                self.moodImageView!.image = UIImage(named: "icn_happy")
            case let THDiaryMoodAverage:
                self.moodImageView!.image = UIImage(named: "icn_average")
            case let THDiaryMoodBad:
                self.moodImageView!.image = UIImage(named: "icn_bad")
            default:
                self.moodImageView!.image = UIImage(named: "icn_noimage")
        }
        
        // Set the rounded edges - using Quartz framework - ensure clipsubviews is checked in storyboard to perform clipped, otherwise this will do nothing
        self.mainImageView.layer.cornerRadius = CGRectGetWidth(self.mainImageView.frame) / 2.0
        

    }
    

}
