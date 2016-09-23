//
//  ColorsAndFonts.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/19/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import UIKit

func COLOR(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a);
}

let DARK_BLUE =          COLOR(37.0, g: 61.0, b: 93.0, a: 1.0);
let LIGHT_BLUE    =      COLOR(2.0, g: 162.0, b: 216.0, a: 1.0);
let VERY_LIGHT_GREY =    COLOR(245.0, g: 245.0, b: 245.0, a: 1.0);
let DARK_PURPLE =        COLOR(107.0, g: 0.0, b: 216.0, a: 1.0);
let MEDIUM_GREY =        COLOR(153.0, g: 153.0, b: 153.0, a: 1.0);
let DARK_GREY =          COLOR(102.0, g: 102.0, b: 102.0, a: 1.0);
let BLUE_HIGHLIGHT =     COLOR(242.0, g: 251.0, b: 253.0, a: 1.0);
let PURPLE_HIGHLIGHT =   COLOR(247.0, g: 242.0, b: 253.0, a: 1.0);
let SUBMIT_HIGHLIGHT =   COLOR(42.0, g: 152.0, b: 198.0, a: 1.0);
let LINE_COLOR =         COLOR(221.0, g: 221.0, b: 221.0, a: 1.0);