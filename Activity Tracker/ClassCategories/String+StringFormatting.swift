//
//  String+StringFormatting.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation

extension String
{
    func dashesForEmpty () -> String
    {
        return self.characters.count > 0 ? self : "--";
    }
}