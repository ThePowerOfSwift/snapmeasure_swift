//
//  Line.swift
//  SnapMeasure
//
//  Created by next-shot on 6/3/15.
//  Copyright (c) 2015 next-shot. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LineObject : NSManagedObject {

    @NSManaged var pointData: NSData
    @NSManaged var name: String
    @NSManaged var point: CGPoint
    @NSManaged var colorData: NSData
    @NSManaged var type : String
    @NSManaged var image: DetailedImageObject

}
