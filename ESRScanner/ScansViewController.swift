//
//  ViewController.swift
//  einzahlungsschein
//
//  Created by Michael on 30.10.15.
//  Copyright © 2015 Michael Weibel. All rights reserved.
//

import UIKit

class ScansViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var topToolbar: UIToolbar!
    // handling of tableView within extension TableView.swift
    @IBOutlet var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"

    var activityIndicator: ActivityIndicator?
    var scans = Scans()
    var disco : Discover?

    override func viewWillAppear(animated: Bool) {
        self.disco = Discover.sharedInstance

        if self.disco?.connection != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func performImageRecognition(rawImage: UIImage) {
        let image = preprocessImage(rawImage)
        
        let ocr = OCR.init()
        ocr.recognise(image)

        let text = ocr.recognisedText()
        let textArr = text.componentsSeparatedByString("\n").filter{
            // make sure only valid strings in the array go in.
            $0.containsString(">") && $0.characters.count > 35 && $0.characters.count <= 53
        }
        if textArr.count > 0 {
            do {
                let esrCode = try ESR.parseText(textArr[textArr.count-1])
                self.scans.addScan(esrCode)
                self.tableView.reloadData()

                self.disco?.connection?.sendRequest(esrCode.dictionary())
            } catch ESRError.AngleNotFound {
                print("AngleNotFound")
            } catch {
                print("some error thrown")
            }
        }

        activityIndicator?.hide()
    }

    @IBAction func takePhoto(sender: AnyObject) {
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
            message: nil, preferredStyle: .ActionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }

        let libraryButton = UIAlertAction(title: "Choose Existing",
            style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker,
                    animated: true,
                    completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)

        let cancelButton = UIAlertAction(title: "Cancel",
            style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        
        presentViewController(imagePickerActionSheet, animated: true,
            completion: nil)
    }

    @IBAction func clearTextView(sender: AnyObject) {
        let alertCtrl = UIAlertController.init(
            title: "Clear text",
            message: "Are you sure you want to remove the scanned text",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alertCtrl.addAction(UIAlertAction(
            title: "Ok",
            style: .Default,
            handler: {
                (action: UIAlertAction!) in
                    self.scans.clear()
                    self.tableView.reloadData()
            }
        ))

        alertCtrl.addAction(UIAlertAction(
            title: "Cancel",
            style: .Default,
            handler: nil
        ))

        presentViewController(alertCtrl, animated: true, completion: nil)
    }

    @IBAction func shareTextView(sender: AnyObject) {
        let activtyCtrl = UIActivityViewController.init(activityItems: [self.scans.string()], applicationActivities: nil)
        self.presentViewController(activtyCtrl, animated: true, completion: nil)
    }
}
