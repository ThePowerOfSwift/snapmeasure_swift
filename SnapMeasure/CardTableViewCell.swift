//
//  CardTableViewCell.swift
//  SnapMeasure
//
//  Created by Camille Dulac on 6/5/15.
//  Copyright (c) 2015 next-shot. All rights reserved.
//

import UIKit
import QuartzCore

class CardTableViewCell: UITableViewCell {
    @IBOutlet var mainView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var myImageView: DrawingView!
    
    func useImage(detailedImage : DetailedImageObject) {
        // Round those corners
        mainView.layer.cornerRadius = 10;
        mainView.layer.masksToBounds = true;
        
        //fill in the data
        nameLabel.text = detailedImage.name
        myImageView.image = UIImage(data: detailedImage.imageData)
        myImageView.initFrame()
        myImageView.initFromObject(detailedImage)
        
        //myImageView.center = CGPointMake(CGRectGetMidX(self.mainView.bounds), CGRectGetMidY(self.mainView.bounds))
        //let scaleFactorX = mainView.bounds.width/myImageView.image!.size.width*mainView.contentScaleFactor
        //let scaleFactorY = mainView.bounds.height/myImageView.image!.size.height*mainView.contentScaleFactor
        //let scaleFactor = min(scaleFactorX, scaleFactorY)
        //myImageView.transform = CGAffineTransformMakeScale(scaleFactor*5, scaleFactor*5);
    }
    
}