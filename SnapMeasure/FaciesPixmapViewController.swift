//
//  FaciesPixmapViewController.swift
//  SnapMeasure
//
//  Created by next-shot on 6/16/15.
//  Copyright (c) 2015 next-shot. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class FaciesCatalog {
    let faciesTypes = [
        "sandstone", "shale", "conglomerate", "limestone", "dolomite", "granites"
    ]
    var faciesImages = [FaciesImageObject]()
    
    func count() -> Int {
       return faciesTypes.count + faciesImages.count
    }
    
    func element(index: Int) -> (name: String, image: UIImage) {
        var name : String
        var image: UIImage
        if( index < faciesTypes.count ) {
            image = UIImage(named: faciesTypes[index])!
            name = faciesTypes[index]
        } else {
            image = UIImage(data: faciesImages[index-faciesTypes.count].imageData)!
            name = faciesImages[index-faciesTypes.count].name
        }
        return (name, image)
    }
    func name(index: Int) -> String {
        if( index < faciesTypes.count ) {
            return faciesTypes[index]
        } else {
            return faciesImages[index-faciesTypes.count].name
        }
    }
    
    func image(name: String) -> (image: UIImage?, tile: Bool) {
        for n in faciesTypes {
            if( n == name ) {
                return (UIImage(named: name), true)
            }
        }
        for fio in faciesImages {
            if( name == fio.name ) {
                return (UIImage(data: fio.imageData), fio.tilePixmap.boolValue)
            }
        }
        return (nil,false)
    }
    
    func imageIndex(name: String) -> Int {
        var index = 0
        for n in faciesTypes {
            if( n == name ) {
                return index
            }
            index++
        }
        for fio in faciesImages {
            if( name == fio.name ) {
                return index
            }
            index++
        }
        return -1
    }
    
    func remove(index: Int) {
        faciesImages.removeAtIndex(index - faciesTypes.count)
    }
    
    func loadImages() {
        // Get the full detailed object from the selected name
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"FaciesImageObject")
        
        var error: NSError?
        var images = (managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [FaciesImageObject])!
        
        faciesImages = images
    }
}

class FaciesTypeTablePickerController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var faciesCatalog : FaciesCatalog?
    var typeButton : UIButton?
    var drawingView: DrawingView?
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faciesCatalog!.count()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PixmapCell", forIndexPath: indexPath) as! UITableViewCell
        let row = indexPath.row
        let imageInfo = faciesCatalog!.element(row)
        cell.imageView!.image = imageInfo.image
        cell.textLabel!.text = imageInfo.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let name = faciesCatalog!.name(row)
        typeButton?.setTitle(name, forState: UIControlState.Normal)
        drawingView?.faciesView.curImageName = name
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let row = indexPath.row
        if( row < faciesCatalog!.faciesTypes.count ) {
            return UITableViewCellEditingStyle.None
        } else {
            return UITableViewCellEditingStyle.Delete
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        if( editingStyle == UITableViewCellEditingStyle.Delete && row >= faciesCatalog!.faciesTypes.count ) {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            faciesCatalog!.remove(row)
        }
    }
    
}

class FaciesPixmapViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var tableController = FaciesTypeTablePickerController()
    var picker = UIImagePickerController()
    var typeButton : UIButton?
    var drawingView: DrawingView?
    var faciesCatalog: FaciesCatalog?
    var drawingController : DrawingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = tableController
        tableView.dataSource = tableController
        tableController.typeButton = typeButton
        tableController.drawingView = drawingView
        tableController.faciesCatalog = faciesCatalog
        
        picker.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        if( drawingController != nil ) {
            drawingController!.imageView.center = drawingController!.center
        }
    }
    
    @IBAction func AddPixmap(sender: AnyObject) {
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(
        picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]
    ) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismissViewControllerAnimated(true, completion: nil)
        askImageName(chosenImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func askImageName(image: UIImage) {
        var inputTextField : UITextField?
        let alert = UIAlertController(title: "Please give image a name", message: "And choose import method", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
            inputTextField = textField
        }
        let noAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Default) { action -> Void in
        }
        alert.addAction(noAction)
        let yesScaleAction: UIAlertAction = UIAlertAction(title: "Ok & Scale", style: .Default) { action -> Void in
            // scale to 128 pixels.
            var scale = 128.0/max(image.size.width, image.size.height)
            var size = CGSize(width: image.size.width*scale, height: image.size.height*scale)
            var nimage = self.resizeImage(image, newSize: size)
            
            // Create ImageObject
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            var detailedImage = NSEntityDescription.insertNewObjectForEntityForName("FaciesImageObject",
                inManagedObjectContext: managedContext) as? FaciesImageObject
            
            detailedImage!.imageData = UIImageJPEGRepresentation(nimage, 1.0)
            detailedImage!.name = inputTextField!.text
            detailedImage!.tilePixmap = true
            
            self.tableController.faciesCatalog!.faciesImages.append(detailedImage!)
            self.tableView.reloadData()
        }
        alert.addAction(yesScaleAction)
        
        let yesNoScaleAction: UIAlertAction = UIAlertAction(title: "Ok & Use as is", style: .Default) { action -> Void in
            // Create ImageObject
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            var detailedImage = NSEntityDescription.insertNewObjectForEntityForName("FaciesImageObject",
                inManagedObjectContext: managedContext) as? FaciesImageObject
            
            detailedImage!.imageData = UIImageJPEGRepresentation(image, 1.0)
            detailedImage!.name = inputTextField!.text
            detailedImage!.tilePixmap = false
            
            self.tableController.faciesCatalog!.faciesImages.append(detailedImage!)
            self.tableView.reloadData()
        }
        alert.addAction(yesNoScaleAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        let imageRef = image.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        CGContextDrawImage(context, newRect, imageRef)
        
        let newImageRef = CGBitmapContextCreateImage(context) as CGImage
        let newImage = UIImage(CGImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
