//
//  THNavigationController.swift
//  Diary
//
//  Created by Alex Sims on 25/11/2014.
//  Copyright (c) 2014 Alexander Sims. All rights reserved.
//

import UIKit

// Subclass the navigation controller so we can skin it
class THNavigationController: UINavigationController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
