//
//  THDiaryEntry.swift
//  Diary
//
//  Created by Alex Sims on 24/11/2014.
//  Copyright (c) 2014 Alexander Sims. All rights reserved.
//

import Foundation
import CoreData

// Use an enum to represent mood as its convenient and compile-time safe
enum Mood: Int16 {
    case THDiaryMoodGood = 0
    case THDiaryMoodAverage = 1
    case THDiaryMoodBad = 2
}

class DiaryEntry: NSManagedObject {
    
    @NSManaged var date: NSTimeInterval
    @NSManaged var body: String
    @NSManaged var location: String
    @NSManaged var imageData: NSData
    @NSManaged var mood: Int16
    
    // This does not need to be stored in the datastore as it can be used as a reference variable
    func sectionName() -> String {
        let date = NSDate(timeIntervalSince1970: self.date)
        let f = NSDateFormatter()
        f.dateFormat = "MMMM yyy"
        
        return f.stringFromDate(date)
    }

}
